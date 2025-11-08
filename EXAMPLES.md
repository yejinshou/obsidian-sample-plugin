# Code Examples - Modular Obsidian Plugin

## 示例代码集合

本文档提供了在模块化架构中常见的代码示例。

---

## 1. 基础插件结构

### 最小化插件入口
```typescript
// src/main.ts
import { Plugin } from 'obsidian';
import { loadSettings, saveSettings } from './settings/settings';

export default class MyPlugin extends Plugin {
	settings: MyPluginSettings;

	async onload() {
		await this.loadSettings();
		console.log('Plugin loaded');
	}

	async loadSettings() {
		this.settings = await loadSettings(this);
	}

	async saveSettings() {
		await saveSettings(this);
	}
}
```

---

## 2. 命令系统

### 简单命令
```typescript
// src/commands/simpleCommands.ts
import { Notice } from 'obsidian';
import type MyPlugin from '../main';

export function registerSimpleCommands(plugin: MyPlugin): void {
	plugin.addCommand({
		id: 'hello-world',
		name: 'Say Hello',
		callback: () => {
			new Notice('Hello, World!');
		}
	});
}
```

### 编辑器命令
```typescript
// src/commands/editorCommands.ts
import { Editor, MarkdownView } from 'obsidian';
import type MyPlugin from '../main';

export function registerEditorCommands(plugin: MyPlugin): void {
	plugin.addCommand({
		id: 'uppercase-selection',
		name: 'Convert selection to uppercase',
		editorCallback: (editor: Editor) => {
			const selection = editor.getSelection();
			editor.replaceSelection(selection.toUpperCase());
		}
	});

	plugin.addCommand({
		id: 'insert-timestamp',
		name: 'Insert current timestamp',
		editorCallback: (editor: Editor) => {
			const timestamp = new Date().toISOString();
			editor.replaceSelection(timestamp);
		}
	});
}
```

### 条件命令
```typescript
// src/commands/conditionalCommands.ts
import { MarkdownView } from 'obsidian';
import type MyPlugin from '../main';

export function registerConditionalCommands(plugin: MyPlugin): void {
	plugin.addCommand({
		id: 'process-current-file',
		name: 'Process current file',
		checkCallback: (checking: boolean) => {
			const view = plugin.app.workspace.getActiveViewOfType(MarkdownView);
			
			if (view) {
				if (!checking) {
					// Execute command
					const file = view.file;
					console.log('Processing file:', file?.path);
				}
				return true;
			}
			return false;
		}
	});
}
```

---

## 3. 设置管理

### 基础设置
```typescript
// src/settings/settings.ts
import type MyPlugin from '../main';

export interface MyPluginSettings {
	apiKey: string;
	enabled: boolean;
	refreshInterval: number;
}

export const DEFAULT_SETTINGS: MyPluginSettings = {
	apiKey: '',
	enabled: true,
	refreshInterval: 60
}

export async function loadSettings(plugin: MyPlugin): Promise<MyPluginSettings> {
	return Object.assign({}, DEFAULT_SETTINGS, await plugin.loadData());
}

export async function saveSettings(plugin: MyPlugin): Promise<void> {
	await plugin.saveData(plugin.settings);
}

// Helper functions
export function validateSettings(settings: MyPluginSettings): boolean {
	return settings.refreshInterval > 0 && settings.refreshInterval <= 3600;
}

export function resetSettings(): MyPluginSettings {
	return { ...DEFAULT_SETTINGS };
}
```

