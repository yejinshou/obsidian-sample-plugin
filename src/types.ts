/**
 * Type definitions for the plugin
 */

export interface PluginData {
	settings: any;
	cache: Map<string, any>;
}

export interface CommandContext {
	source: 'command-palette' | 'hotkey' | 'ribbon';
}

export type PluginEventType = 'settings-changed' | 'plugin-loaded' | 'plugin-unloaded';

export interface PluginEvent {
	type: PluginEventType;
	timestamp: number;
	data?: any;
}
