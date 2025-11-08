# Dart Integration Guide

## 在Obsidian插件中集成Dart代码

### 概述

虽然Obsidian插件最终需要JavaScript，但您可以使用Dart编写部分功能，然后编译为JavaScript。本指南介绍三种集成方法。

---

## 方法1: dart2js (推荐用于纯Dart逻辑)

### 适用场景
- 纯业务逻辑
- 数据处理算法
- 不需要Flutter框架的功能

### 步骤

#### 1. 安装Dart SDK
```bash
# macOS
brew tap dart-lang/dart
brew install dart

# Linux
sudo apt-get update
sudo apt-get install dart

# Windows
choco install dart-sdk
```

#### 2. 创建Dart文件
```dart
// src/dart/dataProcessor.dart
class DataProcessor {
  static String processText(String input) {
    return input.toUpperCase();
  }
  
  static Map<String, dynamic> analyzeData(List<dynamic> data) {
    return {
      'count': data.length,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}

// Export for JavaScript interop
void main() {
  // Empty - functions will be called from JS
}
```

#### 3. 编译为JavaScript
```bash
# 编译单个文件
dart compile js src/dart/dataProcessor.dart -o src/dart/dataProcessor.js

# 优化选项
dart compile js src/dart/dataProcessor.dart -o src/dart/dataProcessor.js -O2
```

#### 4. 在TypeScript中使用
```typescript
// src/utils/dartBridge.ts
declare global {
  interface Window {
    DataProcessor: any;
  }
}

// 动态加载Dart编译的JS
export async function loadDartModule(modulePath: string): Promise<void> {
  return new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src = modulePath;
    script.onload = () => resolve();
    script.onerror = reject;
    document.head.appendChild(script);
  });
}

// 使用Dart函数
export async function initializeDart(): Promise<void> {
  await loadDartModule('dart/dataProcessor.js');
  
  const result = window.DataProcessor.processText('hello world');
  console.log(result); // "HELLO WORLD"
}
```

### 优缺点

✅ **优点**:
- 完全编译为JavaScript
- 可以利用Dart的类型安全
- 输出单个JS文件

❌ **缺点**:
- 输出文件较大
- 不支持Flutter UI组件
- 调试较困难

---

## 方法2: Flutter Web + JS互操作

### 适用场景
- 需要复杂UI组件
- 使用Flutter widget库
- 跨平台代码复用

### 架构
```
TypeScript Plugin (main.js)
    ↓ postMessage
Flutter Web App (iframe)
    ↓ dart2js
JavaScript Bundle
```

### 实现步骤

#### 1. 创建Flutter项目
```bash
flutter create flutter_ui
cd flutter_ui
```

#### 2. 实现JS互操作
```dart
// lib/obsidian_bridge.dart
import 'dart:html' as html;
import 'dart:js' as js;

class ObsidianBridge {
  // 发送消息到Obsidian
  static void sendToObsidian(String type, dynamic data) {
    html.window.parent?.postMessage({
      'type': type,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, '*');
  }
  
  // 监听来自Obsidian的消息
  static void listenToObsidian(Function(dynamic) callback) {
    html.window.onMessage.listen((event) {
      final data = event.data;
      if (data is Map && data['source'] == 'obsidian') {
        callback(data);
      }
    });
  }
  
  // 调用Obsidian API（通过JS）
  static dynamic callObsidianAPI(String method, List<dynamic> args) {
    return js.context.callMethod('obsidianAPI', [method, ...args]);
  }
}
```

#### 3. 构建Flutter Web
```bash
cd flutter_ui
flutter build web --release

# 输出在 build/web/
# 包含: index.html, main.dart.js, flutter.js
```

#### 4. 在插件中集成
```typescript
// src/ui/flutterView.ts
import { ItemView, WorkspaceLeaf } from 'obsidian';

export class FlutterView extends ItemView {
  iframe: HTMLIFrameElement;
  
  async onOpen() {
    const container = this.containerEl.children[1];
    container.empty();
    
    // 创建iframe加载Flutter Web
    this.iframe = container.createEl('iframe', {
      attr: {
        src: 'flutter_ui/build/web/index.html',
        style: 'width: 100%; height: 100%; border: none;'
      }
    });
    
    // 监听Flutter消息
    window.addEventListener('message', this.handleFlutterMessage.bind(this));
  }
  
  handleFlutterMessage(event: MessageEvent) {
    const { type, data } = event.data;
    console.log('Message from Flutter:', type, data);
    // 处理来自Flutter的消息
  }
  
  sendToFlutter(type: string, data: any) {
    this.iframe.contentWindow?.postMessage({
      source: 'obsidian',
      type: type,
      data: data
    }, '*');
  }
}
```

### 优缺点

✅ **优点**:
- 完整的Flutter UI支持
- 丰富的widget库
- 良好的开发体验

❌ **缺点**:
- 输出包含多个文件（HTML, JS, assets）
- 体积较大（2-5MB）
- 需要iframe隔离

---

## 方法3: WebAssembly (实验性)

### 适用场景
- 高性能计算
- 现有Dart/C++代码
- 需要接近原生性能

### 步骤

#### 1. 编译Dart为WASM
```bash
# 需要Dart 3.x+
dart compile wasm src/dart/processor.dart -o assets/processor.wasm
```