### 设置UI
```typescript
// src/settings/settingTab.ts
import { App, PluginSettingTab, Setting } from 'obsidian';
import type MyPlugin from '../main';
import { validateSettings } from './settings';

export class MySettingTab extends PluginSettingTab {
	plugin: MyPlugin;

	constructor(app: App, plugin: MyPlugin) {
		super(app, plugin);
		this.plugin = plugin;
	}

	display(): void {
		const { containerEl } = this;
		containerEl.empty();

		// Text input
		new Setting(containerEl)
			.setName('API Key')
			.setDesc('Your API key')
			.addText(text => text
				.setPlaceholder('Enter API key')
				.setValue(this.plugin.settings.apiKey)
				.onChange(async (value) => {
					this.plugin.settings.apiKey = value;
					await this.plugin.saveSettings();
				}));

		// Toggle
		new Setting(containerEl)
			.setName('Enable feature')
			.setDesc('Turn on/off the feature')
			.addToggle(toggle => toggle
				.setValue(this.plugin.settings.enabled)
				.onChange(async (value) => {
					this.plugin.settings.enabled = value;
					await this.plugin.saveSettings();
				}));

		// Slider
		new Setting(containerEl)
			.setName('Refresh interval')
			.setDesc('How often to refresh (seconds)')
			.addSlider(slider => slider
				.setLimits(10, 300, 10)
				.setValue(this.plugin.settings.refreshInterval)
				.setDynamicTooltip()
				.onChange(async (value) => {
					this.plugin.settings.refreshInterval = value;
					await this.plugin.saveSettings();
				}));

		// Dropdown
		new Setting(containerEl)
			.setName('Theme')
			.setDesc('Choose a theme')
			.addDropdown(dropdown => dropdown
				.addOption('light', 'Light')
				.addOption('dark', 'Dark')
				.addOption('auto', 'Auto')
				.setValue('auto')
				.onChange(async (value) => {
					// Save theme preference
					console.log('Theme changed to:', value);
				}));

		// Button
		new Setting(containerEl)
			.setName('Reset settings')
			.setDesc('Reset all settings to defaults')
			.addButton(button => button
				.setButtonText('Reset')
				.setWarning()
				.onClick(async () => {
					if (confirm('Are you sure you want to reset all settings?')) {
						// Reset logic
					}
				}));
	}
}
```

---

## 4. UI组件

### 简单模态框
```typescript
// src/ui/simpleModal.ts
import { App, Modal } from 'obsidian';

export class SimpleModal extends Modal {
	title: string;
	message: string;

	constructor(app: App, title: string, message: string) {
		super(app);
		this.title = title;
		this.message = message;
	}

	onOpen() {
		const { contentEl } = this;
		contentEl.createEl('h2', { text: this.title });
		contentEl.createEl('p', { text: this.message });
	}

	onClose() {
		const { contentEl } = this;
		contentEl.empty();
	}
}
```

### 输入模态框
```typescript
// src/ui/inputModal.ts
import { App, Modal, Setting } from 'obsidian';

export class InputModal extends Modal {
	result: string;
	onSubmit: (result: string) => void;

	constructor(app: App, onSubmit: (result: string) => void) {
		super(app);
		this.onSubmit = onSubmit;
	}

	onOpen() {
		const { contentEl } = this;

		contentEl.createEl('h2', { text: 'Enter value' });

		new Setting(contentEl)
			.setName('Value')
			.addText(text => text
				.onChange(value => {
					this.result = value;
				}));

		new Setting(contentEl)
			.addButton(btn => btn
				.setButtonText('Submit')
				.setCta()
				.onClick(() => {
					this.close();
					this.onSubmit(this.result);
				}));
	}

	onClose() {
		const { contentEl } = this;
		contentEl.empty();
	}
}

// Usage:
// new InputModal(this.app, (result) => {
//     console.log('User entered:', result);
// }).open();
```

### 自定义视图
```typescript
// src/ui/customView.ts
import { ItemView, WorkspaceLeaf } from 'obsidian';

export const VIEW_TYPE_CUSTOM = 'custom-view';

export class CustomView extends ItemView {
	constructor(leaf: WorkspaceLeaf) {
		super(leaf);
	}

	getViewType(): string {
		return VIEW_TYPE_CUSTOM;
	}

	getDisplayText(): string {
		return 'Custom View';
	}

	getIcon(): string {
		return 'dice';
	}

	async onOpen() {
		const container = this.containerEl.children[1];
		container.empty();
		container.createEl('h4', { text: 'Custom View Content' });
		
		const div = container.createEl('div', { cls: 'custom-view-content' });
		div.createEl('p', { text: 'This is a custom view' });
	}

	async onClose() {
		// Cleanup
	}
}

// Register in main.ts:
// this.registerView(
//     VIEW_TYPE_CUSTOM,
//     (leaf) => new CustomView(leaf)
// );
```

---

## 5. 工具函数

### 文件操作
```typescript
// src/utils/fileUtils.ts
import { App, TFile, TFolder } from 'obsidian';

export async function createNote(
	app: App,
	path: string,
	content: string
): Promise<TFile> {
	const file = await app.vault.create(path, content);
	return file;
}

export async function readNote(app: App, path: string): Promise<string> {
	const file = app.vault.getAbstractFileByPath(path);
	if (file instanceof TFile) {
		return await app.vault.read(file);
	}
	throw new Error(`File not found: ${path}`);
}

export async function updateNote(
	app: App,
	path: string,
	content: string
): Promise<void> {
	const file = app.vault.getAbstractFileByPath(path);
	if (file instanceof TFile) {
		await app.vault.modify(file, content);
	}
}

export async function deleteNote(app: App, path: string): Promise<void> {
	const file = app.vault.getAbstractFileByPath(path);
	if (file instanceof TFile) {
		await app.vault.delete(file);
	}
}

export function getAllMarkdownFiles(app: App): TFile[] {
	return app.vault.getMarkdownFiles();
}

export function getFilesInFolder(app: App, folderPath: string): TFile[] {
	const folder = app.vault.getAbstractFileByPath(folderPath);
	if (folder instanceof TFolder) {
		return folder.children.filter((f): f is TFile => f instanceof TFile);
	}
	return [];
}
```

