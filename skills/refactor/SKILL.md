---
name: refactor
description: 安全重构代码，保持功能不变的同时改善结构
allowed-tools: Read, Grep, Glob, LSP, Edit
scope:
  paths:
    - "**/*.{ts,tsx,js,jsx}"
---

# 代码重构 Skill

在保持外部行为不变的前提下，改善代码内部结构。

## 使用场景

- 消除代码坏味道
- 提取公共逻辑
- 简化复杂函数
- 改善可读性

## 重构原则

1. **小步前进**：每次只做一个小的改动
2. **保持测试**：重构前后测试必须通过
3. **不改行为**：只改结构，不改功能
4. **及时提交**：每完成一步就提交

## 常见重构模式

### 提取函数
```typescript
// Before
function processOrder(order) {
  // 200行代码...
}

// After
function validateOrder(order) { ... }
function calculateTotal(order) { ... }
function saveOrder(order) { ... }
function processOrder(order) {
  validateOrder(order);
  const total = calculateTotal(order);
  saveOrder(order, total);
}
```

### 提取组件
```tsx
// Before
function UserCard({ user }) {
  return (
    <div className="card">
      <img src={user.avatar} />
      <h3>{user.name}</h3>
      <p>{user.email}</p>
      <button onClick={() => follow(user.id)}>Follow</button>
    </div>
  );
}

// After
function UserAvatar({ src, alt }) { ... }
function UserInfo({ name, email }) { ... }
function FollowButton({ userId, onFollow }) { ... }

function UserCard({ user }) {
  return (
    <div className="card">
      <UserAvatar src={user.avatar} alt={user.name} />
      <UserInfo name={user.name} email={user.email} />
      <FollowButton userId={user.id} onFollow={follow} />
    </div>
  );
}
```

### 条件逻辑简化
```typescript
// Before（嵌套过深）
if (user) {
  if (user.isActive) {
    if (user.hasPermission) {
      // do something
    }
  }
}

// After（卫语句）
if (!user) return;
if (!user.isActive) return;
if (!user.hasPermission) return;
// do something
```

## 执行流程

1. 分析目标代码
2. 识别重构机会
3. 制定重构计划
4. 逐步执行重构
5. 验证行为不变

## 输出格式

```markdown
## 重构报告

### 当前问题
[识别到的代码坏味道]

### 重构方案
[采用的重构模式]

### 改动文件
[文件列表和改动说明]

### 验证检查
- [ ] 功能测试通过
- [ ] 类型检查通过
- [ ] 无新增警告
```
