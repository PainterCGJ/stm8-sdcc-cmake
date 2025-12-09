@echo off
REM STM8L052C6 构建脚本
REM 使用方法: build.bat [项目目录]
REM 例如: build.bat source\app

setlocal enabledelayedexpansion

set PROJECT_DIR=%1
if "%PROJECT_DIR%"=="" (
    echo 错误: 请指定项目目录
    echo 使用方法: build.bat [项目目录]
    echo 例如: build.bat source\app
    exit /b 1
)

set BUILD_DIR=build\%PROJECT_DIR%
set CMAKE_TOOLCHAIN_FILE=%~dp0cmake\sdcc-generic.cmake
set CMAKE_MODULE_PATH=%~dp0cmake
set STM8_CHIP=stm8l052c6
set STM8_StdPeriph_DIR=%~dp0source\StdPeriph

echo ========================================
echo STM8L052C6 构建脚本
echo ========================================
echo 项目目录: %PROJECT_DIR%
echo 构建目录: %BUILD_DIR%
echo ========================================

REM 创建构建目录
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

REM 配置CMake
echo.
echo [1/2] 配置CMake...
cmake ^
    -DCMAKE_TOOLCHAIN_FILE=%CMAKE_TOOLCHAIN_FILE% ^
    -DCMAKE_MODULE_PATH=%CMAKE_MODULE_PATH% ^
    -DSTM8_CHIP=%STM8_CHIP% ^
    -DSTM8_StdPeriph_DIR=%STM8_StdPeriph_DIR% ^
    -G "Ninja" ^
    -S "%PROJECT_DIR%" ^
    -B "%BUILD_DIR%"

if errorlevel 1 (
    echo CMake配置失败!
    exit /b 1
)

REM 构建项目
echo.
echo [2/2] 构建项目...
cmake --build "%BUILD_DIR%"

if errorlevel 1 (
    echo 构建失败!
    exit /b 1
)

echo.
echo ========================================
echo 构建完成!
echo 输出文件: %BUILD_DIR%\%PROJECT_DIR%.ihx
echo ========================================

endlocal


