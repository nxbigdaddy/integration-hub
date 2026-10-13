# 企业多系统连接中枢 - Node.js 核心实现

## 项目结构

```
integration-hub-node/
├── package.json          # 依赖配置
├── jest.config.cjs       # Jest 测试配置
├── src/
│   ├── app.js            # Express 应用入口
│   ├── router/           # 路由引擎模块
│   │   ├── RouteRule.js
│   │   └── RouteEngine.js
│   ├── transformer/      # 数据转换引擎模块
│   │   ├── MappingRule.js
│   │   └── DataTransformer.js
│   └── validator/        # 数据校验引擎模块
│       ├── ValidationRule.js
│       └── ValidationEngine.js
└── test/
    ├── app.test.js
    ├── router/
    │   └── RouteEngine.test.js
    ├── transformer/
    │   └── DataTransformer.test.js
    └── validator/
        └── ValidationEngine.test.js
```

## 快速开始

```bash
# 安装依赖
npm install

# 运行测试 (覆盖率 ≥ 90%)
npm test

# 启动服务
npm start
```

## API 接口

### 1. 路由解析
```bash
curl -X POST http://localhost:3000/api/v1/route \
  -H "Content-Type: application/json" \
  -d '{"path": "/api/v1/users", "headers": {}}'
```

### 2. 数据转换
```bash
curl -X POST http://localhost:3000/api/v1/transform \
  -H "Content-Type: application/json" \
  -d '{
    "source": "{\"name\": \"test\"}",
    "rules": [{"sourcePath": "$.name", "targetPath": "$.user", "transformExpression": "UPPER"}]
  }'
```

### 3. 数据校验
```bash
curl -X POST http://localhost:3000/api/v1/validate \
  -H "Content-Type: application/json" \
  -d '{
    "data": "{\"email\": \"test@test.com\"}",
    "rules": [{"fieldPath": "$.email", "type": "REQUIRED", "required": true}]
  }'
```

## 测试结果

```
----------------------|---------|----------|---------|---------|
File                  | % Stmts | % Branch | % Funcs | % Lines |
----------------------|---------|----------|---------|---------|
All files             |   92.04 |    85.22 |     100 |    94.8 |
 router               |    91.3 |       85 |     100 |   95.23 |
 transformer          |   87.17 |    79.31 |     100 |    90.9 |
 validator            |     100 |    89.74 |     100 |     100 |
----------------------|---------|----------|---------|---------|
Test Suites: 4 passed, 4 total
Tests:       25 passed, 25 total
```

<COMPLETE>