import type MyPlugin from '../main';

export interface MyPluginSettings {
	mySetting: string;
	enableNotifications: boolean;
	apiKey: string;
	refreshInterval: number;
}

export const DEFAULT_SETTINGS: MyPluginSettings = {
	mySetting: 'default',
	enableNotifications: true,
	apiKey: '',
	refreshInterval: 5
}

export async function loadSettings(plugin: MyPlugin): Promise<MyPluginSettings> {
	return Object.assign({}, DEFAULT_SETTINGS, await plugin.loadData());
}

export async function saveSettings(plugin: MyPlugin): Promise<void> {
	await plugin.saveData(plugin.settings);
}
