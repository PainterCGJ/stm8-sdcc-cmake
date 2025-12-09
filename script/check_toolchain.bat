@echo off
REM 检查工具链配置脚本
REM 用于诊断CMake和SDCC工具链问题

echo ========================================
echo STM8 工具链诊断工具
echo ========================================
echo.

echo [1] 检查CMake...
where cmake >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] CMake 已找到
    cmake --version
    echo.
    echo CMake路径:
    where cmake
) else (
    echo [错误] CMake 未在PATH中找到
    echo 请确保CMake已安装并在PATH中
)
echo.

echo [2] 检查SDCC编译器...
where sdcc >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] SDCC 已找到
    sdcc --version
    echo.
    echo SDCC路径:
    where sdcc
) else (
    echo [错误] SDCC 未在PATH中找到
    echo 请确保SDCC已安装并在PATH中
)
echo.

echo [3] 检查Ninja...
where ninja >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Ninja 已找到
    ninja --version
    echo.
    echo Ninja路径:
    where ninja
) else (
    echo [警告] Ninja 未在PATH中找到
    echo 建议安装Ninja以加快构建速度
)
echo.

echo [4] 检查PATH中的Qt相关路径...
echo PATH中包含Qt的路径:
echo %PATH% | findstr /i "qt" >nul 2>&1
if %errorlevel% equ 0 (
    echo [警告] 检测到PATH中包含Qt路径
    echo 这可能导致CMake Tools使用Qt的CMake
    echo.
    echo 建议:
    echo 1. 在VSCode设置中明确指定CMake路径
    echo 2. 或将系统CMake路径放在Qt路径之前
) else (
    echo [OK] PATH中未检测到Qt路径
)
echo.

echo [5] 检查工具链文件...
if exist "cmake\sdcc-generic.cmake" (
    echo [OK] 工具链文件存在: cmake\sdcc-generic.cmake
) else (
    echo [错误] 工具链文件不存在
)
echo.

echo ========================================
echo 诊断完成
echo ========================================
echo.
echo 如果发现问题，请参考 TOOLCHAIN_DIAGNOSIS.md 获取解决方案

pause

