---
name: api-docs
description: 自动生成 API 文档，支持 OpenAPI/Swagger 格式
allowed-tools: Read, Grep, Glob, Write
scope:
  paths:
    - "**/*.{ts,tsx,js,jsx}"
    - "**/api/**"
---

# API 文档生成 Skill

自动分析 API 代码并生成标准化文档。

## 使用场景

- 接口文档缺失
- 前后端对接
- API 版本管理

## 支持的框架

- Next.js API Routes
- Express.js
- Fastify
- NestJS
- Hono

## 文档内容

### 接口信息
- 路径和方法
- 请求参数
- 响应格式
- 错误码说明

### 类型定义
- 请求体类型
- 响应体类型
- 枚举值说明

## 执行流程

1. 扫描 API 路由文件
2. 分析类型定义
3. 提取参数和返回值
4. 生成文档结构

## 输出格式

```markdown
## API 文档

### GET /api/users
获取用户列表

**Query 参数：**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | number | 否 | 页码，默认 1 |
| limit | number | 否 | 每页数量，默认 10 |

**响应：**
```json
{
  "data": [
    {
      "id": "string",
      "name": "string",
      "email": "string"
    }
  ],
  "pagination": {
    "total": "number",
    "page": "number",
    "limit": "number"
  }
}
```

**错误码：**
| 状态码 | 说明 |
|--------|------|
| 400 | 参数错误 |
| 401 | 未认证 |
| 500 | 服务器错误 |
```
