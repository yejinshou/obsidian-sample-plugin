# Obsidian Flutter Hybrid Plugin

一个混合架构的Obsidian插件：TypeScript核心 + Flutter Web UI

## 项目架构

### 架构说明
- **核心插件**: TypeScript (flutter-main.ts) - 使用Obsidian Plugin API
- **UI层**: Flutter Web - 提供现代化的用户界面
- **通信机制**: postMessage API 实现双向通信

### 文件结构
```
obsidian-sample-plugin/
├── flutter-main.ts              # TypeScript插件核心
├── flutter_ui/                  # Flutter Web应用
│   ├── pubspec.yaml            # Flutter依赖配置
│   ├── lib/
│   │   ├── main.dart           # Flutter主应用
│   │   └── settings_page.dart  # 设置页面
│   └── build/web/              # 编译输出（生成后）
├── manifest.json               # 插件清单
└── package.json               # npm依赖
```

## 功能特性

### 1. 双向通信
- Obsidian → Flutter: 发送消息和设置数据
- Flutter → Obsidian: 发送用户输入和操作事件

### 2. 设置界面
- 启用/禁用通知
- API密钥输入
- 刷新间隔滑块（1-60秒）

### 3. UI嵌入
- Flutter Web应用通过iframe嵌入到Obsidian
- 在右侧边栏显示
- 支持响应式布局

## TODO 清单

### Phase 1: 环境准备 ✅
- [x] 创建项目结构
- [x] 编写TypeScript插件代码
- [x] 编写Flutter UI代码
- [x] 配置通信机制

### Phase 2: 编译构建
- [ ] 安装Flutter SDK
- [ ] 编译Flutter Web应用
- [ ] 编译TypeScript插件
- [ ] 验证通信功能

### Phase 3: 测试部署
- [ ] 复制文件到Obsidian插件目录
- [ ] 在Obsidian中测试插件
- [ ] 验证双向通信
- [ ] 测试设置保存

### Phase 4: 优化完善
- [ ] 优化Flutter包大小
- [ ] 添加错误处理
- [ ] 改进UI设计
- [ ] 添加更多功能

## 编译步骤

### 前置要求
1. Node.js 18+ 
2. Flutter SDK 3.0+
3. Obsidian 0.15.0+

### 步骤1: 安装依赖

#### TypeScript依赖
```bash
npm install
```

#### Flutter依赖
```bash
cd flutter_ui
flutter pub get
```

### 步骤2: 编译Flutter Web应用

```bash
cd flutter_ui
flutter build web --release
```

编译输出位置: `flutter_ui/build/web/`

**重要提示**: 编译后的文件包括:
- `index.html` - 入口HTML
- `main.dart.js` - 编译后的Dart代码
- `flutter.js` - Flutter引擎
- `assets/` - 资源文件

### 步骤3: 编译TypeScript插件

```bash
# 开发模式（带source map）
npm run dev

# 或生产模式
npm run build
```

编译输出: `main.js`

**注意**: 如果使用Flutter版本，需要将入口点改为 `flutter-main.ts`:

修改 `esbuild.config.mjs`:
```javascript
entryPoints: ["flutter-main.ts"],  // 改为flutter-main.ts
```

然后运行:
```bash
npm run build
```

### 步骤4: 复制到Obsidian插件目录

#### 手动复制方式

1. 找到你的Obsidian保管库路径
2. 创建插件目录（如果不存在）:
```bash
mkdir -p <VaultPath>/.obsidian/plugins/flutter-hybrid-plugin
```

3. 复制必要文件:
```bash
# 复制编译后的主文件
cp main.js <VaultPath>/.obsidian/plugins/flutter-hybrid-plugin/

# 复制manifest
cp manifest.json <VaultPath>/.obsidian/plugins/flutter-hybrid-plugin/

# 复制Flutter Web编译输出
cp -r flutter_ui/build/web <VaultPath>/.obsidian/plugins/flutter-hybrid-plugin/flutter_ui/build/
```

#### 自动复制脚本

创建 `deploy.sh`:
```bash
#!/bin/bash

# 设置你的Obsidian保管库路径
VAULT_PATH="$HOME/Documents/ObsidianVault"
PLUGIN_DIR="$VAULT_PATH/.obsidian/plugins/flutter-hybrid-plugin"

# 创建插件目录
mkdir -p "$PLUGIN_DIR/flutter_ui/build"

# 编译Flutter
cd flutter_ui
flutter build web --release
cd ..

# 编译TypeScript
npm run build

# 复制文件
cp main.js "$PLUGIN_DIR/"
cp manifest.json "$PLUGIN_DIR/"
cp -r flutter_ui/build/web "$PLUGIN_DIR/flutter_ui/build/"

echo "部署完成到: $PLUGIN_DIR"
```

