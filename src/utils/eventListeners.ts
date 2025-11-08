import type MyPlugin from '../main';

export function setupEventListeners(plugin: MyPlugin): void {
	// Register global DOM event
	plugin.registerDomEvent(document, 'click', (evt: MouseEvent) => {
		console.log('click', evt);
	});

	// Register interval
	plugin.registerInterval(
		window.setInterval(() => {
			console.log('setInterval - plugin is running');
		}, 5 * 60 * 1000)
	);
}
