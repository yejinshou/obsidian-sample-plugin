#!/bin/bash

# Flutter Hybrid Plugin Deployment Script
# 用于自动编译和部署插件到Obsidian

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 设置你的Obsidian保管库路径（必须修改为你的实际路径）
VAULT_PATH="$HOME/Documents/ObsidianVault"

# 如果传入参数，使用参数作为vault路径
if [ -n "$1" ]; then
    VAULT_PATH="$1"
fi

PLUGIN_DIR="$VAULT_PATH/.obsidian/plugins/flutter-hybrid-plugin"

echo -e "${YELLOW}Flutter Hybrid Plugin 部署脚本${NC}"
echo "================================================"

# 检查Flutter是否安装
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}错误: 未找到Flutter。请先安装Flutter SDK。${NC}"
    echo "访问: https://docs.flutter.dev/get-started/install"
    exit 1
fi

# 检查Node.js是否安装
if ! command -v node &> /dev/null; then
    echo -e "${RED}错误: 未找到Node.js。请先安装Node.js。${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} 环境检查通过"

# 步骤1: 安装依赖
echo ""
echo "步骤 1/5: 安装依赖..."
if [ ! -d "node_modules" ]; then
    echo "安装npm依赖..."
    npm install
fi

if [ ! -d "flutter_ui/.dart_tool" ]; then
    echo "安装Flutter依赖..."
    cd flutter_ui
    flutter pub get
    cd ..
fi
echo -e "${GREEN}✓${NC} 依赖安装完成"

# 步骤2: 编译Flutter Web应用
echo ""
echo "步骤 2/5: 编译Flutter Web应用..."
cd flutter_ui
flutter build web --release
if [ $? -ne 0 ]; then
    echo -e "${RED}错误: Flutter编译失败${NC}"
    exit 1
fi
cd ..
echo -e "${GREEN}✓${NC} Flutter编译完成"

# 步骤3: 编译TypeScript插件
echo ""
echo "步骤 3/5: 编译TypeScript插件..."

# 临时修改esbuild配置以使用flutter-main.ts
if grep -q 'entryPoints: \["main.ts"\]' esbuild.config.mjs; then
    sed -i.bak 's/entryPoints: \["main.ts"\]/entryPoints: ["flutter-main.ts"]/' esbuild.config.mjs
    RESTORE_CONFIG=true
fi

npm run build
if [ $? -ne 0 ]; then
    echo -e "${RED}错误: TypeScript编译失败${NC}"
    [ "$RESTORE_CONFIG" = true ] && mv esbuild.config.mjs.bak esbuild.config.mjs
    exit 1
fi

# 恢复配置文件
[ "$RESTORE_CONFIG" = true ] && mv esbuild.config.mjs.bak esbuild.config.mjs

echo -e "${GREEN}✓${NC} TypeScript编译完成"

# 步骤4: 创建插件目录并复制文件
echo ""
echo "步骤 4/5: 复制文件到Obsidian插件目录..."
mkdir -p "$PLUGIN_DIR/flutter_ui/build"

# 复制主文件
cp main.js "$PLUGIN_DIR/"
cp manifest.json "$PLUGIN_DIR/"

# 复制Flutter Web构建输出
cp -r flutter_ui/build/web "$PLUGIN_DIR/flutter_ui/build/"

# 可选：复制styles.css（如果存在）
if [ -f "styles.css" ]; then
    cp styles.css "$PLUGIN_DIR/"
fi

echo -e "${GREEN}✓${NC} 文件复制完成"

# 步骤5: 验证部署
echo ""
echo "步骤 5/5: 验证部署..."
if [ -f "$PLUGIN_DIR/main.js" ] && [ -f "$PLUGIN_DIR/manifest.json" ] && [ -d "$PLUGIN_DIR/flutter_ui/build/web" ]; then
    echo -e "${GREEN}✓${NC} 部署验证成功"
else
    echo -e "${RED}错误: 部署验证失败，某些文件缺失${NC}"
    exit 1
fi

# 显示部署信息
echo ""
echo "================================================"
echo -e "${GREEN}部署完成！${NC}"
echo ""
echo "插件位置: $PLUGIN_DIR"
echo ""
echo "接下来的步骤:"
echo "1. 打开Obsidian"
echo "2. 进入 设置 → 社区插件"
echo "3. 关闭安全模式（如果已开启）"
echo "4. 点击'重新加载插件'"
echo "5. 启用 'Flutter Hybrid Plugin'"
echo ""
echo "使用方法:"
echo "- 点击左侧功能区的仪表板图标"
echo "- 或使用命令面板: Ctrl/Cmd+P → 输入 'Open Flutter UI'"
echo "================================================"
