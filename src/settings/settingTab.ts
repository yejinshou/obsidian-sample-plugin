import { App, PluginSettingTab, Setting } from 'obsidian';
import type MyPlugin from '../main';

export class SampleSettingTab extends PluginSettingTab {
	plugin: MyPlugin;

	constructor(app: App, plugin: MyPlugin) {
		super(app, plugin);
		this.plugin = plugin;
	}

	display(): void {
		const { containerEl } = this;

		containerEl.empty();

		containerEl.createEl('h2', { text: 'Plugin Settings' });

		new Setting(containerEl)
			.setName('Setting #1')
			.setDesc('It\'s a secret')
			.addText(text => text
				.setPlaceholder('Enter your secret')
				.setValue(this.plugin.settings.mySetting)
				.onChange(async (value) => {
					this.plugin.settings.mySetting = value;
					await this.plugin.saveSettings();
				}));

		new Setting(containerEl)
			.setName('Enable Notifications')
			.setDesc('Show notifications for plugin events')
			.addToggle(toggle => toggle
				.setValue(this.plugin.settings.enableNotifications)
				.onChange(async (value) => {
					this.plugin.settings.enableNotifications = value;
					await this.plugin.saveSettings();
				}));

		new Setting(containerEl)
			.setName('API Key')
			.setDesc('Enter your API key')
			.addText(text => text
				.setPlaceholder('Enter API key')
				.setValue(this.plugin.settings.apiKey)
				.onChange(async (value) => {
					this.plugin.settings.apiKey = value;
					await this.plugin.saveSettings();
				}));

		new Setting(containerEl)
			.setName('Refresh Interval')
			.setDesc('How often to refresh data (in seconds)')
			.addSlider(slider => slider
				.setLimits(1, 60, 1)
				.setValue(this.plugin.settings.refreshInterval)
				.setDynamicTooltip()
				.onChange(async (value) => {
					this.plugin.settings.refreshInterval = value;
					await this.plugin.saveSettings();
				}));
	}
}
