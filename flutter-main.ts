import { App, Plugin, PluginSettingTab, Setting, ItemView, WorkspaceLeaf } from 'obsidian';

interface FlutterPluginSettings {
	enableNotifications: boolean;
	apiKey: string;
	refreshInterval: number;
}

const DEFAULT_SETTINGS: FlutterPluginSettings = {
	enableNotifications: true,
	apiKey: '',
	refreshInterval: 5
}

export default class FlutterHybridPlugin extends Plugin {
	settings: FlutterPluginSettings;

	async onload() {
		await this.loadSettings();

		// Register the Flutter UI view
		this.registerView(
			'flutter-ui-view',
			(leaf) => new FlutterUIView(leaf, this)
		);

		// Add ribbon icon to open Flutter UI
		this.addRibbonIcon('layout-dashboard', 'Open Flutter UI', () => {
			this.activateView();
		});

		// Add command to open Flutter UI
		this.addCommand({
			id: 'open-flutter-ui',
			name: 'Open Flutter UI',
			callback: () => {
				this.activateView();
			}
		});

		// Add settings tab
		this.addSettingTab(new FlutterPluginSettingTab(this.app, this));

		console.log('Flutter Hybrid Plugin loaded');
	}

	onunload() {
		console.log('Flutter Hybrid Plugin unloaded');
	}

	async loadSettings() {
		this.settings = Object.assign({}, DEFAULT_SETTINGS, await this.loadData());
	}

	async saveSettings() {
		await this.saveData(this.settings);
	}

	async activateView() {
		const { workspace } = this.app;

		let leaf: WorkspaceLeaf | null = null;
		const leaves = workspace.getLeavesOfType('flutter-ui-view');

		if (leaves.length > 0) {
			// A leaf with our view already exists, use that
			leaf = leaves[0];
		} else {
			// Our view could not be found in the workspace, create a new leaf in the right sidebar for it
			const rightLeaf = workspace.getRightLeaf(false);
			if (rightLeaf) {
				leaf = rightLeaf;
				await leaf.setViewState({ type: 'flutter-ui-view', active: true });
			}
		}

		// Reveal the leaf in case it is in a collapsed sidebar
		if (leaf) {
			workspace.revealLeaf(leaf);
		}
	}
}

class FlutterUIView extends ItemView {
	plugin: FlutterHybridPlugin;
	iframe: HTMLIFrameElement;

	constructor(leaf: WorkspaceLeaf, plugin: FlutterHybridPlugin) {
		super(leaf);
		this.plugin = plugin;
	}

	getViewType(): string {
		return 'flutter-ui-view';
	}

	getDisplayText(): string {
		return 'Flutter UI';
	}

	getIcon(): string {
		return 'layout-dashboard';
	}

	async onOpen() {
		const container = this.containerEl.children[1];
		container.empty();
		container.addClass('flutter-ui-container');

		// Create iframe for Flutter Web app
		this.iframe = container.createEl('iframe', {
			attr: {
				src: 'app://obsidian.md/flutter_ui/build/web/index.html',
				style: 'width: 100%; height: 100%; border: none;'
			}
		});

		// Set up message listener for Flutter -> Obsidian communication
		window.addEventListener('message', this.handleMessage.bind(this));

		// Send initial settings when iframe loads
		this.iframe.onload = () => {
			this.sendMessageToFlutter('obsidian-to-flutter', 'Connected to Obsidian!');
		};
	}

	async onClose() {
		window.removeEventListener('message', this.handleMessage.bind(this));
	}

	private handleMessage(event: MessageEvent) {
		const data = event.data;
		
		if (!data || typeof data !== 'object') return;

		switch (data.type) {
			case 'flutter-ready':
				console.log('Flutter UI ready:', data.message);
				// Send current settings to Flutter
				this.sendSettingsToFlutter();
				break;
			
			case 'flutter-to-obsidian':
				console.log('Message from Flutter:', data.message);
				// Handle messages from Flutter
				// You can add custom logic here
				break;
			
			case 'flutter-request-settings':
				this.sendSettingsToFlutter();
				break;
			
			case 'flutter-save-settings':
				if (data.settings) {
					Object.assign(this.plugin.settings, data.settings);
					this.plugin.saveSettings();
				}
				break;
		}
	}

	private sendMessageToFlutter(type: string, message: string) {
		if (this.iframe && this.iframe.contentWindow) {
			this.iframe.contentWindow.postMessage({
				type: type,
				message: message
			}, '*');
		}
	}

	private sendSettingsToFlutter() {
		if (this.iframe && this.iframe.contentWindow) {
			this.iframe.contentWindow.postMessage({
				type: 'obsidian-settings',
				...this.plugin.settings
			}, '*');
		}
	}
}

class FlutterPluginSettingTab extends PluginSettingTab {
	plugin: FlutterHybridPlugin;

	constructor(app: App, plugin: FlutterHybridPlugin) {
		super(app, plugin);
		this.plugin = plugin;
	}

	display(): void {
		const { containerEl } = this;
		containerEl.empty();

		containerEl.createEl('h2', { text: 'Flutter Hybrid Plugin Settings' });

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