### 数据处理
```typescript
// src/utils/dataUtils.ts
export function debounce<T extends (...args: unknown[]) => unknown>(
	func: T,
	wait: number
): (...args: Parameters<T>) => void {
	let timeout: NodeJS.Timeout;
	return function executedFunction(...args: Parameters<T>) {
		clearTimeout(timeout);
		timeout = setTimeout(() => func(...args), wait);
	};
}

export function throttle<T extends (...args: unknown[]) => unknown>(
	func: T,
	limit: number
): (...args: Parameters<T>) => void {
	let inThrottle: boolean;
	return function executedFunction(...args: Parameters<T>) {
		if (!inThrottle) {
			func(...args);
			inThrottle = true;
			setTimeout(() => (inThrottle = false), limit);
		}
	};
}

export function groupBy<T>(
	array: T[],
	key: keyof T
): Record<string, T[]> {
	return array.reduce((result, item) => {
		const group = String(item[key]);
		if (!result[group]) {
			result[group] = [];
		}
		result[group].push(item);
		return result;
	}, {} as Record<string, T[]>);
}
```

### 日期/时间
```typescript
// src/utils/dateUtils.ts
export function formatDate(date: Date, format = 'YYYY-MM-DD'): string {
	const year = date.getFullYear();
	const month = String(date.getMonth() + 1).padStart(2, '0');
	const day = String(date.getDate()).padStart(2, '0');
	
	return format
		.replace('YYYY', String(year))
		.replace('MM', month)
		.replace('DD', day);
}

export function parseDate(dateString: string): Date {
	return new Date(dateString);
}

export function addDays(date: Date, days: number): Date {
	const result = new Date(date);
	result.setDate(result.getDate() + days);
	return result;
}

export function getDaysBetween(date1: Date, date2: Date): number {
	const diff = Math.abs(date1.getTime() - date2.getTime());
	return Math.ceil(diff / (1000 * 60 * 60 * 24));
}
```

---

## 6. 事件处理

### 文件事件
```typescript
// src/events/fileEvents.ts
import { TFile } from 'obsidian';
import type MyPlugin from '../main';

export function setupFileEvents(plugin: MyPlugin): void {
	// File created
	plugin.registerEvent(
		plugin.app.vault.on('create', (file) => {
			console.log('File created:', file.path);
		})
	);

	// File modified
	plugin.registerEvent(
		plugin.app.vault.on('modify', (file) => {
			if (file instanceof TFile) {
				console.log('File modified:', file.path);
			}
		})
	);

	// File deleted
	plugin.registerEvent(
		plugin.app.vault.on('delete', (file) => {
			console.log('File deleted:', file.path);
		})
	);

	// File renamed
	plugin.registerEvent(
		plugin.app.vault.on('rename', (file, oldPath) => {
			console.log(`File renamed from ${oldPath} to ${file.path}`);
		})
	);
}
```

### Workspace事件
```typescript
// src/events/workspaceEvents.ts
import { MarkdownView } from 'obsidian';
import type MyPlugin from '../main';

export function setupWorkspaceEvents(plugin: MyPlugin): void {
	// Active leaf changed
	plugin.registerEvent(
		plugin.app.workspace.on('active-leaf-change', (leaf) => {
			console.log('Active leaf changed');
		})
	);

	// Layout changed
	plugin.registerEvent(
		plugin.app.workspace.on('layout-change', () => {
			console.log('Layout changed');
		})
	);

	// File opened
	plugin.registerEvent(
		plugin.app.workspace.on('file-open', (file) => {
			if (file) {
				console.log('File opened:', file.path);
			}
		})
	);
}
```

---

## 7. 异步操作

