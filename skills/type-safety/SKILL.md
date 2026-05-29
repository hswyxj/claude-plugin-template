---
name: type-safety
description: 检查和改进 TypeScript 类型安全
allowed-tools: Read, Grep, Glob, LSP
scope:
  paths:
    - "**/*.{ts,tsx}"
---

# 类型安全 Skill

检查 TypeScript 代码的类型安全问题并提供修复方案。

## 使用场景

- 消除 any 类型
- 改进类型定义
- 增强类型推断

## 检查维度

### 1. any 使用
- 显式 any 类型
- 隐式 any（未标注返回值）
- 类型断言滥用

### 2. 类型完整性
- 缺失的属性类型
- 可选属性处理
- 联合类型覆盖

### 3. 类型守卫
- 空值检查
- 类型收窄
- 不可达代码

## 常见修复

### 消除 any
```typescript
// ❌ Bad
function processData(data: any) {
  return data.items.map((item: any) => item.name);
}

// ✅ Good
interface DataItem {
  name: string;
  value: number;
}

interface Data {
  items: DataItem[];
}

function processData(data: Data) {
  return data.items.map((item) => item.name);
}
```

### 使用类型守卫
```typescript
// ❌ Bad
function getUserName(user: User | null) {
  if (user) {
    return user.name;
  }
  return 'Unknown';
}

// ✅ Good
function getUserName(user: User | null) {
  if (user === null) {
    return 'Unknown';
  }
  return user.name;
}
```

### 使用 discriminated unions
```typescript
// ❌ Bad
type ApiResponse = {
  data?: any;
  error?: string;
};

// ✅ Good
type ApiResponse =
  | { success: true; data: UserData }
  | { success: false; error: string };
```

## 执行流程

1. 扫描代码中的 any 使用
2. 分析类型定义完整性
3. 识别类型不安全操作
4. 提供具体修复方案

## 输出格式

```markdown
## 类型安全报告

### 🔴 严重问题（必须修复）
- [文件:行号] 使用了 any 类型

### 🟡 建议改进（推荐修复）
- [文件:行号] 缺少类型定义

### 修复方案
[具体的代码修改建议]
```
