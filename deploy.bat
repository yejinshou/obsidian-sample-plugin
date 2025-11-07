@echo off
REM Flutter Hybrid Plugin Deployment Script for Windows
REM 用于自动编译和部署插件到Obsidian

setlocal enabledelayedexpansion

REM 设置你的Obsidian保管库路径（必须修改为你的实际路径）
set "VAULT_PATH=C:\Users\%USERNAME%\Documents\ObsidianVault"

REM 如果传入参数，使用参数作为vault路径
if not "%~1"=="" set "VAULT_PATH=%~1"

set "PLUGIN_DIR=%VAULT_PATH%\.obsidian\plugins\flutter-hybrid-plugin"

echo ========================================
echo Flutter Hybrid Plugin 部署脚本
echo ========================================
echo.

REM 检查Flutter是否安装
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 未找到Flutter。请先安装Flutter SDK。
    echo 访问: https://docs.flutter.dev/get-started/install
    exit /b 1
)

REM 检查Node.js是否安装
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 未找到Node.js。请先安装Node.js。
    exit /b 1
)

echo [成功] 环境检查通过
echo.

REM 步骤1: 安装依赖
echo 步骤 1/5: 安装依赖...
if not exist "node_modules" (
    echo 安装npm依赖...
    call npm install
)

if not exist "flutter_ui\.dart_tool" (
    echo 安装Flutter依赖...
    cd flutter_ui
    call flutter pub get
    cd ..
)
echo [成功] 依赖安装完成
echo.

REM 步骤2: 编译Flutter Web应用
echo 步骤 2/5: 编译Flutter Web应用...
cd flutter_ui
call flutter build web --release
if %ERRORLEVEL% NEQ 0 (
    echo [错误] Flutter编译失败
    cd ..
    exit /b 1
)
cd ..
echo [成功] Flutter编译完成
echo.

REM 步骤3: 编译TypeScript插件
echo 步骤 3/5: 编译TypeScript插件...

REM 备份配置文件
copy esbuild.config.mjs esbuild.config.mjs.bak >nul

REM 临时修改esbuild配置以使用flutter-main.ts
powershell -Command "(Get-Content esbuild.config.mjs) -replace 'entryPoints: \[\"main.ts\"\]', 'entryPoints: [\"flutter-main.ts\"]' | Set-Content esbuild.config.mjs"

call npm run build
set BUILD_RESULT=%ERRORLEVEL%

REM 恢复配置文件
move /Y esbuild.config.mjs.bak esbuild.config.mjs >nul

if %BUILD_RESULT% NEQ 0 (
    echo [错误] TypeScript编译失败
    exit /b 1
)

echo [成功] TypeScript编译完成
echo.

REM 步骤4: 创建插件目录并复制文件
echo 步骤 4/5: 复制文件到Obsidian插件目录...
if not exist "%PLUGIN_DIR%\flutter_ui\build" mkdir "%PLUGIN_DIR%\flutter_ui\build"

REM 复制主文件
copy main.js "%PLUGIN_DIR%\" >nul
copy manifest.json "%PLUGIN_DIR%\" >nul

REM 复制Flutter Web构建输出
xcopy /E /I /Y flutter_ui\build\web "%PLUGIN_DIR%\flutter_ui\build\web" >nul

REM 可选：复制styles.css（如果存在）
if exist "styles.css" copy styles.css "%PLUGIN_DIR%\" >nul

echo [成功] 文件复制完成
echo.

REM 步骤5: 验证部署
echo 步骤 5/5: 验证部署...
if exist "%PLUGIN_DIR%\main.js" if exist "%PLUGIN_DIR%\manifest.json" if exist "%PLUGIN_DIR%\flutter_ui\build\web" (
    echo [成功] 部署验证成功
) else (
    echo [错误] 部署验证失败，某些文件缺失
    exit /b 1
)
echo.

REM 显示部署信息
echo ========================================
echo 部署完成！
echo.
echo 插件位置: %PLUGIN_DIR%
echo.
echo 接下来的步骤:
echo 1. 打开Obsidian
echo 2. 进入 设置 → 社区插件
echo 3. 关闭安全模式（如果已开启）
echo 4. 点击'重新加载插件'
echo 5. 启用 'Flutter Hybrid Plugin'
echo.
echo 使用方法:
echo - 点击左侧功能区的仪表板图标
echo - 或使用命令面板: Ctrl/Cmd+P → 输入 'Open Flutter UI'
echo ========================================
echo.
pause
