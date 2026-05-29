---
name: performance-optimize
description: 性能分析和优化，识别瓶颈并提供改进方案
allowed-tools: Read, Grep, Glob, LSP, Bash
scope:
  paths:
    - "**/*.{ts,tsx,js,jsx}"
---

# 性能优化 Skill

分析代码性能问题，提供优化建议和实现方案。

## 使用场景

- 页面加载缓慢
- 渲染性能问题
- 内存占用过高
- 接口响应慢

## 分析维度

### 1. React 渲染性能
- 不必要的重渲染
- 缺少 memo/useMemo/useCallback
- 大列表未虚拟化
- Context 过度使用

### 2. 网络性能
- 请求瀑布流
- 资源未压缩
- 缓存策略缺失
- 大文件上传

### 3. 内存问题
- 事件监听器未清理
- 定时器未清理
- 闭包引用过大对象
- 组件卸载后更新状态

### 4. 打包体积
- 未使用的依赖
- 重复依赖
- Tree-shaking 失效
- 动态导入缺失

## 常见优化方案

### React 组件优化
```typescript
// 使用 React.memo 避免不必要渲染
const ExpensiveComponent = React.memo(({ data }) => {
  return <div>{/* 复杂渲染 */}</div>;
});

// 使用 useMemo 缓存计算结果
const sortedList = useMemo(() => {
  return list.sort((a, b) => a.value - b.value);
}, [list]);

// 使用 useCallback 缓存函数引用
const handleClick = useCallback(() => {
  doSomething(id);
}, [id]);
```

### 列表虚拟化
```typescript
// 大列表使用虚拟滚动
import { FixedSizeList } from 'react-window';

function VirtualList({ items }) {
  return (
    <FixedSizeList
      height={600}
      itemCount={items.length}
      itemSize={50}
      width="100%"
    >
      {({ index, style }) => (
        <div style={style}>{items[index].name}</div>
      )}
    </FixedSizeList>
  );
}
```

### 代码分割
```typescript
// 路由级代码分割
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings = lazy(() => import('./pages/Settings'));

// 组件级代码分割
const HeavyChart = lazy(() => import('./HeavyChart'));
```

## 执行流程

1. 识别性能瓶颈
2. 分析根本原因
3. 提供优化方案
4. 实现优化代码
5. 验证优化效果

## 输出格式

```markdown
## 性能优化报告

### 性能问题
[识别到的瓶颈]

### 影响程度
[对用户体验的影响]

### 优化方案
[具体优化措施]

### 预期效果
[优化后的预期提升]
```
