# Flutter混合插件快速开始指南

## 什么是这个项目？

这是一个**混合架构**的Obsidian插件：
- **核心**: TypeScript (使用Obsidian Plugin API)
- **UI**: Flutter Web (现代化界面)
- **通信**: postMessage实现双向数据交互

## 为什么选择混合架构？

### 优势
✅ TypeScript核心 - 完全兼容Obsidian Plugin API  
✅ Flutter UI - 丰富的UI组件和跨平台支持  
✅ 独立开发 - UI和逻辑可以分别开发和测试  
✅ 灵活扩展 - 可以随时添加新的UI功能  

### 与纯Flutter方案对比
- ✅ 避免了Flutter Web到CommonJS的转换问题
- ✅ 保持了Obsidian插件的标准结构
- ✅ 更小的核心插件体积
- ✅ 更容易调试和维护

## 快速开始（5分钟）

### 前置要求
```bash
# 检查Node.js版本（需要18+）
node --version

# 检查Flutter版本（需要3.0+）
flutter --version
```

如果没有安装：
- Node.js: https://nodejs.org/
- Flutter: https://docs.flutter.dev/get-started/install

### 一键部署

#### Linux/Mac
```bash
# 修改deploy.sh中的VAULT_PATH为你的Obsidian保管库路径
# 或直接传入路径作为参数

./deploy.sh /path/to/your/obsidian/vault
```

#### Windows
```batch
REM 修改deploy.bat中的VAULT_PATH为你的Obsidian保管库路径
REM 或直接传入路径作为参数

deploy.bat C:\path\to\your\obsidian\vault
```

### 手动步骤

如果自动部署失败，可以手动执行：

#### 1. 安装依赖
```bash
# TypeScript依赖
npm install

# Flutter依赖
cd flutter_ui
flutter pub get
cd ..
```

#### 2. 编译Flutter Web
```bash
cd flutter_ui
flutter build web --release
cd ..
```

#### 3. 编译TypeScript
```bash
# 临时修改esbuild.config.mjs的entryPoints为["flutter-main.ts"]
npm run build
# 编译后记得改回["main.ts"]
```

#### 4. 复制文件
```bash
# 创建目录
mkdir -p <你的保管库>/.obsidian/plugins/flutter-hybrid-plugin/flutter_ui/build

# 复制文件
cp main.js <你的保管库>/.obsidian/plugins/flutter-hybrid-plugin/
cp manifest.json <你的保管库>/.obsidian/plugins/flutter-hybrid-plugin/
cp -r flutter_ui/build/web <你的保管库>/.obsidian/plugins/flutter-hybrid-plugin/flutter_ui/build/
```

#### 5. 在Obsidian中启用
1. 打开Obsidian
2. 设置 → 社区插件
3. 关闭安全模式
4. 重新加载插件
5. 启用"Flutter Hybrid Plugin"

## 使用方法

### 打开UI
- 点击左侧功能区的 📊 图标
- 或按 `Ctrl/Cmd + P`，输入"Open Flutter UI"

### 测试通信
1. 在Flutter UI的文本框中输入消息
2. 点击"Send to Obsidian"
3. 打开开发者控制台（F12）查看消息

### 配置设置
- 在Obsidian设置中找到"Flutter Hybrid Plugin"
- 或在Flutter UI中修改设置

## 目录结构

```
obsidian-sample-plugin/
├── flutter-main.ts              # TypeScript插件核心 ⭐
├── flutter_ui/                  # Flutter Web应用 ⭐
│   ├── pubspec.yaml            # Flutter配置
│   ├── lib/
│   │   ├── main.dart           # Flutter主程序 ⭐
│   │   └── settings_page.dart  # 设置页面
│   └── web/
│       └── index.html          # HTML入口
├── deploy.sh                    # Linux/Mac部署脚本 ⭐
├── deploy.bat                   # Windows部署脚本 ⭐
├── FLUTTER_PLUGIN_README.md    # 完整文档 📖
├── QUICK_START.md              # 本文件
├── manifest.json               # 插件清单
└── package.json               # npm配置
```

⭐ = 核心文件  
📖 = 文档

## 开发工作流

### 开发Flutter UI
```bash
cd flutter_ui
flutter run -d chrome
```
这将启动热重载模式，可以实时查看UI变化。

### 开发TypeScript插件
```bash
npm run dev
```
这将启动watch模式，自动重新编译。

### 完整测试
每次修改后：
1. 编译Flutter: `cd flutter_ui && flutter build web && cd ..`
2. 编译TypeScript: `npm run build`
3. 在Obsidian中重新加载插件

## 常见问题

### Q: Flutter编译很慢
A: 第一次编译会较慢（下载依赖），后续会快很多。可以使用：
```bash
flutter build web --release --web-renderer html  # 更快但渲染质量稍低
```

### Q: 插件无法加载
A: 检查：
1. `main.js`是否存在
2. `manifest.json`是否正确
3. Flutter构建输出是否在`flutter_ui/build/web/`
4. 查看Obsidian开发者控制台的错误信息

### Q: UI显示空白
A: 可能是路径问题。确保：
1. Flutter已正确编译
2. `index.html`在`flutter_ui/build/web/`目录下
3. iframe的src路径正确

### Q: 通信不工作
A: 检查：
1. 浏览器控制台是否有CORS错误
2. postMessage的格式是否正确
3. 消息监听器是否正确注册

## 下一步

### 扩展功能
- 添加更多UI页面
- 实现文件操作功能
- 添加自定义主题
- 集成第三方API

### 优化
- 减小Flutter包大小
- 实现懒加载
- 添加缓存机制
- 改进错误处理

## 获取帮助

- 完整文档: [FLUTTER_PLUGIN_README.md](./FLUTTER_PLUGIN_README.md)
- Obsidian API: https://github.com/obsidianmd/obsidian-api
- Flutter文档: https://docs.flutter.dev/

## 贡献

欢迎提交Issue和Pull Request！

---

**提示**: 第一次使用建议仔细阅读[完整文档](./FLUTTER_PLUGIN_README.md)了解更多细节。
