# Migration Guide: From Monolithic to Modular Architecture

## 从单文件结构迁移到模块化架构

### 概述

本指南帮助您将现有的单文件Obsidian插件迁移到新的模块化架构。

---

## 迁移前准备

### 1. 备份现有代码
```bash
git checkout -b backup/before-refactor
git add .
git commit -m "Backup before refactoring"
git checkout main
```

### 2. 确保测试通过
```bash
npm run build
# 在Obsidian中测试插件功能正常
```

---

## 迁移步骤

### Step 1: 创建新的目录结构

```bash
mkdir -p src/{commands,settings,ui,utils}
```

### Step 2: 拆分主文件

#### 原始结构 (main.ts)
```typescript
// 所有代码在一个文件中
import { Plugin } from 'obsidian';

interface MyPluginSettings { /* ... */ }
const DEFAULT_SETTINGS: MyPluginSettings = { /* ... */ }

export default class MyPlugin extends Plugin {
  settings: MyPluginSettings;
  
  async onload() {
    // 混合了各种逻辑
    await this.loadSettings();
    
    this.addCommand({ /* ... */ });
    this.addSettingTab(new SampleSettingTab(this.app, this));
    // 更多代码...
  }
}

class SampleModal extends Modal { /* ... */ }
class SampleSettingTab extends PluginSettingTab { /* ... */ }
```

#### 新结构

**1. src/main.ts** (入口点 - 仅编排逻辑)
```typescript
import { Plugin } from 'obsidian';
import { MyPluginSettings, loadSettings, saveSettings } from './settings/settings';
import { SampleSettingTab } from './settings/settingTab';
import { registerCommands } from './commands/commands';
import { setupEventListeners } from './utils/eventListeners';

export default class MyPlugin extends Plugin {
	settings: MyPluginSettings;

	async onload() {
		await this.loadSettings();
		registerCommands(this);
		setupEventListeners(this);
		this.addSettingTab(new SampleSettingTab(this.app, this));
	}

	async loadSettings() {
		this.settings = await loadSettings(this);
	}

	async saveSettings() {
		await saveSettings(this);
	}
}
```

**2. src/settings/settings.ts** (设置数据)
```typescript
import type MyPlugin from '../main';

export interface MyPluginSettings {
	mySetting: string;
}

export const DEFAULT_SETTINGS: MyPluginSettings = {
	mySetting: 'default'
}

export async function loadSettings(plugin: MyPlugin): Promise<MyPluginSettings> {
	return Object.assign({}, DEFAULT_SETTINGS, await plugin.loadData());
}

export async function saveSettings(plugin: MyPlugin): Promise<void> {
	await plugin.saveData(plugin.settings);
}
```

**3. src/settings/settingTab.ts** (设置UI)
```typescript
import { App, PluginSettingTab, Setting } from 'obsidian';
import type MyPlugin from '../main';

export class SampleSettingTab extends PluginSettingTab {
	plugin: MyPlugin;

	constructor(app: App, plugin: MyPlugin) {
		super(app, plugin);
		this.plugin = plugin;
	}

	display(): void {
		// 设置UI逻辑
	}
}
```

**4. src/commands/commands.ts** (命令)
```typescript
import type MyPlugin from '../main';
import { SampleModal } from '../ui/modal';

export function registerCommands(plugin: MyPlugin): void {
	plugin.addCommand({
		id: 'open-sample-modal',
		name: 'Open Sample Modal',
		callback: () => {
			new SampleModal(plugin.app).open();
		}
	});
	// 更多命令...
}
```

**5. src/ui/modal.ts** (UI组件)
```typescript
import { App, Modal } from 'obsidian';

export class SampleModal extends Modal {
	constructor(app: App) {
		super(app);
	}

	onOpen() {
		this.contentEl.setText('Modal content');
	}

	onClose() {
		this.contentEl.empty();
	}
}
```

### Step 3: 更新构建配置

**esbuild.config.mjs**
```javascript
// 修改入口点
entryPoints: ["src/main.ts"],  // 从 "main.ts" 改为 "src/main.ts"
```

### Step 4: 更新TypeScript配置（可选）

**tsconfig.json**
```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  }
}
```

然后可以使用路径别名：
```typescript
import { loadSettings } from '@/settings/settings';
```

### Step 5: 测试构建

```bash
# 清理旧的构建产物
rm -f main.js main.js.map

# 构建新结构
npm run build

# 检查输出
ls -lh main.js
```

### Step 6: 测试功能

1. 复制到Obsidian插件目录
2. 重新加载Obsidian
3. 测试所有功能

---

