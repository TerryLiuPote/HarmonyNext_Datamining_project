import numpy as np
from db.models import db
from config.config import RECOMMENDATION_CONFIG

class RecommendationSystem:
    def __init__(self):
        self.algorithm = RECOMMENDATION_CONFIG['algorithm']
        self.similarity_threshold = RECOMMENDATION_CONFIG['similarity_threshold']
        self.max_recommendations = RECOMMENDATION_CONFIG['max_recommendations']
    
    def get_user_ratings(self):
        """
        获取所有用户的评分数据
        返回格式: {user_id: {product_id: rating}}
        """
        query = "SELECT user_id, product_id, rating FROM ratings"
        results = db.fetch_query(query)
        
        user_ratings = {}
        for user_id, product_id, rating in results:
            if user_id not in user_ratings:
                user_ratings[user_id] = {}
            user_ratings[user_id][product_id] = rating
        
        return user_ratings
    
    def calculate_similarity(self, user1_ratings, user2_ratings):
        """
        计算两个用户之间的相似度（余弦相似度）
        """
        # 找到两个用户共同评分的产品
        common_products = set(user1_ratings.keys()) & set(user2_ratings.keys())
        
        if not common_products:
            return 0
        
        # 计算余弦相似度
        user1_vector = np.array([user1_ratings[product] for product in common_products])
        user2_vector = np.array([user2_ratings[product] for product in common_products])
        
        dot_product = np.dot(user1_vector, user2_vector)
        norm_user1 = np.linalg.norm(user1_vector)
        norm_user2 = np.linalg.norm(user2_vector)
        
        if norm_user1 == 0 or norm_user2 == 0:
            return 0
        
        return dot_product / (norm_user1 * norm_user2)
    
    def get_similar_users(self, target_user_id):
        """
        找到与目标用户相似的用户
        """
        user_ratings = self.get_user_ratings()
        
        if target_user_id not in user_ratings:
            return []
        
        target_ratings = user_ratings[target_user_id]
        similar_users = []
        
        for user_id, ratings in user_ratings.items():
            if user_id == target_user_id:
                continue
            
            similarity = self.calculate_similarity(target_ratings, ratings)
            if similarity >= self.similarity_threshold:
                similar_users.append((user_id, similarity))
        
        # 按相似度降序排序
        similar_users.sort(key=lambda x: x[1], reverse=True)
        
        return similar_users
    
    def get_recommendations(self, target_user_id):
        """
        为目标用户生成推荐
        """
        user_ratings = self.get_user_ratings()
        
        if target_user_id not in user_ratings:
            return []
        
        # 获取目标用户已评分的产品
        target_rated_products = set(user_ratings[target_user_id].keys())
        
        # 获取相似用户
        similar_users = self.get_similar_users(target_user_id)
        
        if not similar_users:
            return []
        
        # 计算产品推荐分数
        product_scores = {}
        for user_id, similarity in similar_users:
            for product_id, rating in user_ratings[user_id].items():
                # 只推荐目标用户未评分的产品
                if product_id not in target_rated_products:
                    if product_id not in product_scores:
                        product_scores[product_id] = 0
                    product_scores[product_id] += rating * similarity
        
        # 按推荐分数降序排序
        sorted_recommendations = sorted(product_scores.items(), key=lambda x: x[1], reverse=True)
        
        # 限制推荐数量
        recommendations = [product_id for product_id, score in sorted_recommendations[:self.max_recommendations]]
        
        # 获取产品详情
        if recommendations:
            placeholders = ','.join(['%s'] * len(recommendations))
            query = f"SELECT id, name, description, category, price FROM products WHERE id IN ({placeholders})"
            products = db.fetch_query(query, recommendations)
            
            # 保持推荐顺序
            product_dict = {product[0]: product for product in products}
            return [product_dict[product_id] for product_id in recommendations if product_id in product_dict]
        
        return []
    
    def get_content_based_recommendations(self, target_user_id):
        """
        基于内容的推荐（备用算法）
        """
        # 这里可以实现基于内容的推荐算法
        # 例如：根据用户喜欢的产品类别推荐相似类别的产品
        pass

# 初始化推荐系统
recommendation_system = RecommendationSystem()