/**
 * Helper utilities for the plugin
 */

export function formatTimestamp(timestamp: number): string {
	return new Date(timestamp).toLocaleString();
}

export function debounce<T extends (...args: any[]) => any>(
	func: T,
	wait: number
): (...args: Parameters<T>) => void {
	let timeout: NodeJS.Timeout;
	return function executedFunction(...args: Parameters<T>) {
		const later = () => {
			clearTimeout(timeout);
			func(...args);
		};
		clearTimeout(timeout);
		timeout = setTimeout(later, wait);
	};
}

export function isValidApiKey(key: string): boolean {
	return key.length > 0 && key.length <= 256;
}