#### 2. 在JS中加载WASM
```typescript
async function loadWasm() {
  const response = await fetch('assets/processor.wasm');
  const buffer = await response.arrayBuffer();
  const module = await WebAssembly.compile(buffer);
  const instance = await WebAssembly.instantiate(module);
  return instance.exports;
}
```

### 优缺点

✅ **优点**:
- 高性能
- 体积较小
- 接近原生速度

❌ **缺点**:
- Dart WASM支持实验性
- 调试困难
- 浏览器兼容性问题

---

## 最佳实践建议

### 选择合适的方法

| 需求 | 推荐方法 | 原因 |
|------|---------|------|
| 纯逻辑/算法 | dart2js | 简单直接 |
| 复杂UI | Flutter Web | 完整支持 |
| 高性能计算 | WASM | 性能最佳 |
| 小型工具函数 | 直接用TS | 最简单 |

### 构建流程

#### 自动化构建脚本
```bash
#!/bin/bash
# build-with-dart.sh

echo "Building Dart modules..."
dart compile js src/dart/module1.dart -o src/dart/module1.js -O2
dart compile js src/dart/module2.dart -o src/dart/module2.js -O2

echo "Building TypeScript..."
npm run build

echo "Copying files..."
cp main.js dist/
cp src/dart/*.js dist/dart/

echo "Build complete!"
```

#### package.json 脚本
```json
{
  "scripts": {
    "build:dart": "dart compile js src/dart/module.dart -o src/dart/module.js -O2",
    "build:ts": "node esbuild.config.mjs production",
    "build": "npm run build:dart && npm run build:ts",
    "build:flutter": "cd flutter_ui && flutter build web --release && cd ..",
    "build:all": "npm run build:flutter && npm run build"
  }
}
```

### 目录结构建议
```
obsidian-sample-plugin/
├── src/
│   ├── dart/               # Dart源文件
│   │   ├── module1.dart
│   │   ├── module2.dart
│   │   ├── module1.js      # dart2js输出（.gitignore）
│   │   └── module2.js      # dart2js输出（.gitignore）
│   ├── main.ts             # TypeScript入口
│   └── ...
├── flutter_ui/             # Flutter Web项目（可选）
│   ├── lib/
│   └── build/web/          # Flutter构建输出（.gitignore）
└── dist/                   # 最终输出
    ├── main.js             # 主JS文件
    └── dart/               # Dart编译的JS（可选）
```

### .gitignore 配置
```gitignore
# Dart编译输出
src/dart/*.js
src/dart/*.js.map

# Flutter构建
flutter_ui/build/
flutter_ui/.dart_tool/

# 最终构建产物
dist/
main.js
*.js.map
```

---

## 示例：完整集成

### 1. Dart数据处理器
```dart
// src/dart/textAnalyzer.dart
class TextAnalyzer {
  static Map<String, dynamic> analyze(String text) {
    return {
      'length': text.length,
      'words': text.split(' ').length,
      'chars': text.split('').length,
      'uppercase': text.toUpperCase(),
      'lowercase': text.toLowerCase(),
    };
  }
}

@JS()
library text_analyzer;

import 'package:js/js.dart';

@JS('TextAnalyzer')
external void registerTextAnalyzer();
```

### 2. TypeScript集成
```typescript
// src/utils/textAnalyzer.ts
interface TextAnalysis {
  length: number;
  words: number;
  chars: number;
  uppercase: string;
  lowercase: string;
}

declare global {
  interface Window {
    TextAnalyzer: {
      analyze(text: string): TextAnalysis;
    };
  }
}

export async function analyzeText(text: string): Promise<TextAnalysis> {
  if (!window.TextAnalyzer) {
    await loadDartModule('dart/textAnalyzer.js');
  }
  return window.TextAnalyzer.analyze(text);
}

// 在插件中使用
import { Notice } from 'obsidian';
import { analyzeText } from './utils/textAnalyzer';

async function handleTextAnalysis(text: string) {
  const result = await analyzeText(text);
  new Notice(`Words: ${result.words}, Chars: ${result.chars}`);
}
```

---

## 性能对比

| 方法 | 编译时间 | 输出大小 | 运行性能 | 开发体验 |
|------|---------|---------|---------|---------|
| Pure TypeScript | ⭐⭐⭐ | ~5KB | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| dart2js | ⭐⭐ | ~500KB | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| Flutter Web | ⭐ | ~2MB | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| WASM | ⭐⭐ | ~100KB | ⭐⭐⭐⭐⭐ | ⭐⭐ |

---

## 故障排除

### Dart编译失败
```bash
# 检查Dart版本
dart --version

# 清理缓存
dart pub cache clean

# 重新获取依赖
dart pub get
```

### JS互操作问题
- 确保使用 `@JS()` 注解
- 添加 `package:js/js.dart` 依赖
- 检查JS方法名是否正确

### 性能问题
- 使用 `-O2` 优化选项编译
- 启用代码分割
- 懒加载Dart模块

---

## 总结

集成Dart到Obsidian插件是可行的，但需要权衡：

1. **简单逻辑**: 直接用TypeScript
2. **复杂算法**: 使用dart2js
3. **UI组件**: 使用Flutter Web
4. **高性能**: 考虑WASM

最终输出始终是JavaScript文件，满足Obsidian插件的要求。
