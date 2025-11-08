# Refactored Obsidian Plugin - Multi-File TypeScript Architecture

## 项目概述 / Project Overview

This is a refactored Obsidian plugin that demonstrates a modern, modular architecture with **multiple TypeScript input files** that compile to **JavaScript-only output**. 

这是一个重构后的Obsidian插件，展示了现代化的模块化架构，支持**多个TypeScript输入文件**，编译输出**纯JavaScript文件**。

## 核心特性 / Key Features

✅ **Multiple TypeScript Input Files** - 多个TypeScript输入文件  
✅ **JavaScript-Only Output** - 纯JavaScript输出（main.js）  
✅ **Modular Architecture** - 模块化架构  
✅ **Strongly Typed** - 强类型支持  
✅ **Tree-Shaking Enabled** - 支持Tree-shaking优化  
✅ **Production Ready** - 生产环境就绪  

## 项目架构 / Project Architecture

### Directory Structure / 目录结构

```
obsidian-sample-plugin/
├── src/                          # Source TypeScript files / TypeScript源文件
│   ├── main.ts                   # Plugin entry point / 插件入口
│   ├── types.ts                  # Type definitions / 类型定义
│   ├── commands/                 # Command handlers / 命令处理器
│   │   └── commands.ts          # Command registration / 命令注册
│   ├── settings/                 # Settings management / 设置管理
│   │   ├── settings.ts          # Settings data / 设置数据
│   │   └── settingTab.ts        # Settings UI / 设置界面
│   ├── ui/                       # UI components / UI组件
│   │   └── modal.ts             # Modal dialogs / 对话框
│   ├── utils/                    # Utility functions / 工具函数
│   │   ├── helpers.ts           # Helper utilities / 辅助工具
│   │   └── eventListeners.ts   # Event handlers / 事件处理
│   └── advanced/                 # Advanced features / 高级功能
│       └── advancedFeatures.ts  # Optional advanced module / 可选高级模块
├── main.js                       # Built output (JavaScript only) / 构建输出（纯JS）
├── manifest.json                 # Plugin manifest / 插件清单
├── esbuild.config.mjs           # Build configuration / 构建配置
├── package.json                  # Dependencies / 依赖配置
└── tsconfig.json                # TypeScript configuration / TS配置
```

### Module Organization / 模块组织

#### 1. **Entry Point** (`src/main.ts`)
- Plugin lifecycle management / 插件生命周期管理
- Module orchestration / 模块编排
- Minimal business logic / 最少业务逻辑

#### 2. **Settings** (`src/settings/`)
- `settings.ts`: Data structures and persistence / 数据结构和持久化
- `settingTab.ts`: Settings UI / 设置界面

#### 3. **Commands** (`src/commands/`)
- All plugin commands / 所有插件命令
- Command registration / 命令注册
- Callback implementations / 回调实现

#### 4. **UI Components** (`src/ui/`)
- Modals, views, and dialogs / 对话框、视图和弹窗
- Reusable UI components / 可复用UI组件

#### 5. **Utilities** (`src/utils/`)
- Helper functions / 辅助函数
- Event listeners / 事件监听器
- Common utilities / 通用工具

#### 6. **Types** (`src/types.ts`)
- TypeScript interfaces / TypeScript接口
- Type definitions / 类型定义
- Shared types / 共享类型

## 构建系统 / Build System

### Build Process / 构建流程

The project uses **esbuild** for ultra-fast compilation:

项目使用 **esbuild** 进行超快速编译：

```
Multiple TypeScript Files    →    esbuild    →    Single main.js
   (src/**/*.ts)                  (bundler)         (JavaScript only)
```

### Build Commands / 构建命令

```bash
# Development mode with watch (开发模式，带监听)
npm run dev

# Production build (生产构建)
npm run build

# Type checking only (仅类型检查)
npx tsc -noEmit -skipLibCheck
```

### Build Features / 构建特性

- **Bundle**: All TypeScript files are bundled into a single `main.js`
- **Tree-shaking**: Unused code is automatically removed
- **Minification**: Production builds are minified
- **Source Maps**: Available in development mode
- **External Dependencies**: Obsidian API is marked as external (not bundled)

## 使用指南 / Usage Guide

### Installation / 安装

1. **Install dependencies / 安装依赖**
   ```bash
   npm install
   ```

2. **Build the plugin / 构建插件**
   ```bash
   npm run build
   ```

3. **Copy to Obsidian vault / 复制到Obsidian保管库**
   ```bash
   # Manually copy / 手动复制
   cp main.js manifest.json <VaultPath>/.obsidian/plugins/your-plugin-name/
   
   # Or use deploy script / 或使用部署脚本
   ./deploy.sh  # Linux/Mac
   ./deploy.bat # Windows
   ```

### Development Workflow / 开发工作流

1. **Start dev mode / 启动开发模式**
   ```bash
   npm run dev
   ```

2. **Make changes to TypeScript files / 修改TypeScript文件**
   - Edit any file in `src/` directory
   - Changes are automatically recompiled

3. **Test in Obsidian / 在Obsidian中测试**
   - Press `Ctrl/Cmd + R` to reload Obsidian
   - Or disable and re-enable the plugin

### Adding New Features / 添加新功能

#### Add a New Command / 添加新命令

Edit `src/commands/commands.ts`:

