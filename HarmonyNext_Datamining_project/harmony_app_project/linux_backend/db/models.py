import mysql.connector
from mysql.connector import Error
from config.config import DATABASE_CONFIG

class Database:
    def __init__(self):
        self.connection = None
        self.cursor = None
        self.connect()
    
    def connect(self):
        try:
            self.connection = mysql.connector.connect(**DATABASE_CONFIG)
            if self.connection.is_connected():
                print("成功连接到数据库")
                self.cursor = self.connection.cursor()
        except Error as e:
            print(f"数据库连接错误: {e}")
    
    def disconnect(self):
        if self.connection.is_connected():
            self.cursor.close()
            self.connection.close()
            print("数据库连接已关闭")
    
    def create_tables(self):
        # 创建用户表
        user_table_query = """
        CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(50) NOT NULL UNIQUE,
            password VARCHAR(255) NOT NULL,
            email VARCHAR(100) NOT NULL UNIQUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """
        
        # 创建产品表
        product_table_query = """
        CREATE TABLE IF NOT EXISTS products (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            description TEXT,
            category VARCHAR(50),
            price DECIMAL(10, 2),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """
        
        # 创建评分表 (用于推荐系统)
        rating_table_query = """
        CREATE TABLE IF NOT EXISTS ratings (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            product_id INT NOT NULL,
            rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
            UNIQUE KEY unique_user_product (user_id, product_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """
        
        # 创建数据录入表
        data_entry_table_query = """
        CREATE TABLE IF NOT EXISTS data_entries (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            data_type VARCHAR(50) NOT NULL,
            data_content JSON NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """
        
        try:
            # 执行建表语句
            self.cursor.execute(user_table_query)
            self.cursor.execute(product_table_query)
            self.cursor.execute(rating_table_query)
            self.cursor.execute(data_entry_table_query)
            self.connection.commit()
            print("数据库表创建成功")
        except Error as e:
            print(f"创建数据库表错误: {e}")
            self.connection.rollback()
    
    # 通用查询方法
    def execute_query(self, query, params=None):
        try:
            if params:
                self.cursor.execute(query, params)
            else:
                self.cursor.execute(query)
            self.connection.commit()
            return True
        except Error as e:
            print(f"执行查询错误: {e}")
            self.connection.rollback()
            return False
    
    # 通用查询并返回结果的方法
    def fetch_query(self, query, params=None):
        try:
            if params:
                self.cursor.execute(query, params)
            else:
                self.cursor.execute(query)
            result = self.cursor.fetchall()
            return result
        except Error as e:
            print(f"执行查询错误: {e}")
            return None

# 初始化数据库连接
db = Database()

# 如果需要创建表，可以调用此方法
# db.create_tables()