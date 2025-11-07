# Project Understanding: Obsidian Sample Plugin & Obsidian API

## Overview

This document demonstrates a comprehensive understanding of the Obsidian Sample Plugin project and the Obsidian API (https://github.com/obsidianmd/obsidian-api).

## About This Project

### Purpose
This is a sample/template project for developing Obsidian plugins. It serves as a starting point for plugin developers and demonstrates the fundamental capabilities of the Obsidian Plugin API.

### Technology Stack
- **Language**: TypeScript (compiled to JavaScript)
- **Build Tool**: esbuild (fast JavaScript bundler)
- **Package Manager**: npm
- **Runtime**: Runs inside Obsidian app (Electron-based)
- **API**: Obsidian Plugin API (TypeScript definitions)

### Project Structure
```
.
├── main.ts              # Main plugin entry point (source)
├── main.js              # Compiled output (generated, not in git)
├── manifest.json        # Plugin metadata
├── package.json         # npm dependencies and scripts
├── tsconfig.json        # TypeScript configuration
├── esbuild.config.mjs   # Build configuration
├── styles.css           # Optional plugin styles
└── README.md            # Documentation
```

## Understanding the Obsidian API

### What is the Obsidian API?

The Obsidian API is a TypeScript/JavaScript interface that allows developers to extend Obsidian's functionality through plugins. The API is distributed as TypeScript type definitions (`obsidian.d.ts`) via the npm package `obsidian`.

**Repository**: https://github.com/obsidianmd/obsidian-api

### Key Components of the Obsidian API

#### 1. Plugin Base Class
Every plugin extends the `Plugin` class and implements lifecycle methods:
- `onload()`: Called when plugin is enabled
- `onunload()`: Called when plugin is disabled

#### 2. App Object
The central interface to Obsidian's functionality, accessible via `this.app`:
- **Vault**: File system access (read/write/delete files)
- **Workspace**: UI management (views, panes, leaves)
- **MetadataCache**: Fast access to file metadata, links, tags
- **FileManager**: High-level file operations

#### 3. Plugin Capabilities

##### Commands
Add new commands to the Command Palette:
```typescript
this.addCommand({
  id: 'my-command',
  name: 'My Command',
  callback: () => { /* action */ }
});
```

##### Ribbon Icons
Add clickable icons to the left sidebar:
```typescript
this.addRibbonIcon('dice', 'Tooltip', (evt) => {
  // Handle click
});
```

##### Settings
Provide configuration UI:
```typescript
this.addSettingTab(new MySettingTab(this.app, this));
```

##### Events
Listen to app events:
```typescript
this.registerEvent(
  this.app.workspace.on('file-open', (file) => {
    // Handle file open
  })
);
```

##### DOM Events
Listen to DOM events with automatic cleanup:
```typescript
this.registerDomEvent(document, 'click', (evt) => {
  // Handle click
});
```

##### Intervals
Register intervals that are automatically cleared:
```typescript
this.registerInterval(
  window.setInterval(() => { /* periodic task */ }, 5000)
);
```

##### Modals
Create custom dialogs:
```typescript
class MyModal extends Modal {
  onOpen() {
    // Populate modal content
  }
  onClose() {
    // Clean up
  }
}
```

##### Views
Create custom panes/tabs:
```typescript
class MyView extends ItemView {
  getViewType(): string { return 'my-view'; }
  getDisplayText(): string { return 'My View'; }
  async onOpen() { /* render */ }
}
```

## This Sample Plugin Demonstrates

### 1. Ribbon Icon
Creates a dice icon in the left sidebar that shows a notice when clicked.

**Code**: `main.ts` lines 20-25
```typescript
const ribbonIconEl = this.addRibbonIcon('dice', 'Sample Plugin', (_evt: MouseEvent) => {
  new Notice('This is a notice!');
});
```

### 2. Status Bar
Adds text to the status bar at the bottom of the app.

**Code**: `main.ts` lines 28-29
```typescript
const statusBarItemEl = this.addStatusBarItem();
statusBarItemEl.setText('Status Bar Text');
```

### 3. Commands
Demonstrates three types of commands:

#### Simple Command
Opens a modal when triggered.

**Code**: `main.ts` lines 32-38

#### Editor Command
Operates on the active editor, replacing selected text.

**Code**: `main.ts` lines 40-47

#### Conditional Command
Only available when certain conditions are met (e.g., markdown view is active).

**Code**: `main.ts` lines 49-66

### 4. Modal Dialog
A simple modal that displays "Woah!" when opened.

**Code**: `main.ts` lines 94-108

### 5. Settings Tab
Demonstrates plugin settings with persistence.

**Code**: `main.ts` lines 110-134
- Shows a text input for a "secret" setting
- Persists settings using `loadData()`/`saveData()`
- Automatically saves on change

### 6. Event Listeners
#### DOM Event
Logs all clicks on the document.

**Code**: `main.ts` lines 73-75

#### Interval
Logs a message every 5 minutes.

**Code**: `main.ts` lines 78

### 7. Settings Persistence
Shows how to:
- Define settings interface
- Set defaults
- Load settings on plugin start
- Save settings on change

**Code**: `main.ts` lines 5-11, 85-91

## Build Process

### Development Build (Watch Mode)
```bash
npm run dev
```
- Watches for file changes
- Automatically rebuilds
- Includes source maps for debugging
- No minification

### Production Build
```bash
npm run build
```
- Type checks with TypeScript
- Bundles with esbuild
- Minified output
- No source maps
- Output: `main.js` (~2.2KB for this sample)

### Build Configuration
**File**: `esbuild.config.mjs`
- Entry point: `main.ts`
- Output: `main.js`
- Format: CommonJS (CJS)
- Target: ES2018
- External dependencies: obsidian, electron, codemirror (provided by Obsidian)
- Bundles all other dependencies

## Plugin Installation & Usage

### Manual Installation
1. Copy to vault: `<VaultFolder>/.obsidian/plugins/sample-plugin/`
2. Files needed:
   - `main.js` (compiled output)
   - `manifest.json` (metadata)
   - `styles.css` (if used)
3. Reload Obsidian
4. Enable in **Settings → Community plugins**

### Development Workflow
1. Clone repo to `.obsidian/plugins/your-plugin-name/`
2. Run `npm install`
3. Run `npm run dev` (watch mode)
4. Make changes to `main.ts`
5. Reload Obsidian to test changes

## Manifest Structure

**File**: `manifest.json`

Required fields:
- `id`: Unique plugin identifier (must match folder name)
- `name`: Display name
- `version`: Semantic version (x.y.z)
- `minAppVersion`: Minimum Obsidian version required
- `description`: Brief description
- `author`: Author name
- `authorUrl`: Author's website
- `isDesktopOnly`: Whether plugin works on mobile

## TypeScript Configuration

**File**: `tsconfig.json`

Key settings:
- `target: "ES6"`: JavaScript version
- `module: "ESNext"`: Module system
- `strictNullChecks: true`: Type safety
- `noImplicitAny: true`: Require type annotations
- Includes source maps for debugging

## Key Concepts

### Plugin Lifecycle
1. **Load**: `onload()` called when plugin enabled
   - Register commands, UI elements, events
   - Load settings
   - Initialize state

2. **Active**: Plugin is running
   - Commands available
   - Event listeners active
   - UI elements visible

3. **Unload**: `onunload()` called when plugin disabled
   - Clean up resources
   - Remove UI elements
   - Unregister events (automatic with `register*` methods)

### Resource Management
The API provides automatic cleanup methods:
- `this.registerEvent()`: Auto-unregisters event listeners
- `this.registerDomEvent()`: Auto-removes DOM listeners
- `this.registerInterval()`: Auto-clears intervals
- `this.addRibbonIcon()`: Auto-removes ribbon icon
- `this.addStatusBarItem()`: Auto-removes status bar item

This ensures plugins clean up properly when disabled.

### Data Persistence
Plugins can persist data:
```typescript
// Load (returns any JSON-serializable data)
const data = await this.loadData();

// Save (accepts any JSON-serializable data)
await this.saveData(myData);
```

Data is stored in `<VaultFolder>/.obsidian/plugins/<plugin-id>/data.json`

## Best Practices (from AGENTS.md)

### Code Organization
- Keep `main.ts` minimal (lifecycle only)
- Split functionality into separate modules
- Use clear module boundaries
- Avoid large files (>200-300 lines)

### Performance
- Keep `onload()` light
- Defer heavy work until needed
- Batch disk access
- Debounce expensive operations

### Security & Privacy
- Default to local/offline operation
- No hidden telemetry
- Require explicit opt-in for network requests
- Never execute remote code
- Respect user privacy

### Mobile Compatibility
- Test on iOS and Android if `isDesktopOnly: false`
- Avoid Node.js/Electron APIs for mobile support
- Be mindful of memory constraints

### Versioning
- Use Semantic Versioning
- Update `manifest.json` version
- Update `versions.json` (maps plugin version → min Obsidian version)
- Create GitHub release with exact version tag
- Attach `main.js`, `manifest.json`, `styles.css` to release

## Related Resources

- **Obsidian API Repository**: https://github.com/obsidianmd/obsidian-api
- **API Documentation**: https://docs.obsidian.md
- **Sample Plugin**: https://github.com/obsidianmd/obsidian-sample-plugin
- **Plugin Guidelines**: https://docs.obsidian.md/Plugins/Releasing/Plugin+guidelines
- **Developer Policies**: https://docs.obsidian.md/Developer+policies
- **Style Guide**: https://help.obsidian.md/style-guide

## Conclusion

This sample plugin effectively demonstrates the core capabilities of the Obsidian Plugin API:
1. **UI Extensions**: Ribbon icons, status bar, modals
2. **Commands**: Various types with different triggers
3. **Settings**: Persistent configuration with UI
4. **Events**: DOM and app event handling
5. **Lifecycle**: Proper resource management

The plugin serves as an excellent starting point for developers looking to extend Obsidian's functionality while following best practices for plugin development.
