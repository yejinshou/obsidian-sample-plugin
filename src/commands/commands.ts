import { Editor, MarkdownView, Notice } from 'obsidian';
import type MyPlugin from '../main';
import { SampleModal } from '../ui/modal';

export function registerCommands(plugin: MyPlugin): void {
	// Simple command to open modal
	plugin.addCommand({
		id: 'open-sample-modal-simple',
		name: 'Open sample modal (simple)',
		callback: () => {
			new SampleModal(plugin.app).open();
		}
	});

	// Editor command
	plugin.addCommand({
		id: 'sample-editor-command',
		name: 'Sample editor command',
		editorCallback: (editor: Editor, _view: MarkdownView) => {
			console.log(editor.getSelection());
			editor.replaceSelection('Sample Editor Command');
			new Notice('Editor command executed!');
		}
	});

	// Complex command with check callback
	plugin.addCommand({
		id: 'open-sample-modal-complex',
		name: 'Open sample modal (complex)',
		checkCallback: (checking: boolean) => {
			const markdownView = plugin.app.workspace.getActiveViewOfType(MarkdownView);
			if (markdownView) {
				if (!checking) {
					new SampleModal(plugin.app).open();
				}
				return true;
			}
			return false;
		}
	});

	// Additional command to show settings
	plugin.addCommand({
		id: 'show-plugin-info',
		name: 'Show plugin information',
		callback: () => {
			new Notice(`Plugin loaded with settings: ${JSON.stringify(plugin.settings)}`);
		}
	});
}
