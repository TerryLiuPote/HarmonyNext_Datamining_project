# 服务器配置
SERVER_CONFIG = {
    'host': '0.0.0.0',  # 监听所有网络接口
    'port': 8080,       # 服务端口
    'debug': True       # 调试模式
}

# 数据库配置
DATABASE_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'password': 'password',
    'database': 'harmony_app_db',
    'charset': 'utf8mb4'
}

# 网络接口配置
NETWORK_CONFIG = {
    'lan_interface': 'eth0',    # LAN网络接口
    'wan_interface': 'eth1',    # WAN网络接口
    'lan_ip_range': '192.168.1.0/24',  # LAN IP范围
    'wan_ip_range': '10.0.0.0/24'       # WAN IP范围
}

# 推荐系统配置
RECOMMENDATION_CONFIG = {
    'algorithm': 'collaborative_filtering',  # 推荐算法类型
    'similarity_threshold': 0.7,              # 相似度阈值
    'max_recommendations': 10                # 最大推荐数量
}