@echo off
REM 生成 compile_commands.json 的批处理脚本
REM 用于 Ninja 生成器（Ninja 不会自动生成 compile_commands.json）

set BUILD_DIR=build\stm8l-app
set SOURCE_DIR=source\app

echo 正在生成 compile_commands.json...

if not exist "%BUILD_DIR%" (
    echo 错误: 构建目录不存在: %BUILD_DIR%
    echo 请先运行 CMake 配置
    exit /b 1
)

cd /d "%BUILD_DIR%"

REM 尝试使用 CMake 3.20+ 的方法
cmake --build . --target %SOURCE_DIR% >nul 2>&1

REM 如果 compile_commands.json 不存在，使用备用方法
if not exist "compile_commands.json" (
    echo 使用备用方法生成 compile_commands.json...
    
    REM 这里可以添加手动生成逻辑
    REM 或者提示用户使用 PowerShell 脚本
    echo 请运行 PowerShell 脚本: script\generate_compile_commands.ps1
    cd /d ..
    exit /b 1
)

REM 复制到工作区根目录
if exist "compile_commands.json" (
    copy /Y "compile_commands.json" "..\..\compile_commands.json" >nul 2>&1
    echo 已在工作区根目录创建 compile_commands.json
)

cd /d ..
echo 完成!