## 迁移检查清单

### 代码迁移
- [ ] 创建 `src/` 目录结构
- [ ] 移动设置相关代码到 `src/settings/`
- [ ] 移动命令到 `src/commands/`
- [ ] 移动UI组件到 `src/ui/`
- [ ] 移动工具函数到 `src/utils/`
- [ ] 创建类型定义文件 `src/types.ts`
- [ ] 更新所有import路径
- [ ] 移除未使用的代码

### 构建配置
- [ ] 更新 `esbuild.config.mjs` 入口点
- [ ] 更新 `tsconfig.json`（如果需要）
- [ ] 更新 `.gitignore`
- [ ] 测试开发模式 (`npm run dev`)
- [ ] 测试生产构建 (`npm run build`)

### 文档
- [ ] 更新 README.md
- [ ] 添加模块说明
- [ ] 更新开发指南
- [ ] 添加示例代码

### 测试
- [ ] 所有命令正常工作
- [ ] 设置能正确保存和加载
- [ ] UI组件显示正常
- [ ] 没有控制台错误
- [ ] 性能没有下降

---

## 常见问题

### Q: 循环依赖错误
**A**: 重构模块依赖关系

```typescript
// ❌ 错误：循环依赖
// src/main.ts imports commands.ts
// commands.ts imports main.ts

// ✅ 正确：使用类型导入
import type MyPlugin from '../main';
```

### Q: 类型找不到
**A**: 确保使用正确的导入路径

```typescript
// ❌ 错误
import { MyPluginSettings } from './settings';

// ✅ 正确
import { MyPluginSettings } from './settings/settings';
// 或使用 barrel export
import { MyPluginSettings } from './settings';  // 如果有 index.ts
```

### Q: 构建体积增大
**A**: 检查是否导入了不必要的模块

```typescript
// ❌ 导入整个lodash
import _ from 'lodash';

// ✅ 只导入需要的函数
import debounce from 'lodash/debounce';
```

### Q: 热重载不工作
**A**: 确保dev模式正确运行

```bash
# 停止旧的dev进程
npm run dev
# 检查esbuild是否在监听文件变化
```

---

## 迁移模板

### 小型插件 (< 500行)

```
src/
├── main.ts           # 入口
├── settings.ts       # 所有设置
├── commands.ts       # 所有命令
└── utils.ts          # 工具函数
```

### 中型插件 (500-2000行)

```
src/
├── main.ts
├── settings/
│   ├── settings.ts
│   └── settingTab.ts
├── commands/
│   └── commands.ts
├── ui/
│   ├── modal.ts
│   └── view.ts
└── utils/
    └── helpers.ts
```

### 大型插件 (> 2000行)

```
src/
├── main.ts
├── types.ts
├── settings/
│   ├── index.ts
│   ├── settings.ts
│   └── settingTab.ts
├── commands/
│   ├── index.ts
│   ├── editorCommands.ts
│   └── viewCommands.ts
├── ui/
│   ├── index.ts
│   ├── modals/
│   │   ├── confirmModal.ts
│   │   └── inputModal.ts
│   └── views/
│       ├── mainView.ts
│       └── sidebarView.ts
├── utils/
│   ├── index.ts
│   ├── helpers.ts
│   ├── validators.ts
│   └── formatters.ts
└── services/
    ├── apiService.ts
    └── dataService.ts
```

---

## 性能对比

### 构建时间
| 结构 | TypeScript编译 | esbuild打包 | 总时间 |
|------|---------------|------------|--------|
| 单文件 | ~2s | ~0.5s | ~2.5s |
| 模块化 | ~2.5s | ~0.5s | ~3s |

性能差异可忽略不计。

### 运行时性能
模块化不影响运行时性能，因为最终都打包成单个文件。

### 开发体验
- ✅ 代码更易理解和维护
- ✅ 多人协作更容易
- ✅ IDE支持更好（智能提示、跳转）
- ✅ 测试更容易编写

---

## 回滚计划

如果迁移出现问题：

```bash
# 恢复到迁移前的状态
git checkout backup/before-refactor

# 或者只恢复特定文件
git checkout backup/before-refactor -- main.ts
```

---

## 下一步

迁移完成后：

1. **添加单元测试**: 为各个模块编写测试
2. **文档化API**: 为公共函数添加JSDoc注释
3. **持续重构**: 识别并优化代码异味
4. **性能监控**: 监控构建时间和包大小

---

## 示例：实际迁移案例

查看提交历史了解实际迁移过程：
```bash
git log --oneline src/
```

参考 `REFACTORED_README.md` 了解新架构的详细信息。
