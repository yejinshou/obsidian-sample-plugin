import { App, Modal } from 'obsidian';

export class SampleModal extends Modal {
	constructor(app: App) {
		super(app);
	}

	onOpen() {
		const { contentEl } = this;
		contentEl.setText('Woah! This is a modal from the refactored plugin!');
	}

	onClose() {
		const { contentEl } = this;
		contentEl.empty();
	}
}
