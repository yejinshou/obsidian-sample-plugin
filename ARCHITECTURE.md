# Flutter混合插件架构图

```
┌─────────────────────────────────────────────────────────────┐
│                        Obsidian 应用                         │
│  ┌───────────────────────────────────────────────────────┐  │
│  │         Flutter Hybrid Plugin (TypeScript)            │  │
│  │                                                       │  │
│  │  ┌─────────────────────────────────────────────┐     │  │
│  │  │  flutter-main.ts                           │     │  │
│  │  │  • Plugin lifecycle (onload/onunload)      │     │  │
│  │  │  • Register view, commands, settings       │     │  │
│  │  │  • Message handler                         │     │  │
│  │  └─────────────────┬───────────────────────────┘     │  │
│  │                    │                                 │  │
│  │                    │ postMessage                     │  │
│  │                    │ (双向通信)                       │  │
│  │                    ▼                                 │  │
│  │  ┌─────────────────────────────────────────────┐     │  │
│  │  │          ItemView (iframe container)       │     │  │
│  │  │                                           │     │  │
│  │  │  ┌─────────────────────────────────┐      │     │  │
│  │  │  │   Flutter Web App (iframe)      │      │     │  │
│  │  │  │                                 │      │     │  │
│  │  │  │  ┌───────────────────────────┐  │      │     │  │
│  │  │  │  │  main.dart                │  │      │     │  │
│  │  │  │  │  • UI rendering           │  │      │     │  │
│  │  │  │  │  • Message listener       │  │      │     │  │
│  │  │  │  │  • Send messages          │  │      │     │  │
│  │  │  │  └───────────────────────────┘  │      │     │  │
│  │  │  │                                 │      │     │  │
│  │  │  │  ┌───────────────────────────┐  │      │     │  │
│  │  │  │  │  settings_page.dart       │  │      │     │  │
│  │  │  │  │  • Settings UI            │  │      │     │  │
│  │  │  │  │  • Load/save settings     │  │      │     │  │
│  │  │  │  └───────────────────────────┘  │      │     │  │
│  │  │  └─────────────────────────────────┘      │     │  │
│  │  └─────────────────────────────────────────────┘     │  │
│  │                                                       │  │
│  │  ┌─────────────────────────────────────────────┐     │  │
│  │  │  PluginSettingTab                          │     │  │
│  │  │  • Native Obsidian settings UI             │     │  │
│  │  │  • Syncs with Flutter settings             │     │  │
│  │  └─────────────────────────────────────────────┘     │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 通信流程

### Obsidian → Flutter
```
TypeScript                           Flutter
─────────────                       ─────────
iframe.contentWindow.postMessage    window.onMessage.listen
    │                                   │
    └──► {                              │
           type: 'obsidian-to-flutter'  │
           message: 'Hello'              │
         } ───────────────────────────► │
                                        │
                                    处理消息
                                    更新UI
```

### Flutter → Obsidian  
```
Flutter                              TypeScript
─────────                           ─────────────
html.window.parent?.postMessage     window.addEventListener('message')
    │                                   │
    └──► {                              │
           type: 'flutter-to-obsidian'  │
           message: 'Hi'                 │
         } ───────────────────────────► │
                                        │
                                    处理消息
                                    执行操作
```

## 消息类型

| 类型 | 方向 | 用途 |
|------|------|------|
| `flutter-ready` | Flutter → Obsidian | Flutter UI加载完成 |
| `obsidian-to-flutter` | Obsidian → Flutter | 发送消息到Flutter |
| `flutter-to-obsidian` | Flutter → Obsidian | 发送消息到Obsidian |
| `flutter-request-settings` | Flutter → Obsidian | 请求获取设置 |
| `obsidian-settings` | Obsidian → Flutter | 发送设置数据 |
| `flutter-save-settings` | Flutter → Obsidian | 保存设置 |

## 构建流程

```
源代码                  编译                    输出
───────────            ─────                  ─────

flutter_ui/
├── lib/
│   ├── main.dart ───► flutter build web ───► flutter_ui/build/web/
│   └── settings.dart                          ├── index.html
└── pubspec.yaml                               ├── main.dart.js
                                               ├── flutter.js
                                               └── assets/

flutter-main.ts ─────► npm run build ────────► main.js (CommonJS)
```

## 部署流程

```
1. 编译Flutter Web
   cd flutter_ui && flutter build web
   
2. 编译TypeScript  
   npm run build
   
3. 复制到Obsidian
   <vault>/.obsidian/plugins/flutter-hybrid-plugin/
   ├── main.js
   ├── manifest.json
   └── flutter_ui/build/web/
       ├── index.html
       └── ...

4. 在Obsidian中启用插件
```

## 为什么选择混合架构？

### ✅ 优势

1. **兼容性好**
   - TypeScript核心完全兼容Obsidian Plugin API
   - 避免Flutter Web到CommonJS的转换问题

2. **开发效率高**
   - Flutter提供丰富的UI组件
   - TypeScript处理Obsidian交互
   - 各自独立开发和测试

3. **灵活性强**
   - 可以轻松添加新的Flutter UI页面
   - 不影响Obsidian核心功能
   - 易于维护和升级

4. **性能合理**
   - Flutter UI按需加载（iframe）
   - TypeScript核心轻量（几KB）
   - 通信开销最小（postMessage）

### ⚠️ 注意事项

1. **首次加载**
   - Flutter Web首次加载需要下载引擎（约1-2MB）
   - 后续访问会使用浏览器缓存

2. **iframe限制**
   - 某些Obsidian API无法直接在Flutter中使用
   - 需要通过消息传递间接访问

3. **调试**
   - TypeScript和Flutter需要分别调试
   - 使用浏览器开发者工具查看两者的控制台

## 扩展开发示例

### 添加新的消息类型

**在TypeScript中:**
```typescript
case 'your-custom-type':
  // 处理自定义消息
  const data = event.data;
  console.log('Received:', data);
  break;
```

**在Flutter中:**
```dart
html.window.parent?.postMessage({
  'type': 'your-custom-type',
  'customData': yourData
}, '*');
```

### 添加新的Flutter页面

1. 创建新的Dart文件 `flutter_ui/lib/new_page.dart`
2. 在 `main.dart` 中添加导航逻辑
3. 通过消息通知Obsidian切换页面

## 总结

这个混合架构结合了：
- **TypeScript**: Obsidian原生集成、轻量级核心
- **Flutter**: 现代UI、丰富组件、跨平台
- **postMessage**: 简单高效的通信机制

适合需要复杂UI但又想保持Obsidian原生体验的插件开发。
