import { Plugin } from 'obsidian';
import { MyPluginSettings, loadSettings, saveSettings } from './settings/settings';
import { SampleSettingTab } from './settings/settingTab';
import { SampleModal } from './ui/modal';
import { registerCommands } from './commands/commands';
import { setupEventListeners } from './utils/eventListeners';

export default class MyPlugin extends Plugin {
	settings: MyPluginSettings;

	async onload() {
		await this.loadSettings();

		// Register all commands
		registerCommands(this);

		// Set up event listeners
		setupEventListeners(this);

		// Add ribbon icon
		const ribbonIconEl = this.addRibbonIcon('dice', 'Sample Plugin', (_evt: MouseEvent) => {
			new SampleModal(this.app).open();
		});
		ribbonIconEl.addClass('my-plugin-ribbon-class');

		// Add status bar item
		const statusBarItemEl = this.addStatusBarItem();
		statusBarItemEl.setText('Status Bar Text');

		// Add settings tab
		this.addSettingTab(new SampleSettingTab(this.app, this));

		console.log('Plugin loaded successfully');
	}

	onunload() {
		console.log('Plugin unloaded');
	}

	async loadSettings() {
		this.settings = await loadSettings(this);
	}

	async saveSettings() {
		await saveSettings(this);
	}
}
