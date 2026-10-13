# 企业多系统连接中枢 - ASP 完整版

## 项目结构

```
integration-hub-asp/
├── css/
│   └── style.css              # 统一样式
├── inc/
│   ├── conn.asp               # 数据库连接 + 公共函数
│   ├── engine.asp             # 集成引擎核心 (路由/转换/校验/日志/HTTP)
│   └── queue.asp              # 消息队列模拟
├── api/
│   ├── route.asp              # 路由 API 端点
│   ├── transform.asp          # 数据转换 API
│   ├── validate.asp           # 数据校验 API
│   └── webhook.asp            # Webhook 接收端点
├── db/
│   └── init.sql               # SQL Server 初始化脚本
├── login.asp                  # 登录页
├── logout.asp                 # 退出
├── index.asp                  # 主控制台 (8 模块)
├── system_edit.asp            # 系统增删改
├── system_action.asp          # 系统状态切换
├── api_edit.asp               # API 注册/编辑
├── mapping_edit.asp           # 数据映射管理
├── mapping_action.asp         # 映射状态切换
├── route_edit.asp             # 路由规则管理
├── settings_save.asp          # 设置保存
├── sync.asp                   # 数据同步执行
├── queue_process.asp          # 队列处理引擎
├── queue_manage.asp           # 队列管理界面
├── test_api.asp               # API 测试页面
└── README.md                  # 本文档
```

## 已实现功能

### 1. 管理界面 (100%)
- ✅ 系统管理 (CRUD + 状态切换)
- ✅ API 管理 (注册 + 编辑)
- ✅ 数据映射 (规则配置)
- ✅ 路由配置 (规则管理)
- ✅ 监控中心 (统计展示)
- ✅ 日志审计 (操作日志)
- ✅ 系统设置 (安全配置)

### 2. 集成引擎 (100%)
- ✅ 动态路由引擎 (前缀/精确/Header 匹配)
- ✅ 数据转换引擎 (字段映射 + UPPER/LOWER/TRIM/prefix)
- ✅ 数据校验引擎 (REQUIRED/REGEX/EMAIL/PHONE/MIN_LENGTH/MAX_LENGTH)
- ✅ HTTP 客户端 (GET/POST 调用外部系统)
- ✅ 日志记录器 (写入数据库)

### 3. 消息队列 (100%)
- ✅ 消息入队 (Enqueue)
- ✅ 消息出队 (Dequeue)
- ✅ 状态管理 (pending/processing/completed/failed)
- ✅ 失败重试机制
- ✅ 队列统计

### 4. 数据同步 (100%)
- ✅ 从源系统拉取数据 (HTTP GET)
- ✅ 数据校验 (拦截非法数据)
- ✅ 数据转换 (字段映射)
- ✅ 推送到目标系统 (HTTP POST)
- ✅ 同步任务管理 (手动/定时)

### 5. API 端点
| 端点 | 功能 |
|------|------|
| `/api/route.asp?path=/xxx` | 路由匹配 |
| `/api/transform.asp` | 数据转换 |
| `/api/validate.asp` | 数据校验 |
| `/api/webhook.asp?system=xxx` | 接收外部推送 |

## 部署步骤

### 1. 环境要求
- Windows Server 2012 R2+
- IIS 8.0+
- SQL Server 2012+
- ASP 3.0

### 2. IIS 配置
1. 添加网站，物理路径指向项目目录
2. 应用程序池: `.NET Framework 4.0` (经典模式)
3. 启用 ASP: 服务器管理器 → Web 服务器 → 应用程序开发 → ASP

### 3. 数据库
```bash
sqlcmd -S .\SQLEXPRESS -i db\init.sql
```
修改 `inc/conn.asp` 连接字符串。

### 4. 访问
```
http://localhost/login.asp
账号: admin / admin123
```

## 使用示例

### 测试路由
访问 `test_api.asp` 或调用:
```
GET /api/route.asp?path=/api/v1/orders
```

### 测试转换
```
POST /api/transform.asp
source={"id": "abc", "name": "test"}
rules=$.id|$.user_id|UPPER;$.name|$.full_name
```

### 测试校验
```
POST /api/validate.asp
data={"email": "test@example.com", "phone": "13800138000"}
rules=$.email|EMAIL|;$.phone|PHONE|
```

### 执行同步
访问 `sync.asp` 创建同步任务，点击"执行"按钮。

### 队列处理
```
GET /queue_process.asp?queue=default&count=10
```