使用方法:
```bash
chmod +x deploy.sh
./deploy.sh
```

#### Windows批处理脚本

创建 `deploy.bat`:
```batch
@echo off
REM 设置你的Obsidian保管库路径
set VAULT_PATH=C:\Users\YourName\Documents\ObsidianVault
set PLUGIN_DIR=%VAULT_PATH%\.obsidian\plugins\flutter-hybrid-plugin

REM 创建插件目录
mkdir "%PLUGIN_DIR%\flutter_ui\build" 2>nul

REM 编译Flutter
cd flutter_ui
call flutter build web --release
cd ..

REM 编译TypeScript
call npm run build

REM 复制文件
copy main.js "%PLUGIN_DIR%\"
copy manifest.json "%PLUGIN_DIR%\"
xcopy /E /I /Y flutter_ui\build\web "%PLUGIN_DIR%\flutter_ui\build\web"

echo 部署完成到: %PLUGIN_DIR%
pause
```

### 步骤5: 在Obsidian中启用插件

1. 打开Obsidian
2. 进入 **设置 → 社区插件**
3. 确保"安全模式"已关闭
4. 点击"重新加载插件"
5. 在插件列表中找到"Flutter Hybrid Plugin"并启用

## 使用方法

### 打开Flutter UI
- 点击左侧功能区的仪表板图标
- 或使用命令面板: `Ctrl/Cmd + P` → 输入 "Open Flutter UI"

### 设置配置
- 进入 **设置 → Flutter Hybrid Plugin**
- 或在Flutter UI中点击设置按钮

### 测试通信
1. 打开Flutter UI
2. 在文本框中输入消息
3. 点击"Send to Obsidian"
4. 查看控制台输出验证消息已接收

## 通信协议

### Obsidian → Flutter

```typescript
// 发送消息
iframe.contentWindow.postMessage({
  type: 'obsidian-to-flutter',
  message: 'Hello from Obsidian'
}, '*');

// 发送设置
iframe.contentWindow.postMessage({
  type: 'obsidian-settings',
  enableNotifications: true,
  apiKey: 'xxx',
  refreshInterval: 5
}, '*');
```

### Flutter → Obsidian

```dart
// 发送消息
html.window.parent?.postMessage({
  'type': 'flutter-to-obsidian',
  'message': 'Hello from Flutter'
}, '*');

// 请求设置
html.window.parent?.postMessage({
  'type': 'flutter-request-settings'
}, '*');

// 保存设置
html.window.parent?.postMessage({
  'type': 'flutter-save-settings',
  'settings': {
    'enableNotifications': true,
    'apiKey': 'xxx',
    'refreshInterval': 5
  }
}, '*');
```

## 故障排除

### Flutter编译失败
```bash
# 清理并重新获取依赖
cd flutter_ui
flutter clean
flutter pub get
flutter build web --release
```

### 插件无法加载
1. 检查控制台错误信息 (Ctrl/Cmd + Shift + I)
2. 确认 `main.js` 和 `manifest.json` 在正确位置
3. 确认Flutter编译输出在 `flutter_ui/build/web/`

### iframe无法显示
1. 检查Flutter Web文件路径
2. 确认 `index.html` 存在于 `flutter_ui/build/web/`
3. 查看浏览器控制台的CORS错误

### 通信不工作
1. 打开浏览器开发者工具
2. 检查postMessage事件是否触发
3. 验证消息格式是否正确

## 性能优化建议

### 减小Flutter包大小
```bash
# 使用--web-renderer html模式（更小但性能稍低）
flutter build web --release --web-renderer html

# 使用--web-renderer canvaskit模式（默认，性能更好但更大）
flutter build web --release --web-renderer canvaskit
```

### Tree Shaking
确保在Flutter代码中只导入需要的包，避免导入整个库。

### 延迟加载
考虑将Flutter UI设置为按需加载，而不是插件启动时立即加载。

## 扩展开发

### 添加新的通信类型

1. 在TypeScript中添加消息处理:
```typescript
case 'your-new-type':
  // 处理逻辑
  break;
```

2. 在Flutter中发送:
```dart
html.window.parent?.postMessage({
  'type': 'your-new-type',
  'data': yourData
}, '*');
```

### 添加新的Flutter页面

1. 创建新的Dart文件
2. 在 `main.dart` 中添加路由
3. 更新导航逻辑

## 参考资源

- [Obsidian Plugin API](https://github.com/obsidianmd/obsidian-api)
- [Flutter Web 文档](https://docs.flutter.dev/platform-integration/web)
- [postMessage API](https://developer.mozilla.org/en-US/docs/Web/API/Window/postMessage)

## 许可证

MIT License