```typescript
plugin.addCommand({
    id: 'your-new-command',
    name: 'Your New Command',
    callback: () => {
        new Notice('New command executed!');
    }
});
```

#### Add a New Setting / 添加新设置

1. Update interface in `src/settings/settings.ts`:
   ```typescript
   export interface MyPluginSettings {
       // ... existing settings
       newSetting: string;
   }
   ```

2. Add UI in `src/settings/settingTab.ts`:
   ```typescript
   new Setting(containerEl)
       .setName('New Setting')
       .setDesc('Description')
       .addText(text => text
           .setValue(this.plugin.settings.newSetting)
           .onChange(async (value) => {
               this.plugin.settings.newSetting = value;
               await this.plugin.saveSettings();
           }));
   ```

#### Create a New Module / 创建新模块

1. Create a new file: `src/features/myFeature.ts`
2. Export your functions/classes
3. Import in `src/main.ts`
4. Use in plugin lifecycle

## 扩展支持 / Extension Support

### Adding Dart/Flutter Support / 添加Dart/Flutter支持

If you want to add Dart code that compiles to JavaScript:

如果要添加编译为JavaScript的Dart代码：

1. **Option 1: Dart2JS** (Standalone compilation / 独立编译)
   ```bash
   dart compile js src/dart/myfile.dart -o src/dart/myfile.js
   ```
   Then import in TypeScript:
   ```typescript
   import './dart/myfile.js';
   ```

2. **Option 2: Flutter Web** (For UI components / 用于UI组件)
   - Compile Flutter to JS: `flutter build web`
   - Load compiled JS dynamically in your plugin
   - Use postMessage for communication

### Multiple JavaScript Outputs / 多个JavaScript输出

To build multiple JS files, update `esbuild.config.mjs`:

要构建多个JS文件，更新 `esbuild.config.mjs`：

```javascript
entryPoints: [
    "src/main.ts",
    "src/advanced/advancedFeatures.ts"
],
outdir: "dist",  // Output directory instead of outfile
```

This will generate:
- `dist/main.js`
- `dist/advancedFeatures.js`

## 技术规格 / Technical Specifications

### TypeScript Configuration / TypeScript配置

- **Target**: ES2018
- **Module**: CommonJS
- **Strict Mode**: Enabled
- **Source Maps**: Development only

### Build Configuration / 构建配置

- **Bundler**: esbuild 0.17.3
- **Format**: CommonJS (cjs)
- **Tree-shaking**: Enabled
- **Minification**: Production only
- **External**: Obsidian API, Electron, CodeMirror

### Dependencies / 依赖

- **Runtime**: Obsidian API (external)
- **Dev**: TypeScript 4.7.4, esbuild 0.17.3
- **Types**: @types/node, obsidian.d.ts

## 最佳实践 / Best Practices

### Code Organization / 代码组织

✅ **Do / 推荐**:
- Keep files small and focused (< 300 lines)
- One class/feature per file
- Use barrel exports (index.ts) for modules
- Group related functionality in directories

❌ **Don't / 不推荐**:
- Put all code in main.ts
- Mix concerns in a single file
- Create circular dependencies
- Import entire libraries when you need one function

### Performance / 性能

- Use lazy loading for heavy features
- Avoid expensive operations in onload()
- Debounce frequent operations
- Cache computed values

### Type Safety / 类型安全

- Always define interfaces for complex data
- Use strict TypeScript checks
- Avoid `any` type when possible
- Leverage type inference

## 故障排除 / Troubleshooting

### Build Errors / 构建错误

**Error**: `Cannot find module 'obsidian'`
- **Solution**: Run `npm install`

**Error**: TypeScript compilation errors
- **Solution**: Check `tsconfig.json` and fix type errors

### Runtime Errors / 运行时错误

**Error**: Plugin doesn't load
- Check browser console (Ctrl/Cmd + Shift + I)
- Verify `main.js` and `manifest.json` exist
- Check Obsidian version compatibility

**Error**: Commands not appearing
- Reload Obsidian
- Check command IDs are unique
- Verify plugin is enabled

## 版本历史 / Version History

### v1.0.0 - Refactored Architecture
- ✅ Multi-file TypeScript structure
- ✅ JavaScript-only output
- ✅ Modular command system
- ✅ Enhanced settings management
- ✅ Utility functions library
- ✅ Type definitions

## 贡献 / Contributing

This is a sample/template project. Feel free to:
- Fork and customize
- Report issues
- Submit improvements
- Create variants

## 许可证 / License

MIT License - See LICENSE file for details

## 相关资源 / Resources

- [Obsidian Plugin API](https://github.com/obsidianmd/obsidian-api)
- [TypeScript Documentation](https://www.typescriptlang.org/docs/)
- [esbuild Documentation](https://esbuild.github.io/)
- [Plugin Development Guide](https://docs.obsidian.md/Plugins/Getting+started/Build+a+plugin)

---

**Note**: This refactored architecture demonstrates how to build a modular Obsidian plugin with multiple TypeScript source files that compile to a single JavaScript output. The structure is scalable and maintainable for larger projects.

**注意**: 这个重构后的架构展示了如何构建一个模块化的Obsidian插件，使用多个TypeScript源文件编译为单个JavaScript输出。这个结构适合大型项目，具有良好的可扩展性和可维护性。
