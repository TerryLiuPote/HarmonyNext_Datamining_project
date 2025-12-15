# 鸿蒙应用与Linux服务端项目

## 项目概述

这是一个完整的手机端原生鸿蒙应用与Linux服务端的整合项目，包含前端界面、数据库、推荐系统、数据录入功能以及LAN/WAN网络接口支持。

## 项目结构

```
harmony_app_project/
├── harmony_frontend/          # 鸿蒙前端应用
│   ├── MainPage.ets          # 登录页面
│   ├── RegisterPage.ets      # 注册页面
│   ├── HomePage.ets          # 主页（推荐内容）
│   ├── DataEntryPage.ets     # 数据录入页面
│   ├── MyDataPage.ets        # 我的数据页面
│   └── config.json           # 应用配置文件
└── linux_backend/            # Linux服务端
    ├── api/                  # API接口模块
    │   └── app.py            # Flask API应用
    ├── db/                   # 数据库模块
    │   └── models.py         # 数据库模型
    ├── recommendation_system/# 推荐系统模块
    │   └── recommendation.py # 推荐算法实现
    └── config/               # 配置模块
        └── config.py         # 服务端配置
```

## 功能特性

### 前端功能
- 用户认证（登录/注册）
- 数据录入（支持文本、数字、JSON格式）
- 数据查看与管理
- 个性化推荐系统
- 网络接口信息展示

### 服务端功能
- RESTful API接口
- MySQL数据库连接与管理
- 基于协同过滤的推荐算法
- 数据录入与存储
- LAN/WAN网络接口支持

## 技术栈

### 前端
- 鸿蒙原生应用（HarmonyOS）
- ArkTS编程语言

### 服务端
- Python 3.x
- Flask框架
- MySQL数据库
- 协同过滤推荐算法

## 部署说明

### Linux服务端部署

1. 安装依赖：
   ```bash
   pip install flask mysql-connector-python
   ```

2. 配置数据库：
   - 修改 `linux_backend/config/config.py` 中的数据库连接信息
   - 创建数据库和表：
     ```bash
     python linux_backend/db/models.py
     ```

3. 启动服务：
   ```bash
   python linux_backend/api/app.py
   ```

### 鸿蒙前端应用部署

1. 使用DevEco Studio打开 `harmony_frontend` 目录
2. 配置签名和设备
3. 编译并运行应用

## API接口说明

### 用户认证
- `POST /api/users/register` - 用户注册
- `POST /api/users/login` - 用户登录

### 数据管理
- `POST /api/data/entry` - 数据录入
- `GET /api/data/entries/<user_id>` - 获取用户数据

### 推荐系统
- `GET /api/recommendations/<user_id>` - 获取个性化推荐

### 网络信息
- `GET /api/network/lan` - 获取LAN网络信息
- `GET /api/network/wan` - 获取WAN网络信息

## 网络接口配置

### LAN网络接口
- 默认使用192.168.1.x子网
- 支持自动获取IP地址

### WAN网络接口
- 支持DHCP自动配置
- 可手动配置静态IP地址

## 使用指南

1. 在手机上安装鸿蒙应用
2. 注册新用户或使用已有账号登录
3. 使用数据录入功能添加数据
4. 在主页查看个性化推荐内容
5. 在我的数据页面查看和管理录入的数据

## 注意事项

- 确保手机和Linux服务端在同一局域网内
- 首次使用需要初始化数据库
- 推荐功能需要足够的用户数据才能生效

## 未来扩展

- 添加更多数据类型支持
- 优化推荐算法
- 增加数据可视化功能
- 支持云同步
- 添加更多网络接口配置选项