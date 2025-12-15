from flask import Flask, request, jsonify
from flask_cors import CORS
import hashlib
import json
from db.models import db
from recommendation_system.recommendation import recommendation_system
from config.config import SERVER_CONFIG, NETWORK_CONFIG

app = Flask(__name__)
CORS(app)  # 启用CORS，允许跨域请求

# 密码加密函数
def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()

# 用户注册接口
@app.route('/api/users/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    email = data.get('email')
    
    if not all([username, password, email]):
        return jsonify({'error': '缺少必要参数'}), 400
    
    # 检查用户名或邮箱是否已存在
    query = "SELECT * FROM users WHERE username = %s OR email = %s"
    result = db.fetch_query(query, (username, email))
    
    if result:
        return jsonify({'error': '用户名或邮箱已存在'}), 400
    
    # 插入新用户
    hashed_password = hash_password(password)
    insert_query = "INSERT INTO users (username, password, email) VALUES (%s, %s, %s)"
    if db.execute_query(insert_query, (username, hashed_password, email)):
        return jsonify({'message': '注册成功'}), 201
    else:
        return jsonify({'error': '注册失败'}), 500

# 用户登录接口
@app.route('/api/users/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    
    if not all([username, password]):
        return jsonify({'error': '缺少必要参数'}), 400
    
    # 检查用户
    hashed_password = hash_password(password)
    query = "SELECT id, username, email FROM users WHERE username = %s AND password = %s"
    result = db.fetch_query(query, (username, hashed_password))
    
    if result:
        user_id, username, email = result[0]
        return jsonify({
            'message': '登录成功',
            'user': {
                'id': user_id,
                'username': username,
                'email': email
            }
        }), 200
    else:
        return jsonify({'error': '用户名或密码错误'}), 401

# 数据录入接口
@app.route('/api/data/entry', methods=['POST'])
def data_entry():
    data = request.get_json()
    user_id = data.get('user_id')
    data_type = data.get('data_type')
    data_content = data.get('data_content')
    
    if not all([user_id, data_type, data_content]):
        return jsonify({'error': '缺少必要参数'}), 400
    
    # 检查用户是否存在
    user_query = "SELECT id FROM users WHERE id = %s"
    user_result = db.fetch_query(user_query, (user_id,))
    
    if not user_result:
        return jsonify({'error': '用户不存在'}), 404
    
    # 插入数据
    insert_query = "INSERT INTO data_entries (user_id, data_type, data_content) VALUES (%s, %s, %s)"
    if db.execute_query(insert_query, (user_id, data_type, json.dumps(data_content))):
        return jsonify({'message': '数据录入成功'}), 201
    else:
        return jsonify({'error': '数据录入失败'}), 500

# 获取用户数据接口
@app.route('/api/data/entries/<int:user_id>', methods=['GET'])
def get_user_data(user_id):
    # 检查用户是否存在
    user_query = "SELECT id FROM users WHERE id = %s"
    user_result = db.fetch_query(user_query, (user_id,))
    
    if not user_result:
        return jsonify({'error': '用户不存在'}), 404
    
    # 获取用户数据
    data_query = "SELECT id, data_type, data_content, created_at FROM data_entries WHERE user_id = %s ORDER BY created_at DESC"
    data_result = db.fetch_query(data_query, (user_id,))
    
    entries = []
    for entry in data_result:
        entries.append({
            'id': entry[0],
            'data_type': entry[1],
            'data_content': json.loads(entry[2]),
            'created_at': entry[3].strftime('%Y-%m-%d %H:%M:%S')
        })
    
    return jsonify({'entries': entries}), 200

# 产品评分接口
@app.route('/api/ratings', methods=['POST'])
def rate_product():
    data = request.get_json()
    user_id = data.get('user_id')
    product_id = data.get('product_id')
    rating = data.get('rating')
    
    if not all([user_id, product_id, rating]):
        return jsonify({'error': '缺少必要参数'}), 400
    
    # 检查评分是否在有效范围内
    if not (1 <= rating <= 5):
        return jsonify({'error': '评分必须在1-5之间'}), 400
    
    # 检查用户和产品是否存在
    user_query = "SELECT id FROM users WHERE id = %s"
    user_result = db.fetch_query(user_query, (user_id,))
    
    product_query = "SELECT id FROM products WHERE id = %s"
    product_result = db.fetch_query(product_query, (product_id,))
    
    if not user_result:
        return jsonify({'error': '用户不存在'}), 404
    
    if not product_result:
        return jsonify({'error': '产品不存在'}), 404
    
    # 插入或更新评分
    upsert_query = """
    INSERT INTO ratings (user_id, product_id, rating) 
    VALUES (%s, %s, %s) 
    ON DUPLICATE KEY UPDATE rating = %s
    """
    
    if db.execute_query(upsert_query, (user_id, product_id, rating, rating)):
        return jsonify({'message': '评分成功'}), 201
    else:
        return jsonify({'error': '评分失败'}), 500

# 获取推荐接口
@app.route('/api/recommendations/<int:user_id>', methods=['GET'])
def get_recommendations(user_id):
    # 检查用户是否存在
    user_query = "SELECT id FROM users WHERE id = %s"
    user_result = db.fetch_query(user_query, (user_id,))
    
    if not user_result:
        return jsonify({'error': '用户不存在'}), 404
    
    # 获取推荐
    recommendations = recommendation_system.get_recommendations(user_id)
    
    # 格式化推荐结果
    formatted_recommendations = []
    for product in recommendations:
        formatted_recommendations.append({
            'id': product[0],
            'name': product[1],
            'description': product[2],
            'category': product[3],
            'price': float(product[4]) if product[4] else None
        })
    
    return jsonify({'recommendations': formatted_recommendations}), 200

# 获取网络接口信息
@app.route('/api/network/interfaces', methods=['GET'])
def get_network_interfaces():
    # 在实际应用中，这里可以调用系统命令获取网络接口信息
    # 这里返回配置文件中的网络接口信息作为示例
    return jsonify({
        'lan_interface': NETWORK_CONFIG['lan_interface'],
        'wan_interface': NETWORK_CONFIG['wan_interface'],
        'lan_ip_range': NETWORK_CONFIG['lan_ip_range'],
        'wan_ip_range': NETWORK_CONFIG['wan_ip_range']
    }), 200

# 添加产品接口（用于测试推荐系统）
@app.route('/api/products', methods=['POST'])
def add_product():
    data = request.get_json()
    name = data.get('name')
    description = data.get('description')
    category = data.get('category')
    price = data.get('price')
    
    if not name:
        return jsonify({'error': '产品名称不能为空'}), 400
    
    insert_query = "INSERT INTO products (name, description, category, price) VALUES (%s, %s, %s, %s)"
    if db.execute_query(insert_query, (name, description, category, price)):
        return jsonify({'message': '产品添加成功'}), 201
    else:
        return jsonify({'error': '产品添加失败'}), 500

# 获取所有产品接口
@app.route('/api/products', methods=['GET'])
def get_products():
    query = "SELECT id, name, description, category, price FROM products"
    products = db.fetch_query(query)
    
    formatted_products = []
    for product in products:
        formatted_products.append({
            'id': product[0],
            'name': product[1],
            'description': product[2],
            'category': product[3],
            'price': float(product[4]) if product[4] else None
        })
    
    return jsonify({'products': formatted_products}), 200

if __name__ == '__main__':
    # 创建数据库表（如果不存在）
    db.create_tables()
    
    # 启动Flask应用
    app.run(
        host=SERVER_CONFIG['host'],
        port=SERVER_CONFIG['port'],
        debug=SERVER_CONFIG['debug']
    )