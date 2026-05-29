---
name: ui-review
description: UI 代码审查，检查可访问性、响应式设计和一致性
allowed-tools: Read, Grep, Glob, LSP
scope:
  paths:
    - "**/*.{tsx,jsx}"
    - "**/*.css"
    - "**/*.scss"
---

# UI 审查 Skill

审查前端 UI 代码，确保质量、可访问性和一致性。

## 使用场景

- 组件开发自检
- UI/UX 评审
- 可访问性合规

## 审查维度

### 1. 可访问性 (a11y)
- 语义化 HTML 标签
- ARIA 属性完整性
- 键盘导航支持
- 颜色对比度
- 屏幕阅读器兼容

### 2. 响应式设计
- 移动端适配
- 断点设置合理
- 触摸目标大小
- 字体可缩放

### 3. 一致性
- 命名规范统一
- 样式命名约定（BEM/CSS Modules）
- 组件 API 一致
- 颜色/字体使用设计系统

### 4. 性能
- 图片优化
- 动画性能
- 条件渲染优化
- 大列表虚拟化

## 常见问题

### 可访问性问题
```tsx
// ❌ Bad
<div onClick={handleClick}>Click me</div>
<img src="avatar.png" />

// ✅ Good
<button onClick={handleClick}>Click me</button>
<img src="avatar.png" alt="User avatar" />
```

### 响应式问题
```css
/* ❌ Bad */
.container {
  width: 1200px;
}

/* ✅ Good */
.container {
  width: 100%;
  max-width: 1200px;
}
```

## 执行流程

1. 读取目标组件代码
2. 按维度逐项检查
3. 标记问题和严重程度
4. 提供修复建议

## 输出格式

```markdown
## UI 审查报告

### 🔴 严重问题（必须修复）
- [组件名] 可访问性问题：缺少 alt 属性

### 🟡 建议改进（推荐修复）
- [组件名] 响应式问题：固定宽度

### 🟢 优点
- 组件结构清晰
- 命名规范统一
```