### Promise处理
```typescript
// src/utils/asyncUtils.ts
export async function retry<T>(
	fn: () => Promise<T>,
	maxRetries = 3,
	delay = 1000
): Promise<T> {
	for (let i = 0; i < maxRetries; i++) {
		try {
			return await fn();
		} catch (error) {
			if (i === maxRetries - 1) throw error;
			await new Promise(resolve => setTimeout(resolve, delay));
		}
	}
	throw new Error('Max retries exceeded');
}

export async function timeout<T>(
	promise: Promise<T>,
	ms: number
): Promise<T> {
	const timeoutPromise = new Promise<never>((_, reject) =>
		setTimeout(() => reject(new Error('Timeout')), ms)
	);
	return Promise.race([promise, timeoutPromise]);
}

export async function parallel<T>(
	tasks: (() => Promise<T>)[]
): Promise<T[]> {
	return Promise.all(tasks.map(task => task()));
}

export async function sequential<T>(
	tasks: (() => Promise<T>)[]
): Promise<T[]> {
	const results: T[] = [];
	for (const task of tasks) {
		results.push(await task());
	}
	return results;
}
```

---

## 8. 完整示例：笔记统计插件

```typescript
// src/main.ts
import { Plugin, Notice } from 'obsidian';
import { NoteStatsView, VIEW_TYPE_STATS } from './ui/statsView';
import { calculateStats } from './utils/statsCalculator';

export default class NoteStatsPlugin extends Plugin {
	async onload() {
		// Register view
		this.registerView(
			VIEW_TYPE_STATS,
			(leaf) => new NoteStatsView(leaf, this)
		);

		// Add command
		this.addCommand({
			id: 'show-stats',
			name: 'Show note statistics',
			callback: async () => {
				const stats = await calculateStats(this.app);
				new Notice(`Total notes: ${stats.totalNotes}`);
			}
		});

		// Add ribbon icon
		this.addRibbonIcon('bar-chart', 'Note Stats', () => {
			this.activateView();
		});
	}

	async activateView() {
		const { workspace } = this.app;
		
		let leaf = workspace.getLeavesOfType(VIEW_TYPE_STATS)[0];
		if (!leaf) {
			leaf = workspace.getRightLeaf(false)!;
			await leaf.setViewState({ type: VIEW_TYPE_STATS });
		}
		
		workspace.revealLeaf(leaf);
	}
}

// src/utils/statsCalculator.ts
import { App, TFile } from 'obsidian';

export interface NoteStats {
	totalNotes: number;
	totalWords: number;
	totalCharacters: number;
	averageLength: number;
}

export async function calculateStats(app: App): Promise<NoteStats> {
	const files = app.vault.getMarkdownFiles();
	let totalWords = 0;
	let totalCharacters = 0;

	for (const file of files) {
		const content = await app.vault.read(file);
		totalWords += content.split(/\s+/).length;
		totalCharacters += content.length;
	}

	return {
		totalNotes: files.length,
		totalWords,
		totalCharacters,
		averageLength: files.length > 0 ? totalWords / files.length : 0
	};
}

// src/ui/statsView.ts
import { ItemView, WorkspaceLeaf } from 'obsidian';
import type NoteStatsPlugin from '../main';
import { calculateStats } from '../utils/statsCalculator';

export const VIEW_TYPE_STATS = 'note-stats-view';

export class NoteStatsView extends ItemView {
	plugin: NoteStatsPlugin;

	constructor(leaf: WorkspaceLeaf, plugin: NoteStatsPlugin) {
		super(leaf);
		this.plugin = plugin;
	}

	getViewType(): string {
		return VIEW_TYPE_STATS;
	}

	getDisplayText(): string {
		return 'Note Statistics';
	}

	async onOpen() {
		const container = this.containerEl.children[1];
		container.empty();
		container.createEl('h4', { text: 'Note Statistics' });

		const stats = await calculateStats(this.app);
		
		const statsDiv = container.createEl('div', { cls: 'stats-container' });
		statsDiv.createEl('p', { text: `Total Notes: ${stats.totalNotes}` });
		statsDiv.createEl('p', { text: `Total Words: ${stats.totalWords}` });
		statsDiv.createEl('p', { text: `Total Characters: ${stats.totalCharacters}` });
		statsDiv.createEl('p', { 
			text: `Average Length: ${stats.averageLength.toFixed(2)} words` 
		});
	}
}
```

---

## 总结

这些示例展示了如何在模块化架构中组织代码。关键原则：

1. **单一职责**: 每个模块负责一个功能
2. **类型安全**: 使用TypeScript类型
3. **可复用**: 创建可复用的工具函数
4. **清晰结构**: 逻辑分组到适当的目录

参考 `src/` 目录中的实际实现。
