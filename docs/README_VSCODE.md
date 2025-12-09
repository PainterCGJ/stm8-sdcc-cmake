# VSCode 开发环境配置说明

## 概述

本项目已配置好VSCode开发环境，针对STM8L052C6芯片进行开发。

## 配置说明

### 1. 已禁用的插件
- Microsoft C/C++ 插件已禁用（因为SDCC编译器不兼容）

### 2. CMake配置
- 工具链文件: `cmake/sdcc-generic.cmake`
- 目标芯片: `stm8l052c6`
- 构建系统: Ninja
- 构建目录: `build/`

### 3. 推荐扩展
- CMake Tools (ms-vscode.cmake-tools)

## 使用方法

### 方法1: 使用VSCode任务

1. 按 `Ctrl+Shift+P` 打开命令面板
2. 输入 "Tasks: Run Task"
3. 选择以下任务之一:
   - **CMake: 配置** - 配置CMake项目
   - **CMake: 构建** - 构建项目（默认构建任务，快捷键 `Ctrl+Shift+B`）
   - **CMake: 清理** - 清理构建文件
   - **CMake: 重新配置并构建** - 重新配置并构建

### 方法2: 使用CMake Tools扩展

1. 安装 CMake Tools 扩展
2. 打开命令面板 (`Ctrl+Shift+P`)
3. 运行 "CMake: Configure" 配置项目
4. 运行 "CMake: Build" 构建项目

### 方法3: 使用命令行脚本

```bash
# 构建指定项目
script\build.bat stm8l-gpio
```

## 项目结构

```
stm8-sdcc-cmake-master/
├── .vscode/              # VSCode配置文件
│   ├── settings.json     # 工作区设置
│   ├── tasks.json        # 构建任务
│   ├── launch.json       # 调试配置
│   └── extensions.json   # 推荐扩展
├── cmake/                # CMake工具链文件
├── StdPeriph/            # STM8标准外设库
├── stm8l-gpio/           # GPIO示例项目
├── stm8l-blinky/         # LED闪烁示例项目
└── script/build.bat      # 快速构建脚本
```

## 构建输出

构建完成后，输出文件位于:
- `build/[项目名]/[项目名].ihx` - SDCC Intel Hex格式文件

## 注意事项

1. **Microsoft C/C++插件已禁用**: 因为SDCC编译器与Microsoft C/C++插件的IntelliSense不兼容，已禁用该插件。

2. **目标芯片**: 当前配置为STM8L052C6，如需更改，请修改:
   - `.vscode/settings.json` 中的 `cmake.configureArgs`
   - `.vscode/tasks.json` 中的任务参数
   - `script/build.bat` 中的 `STM8_CHIP` 变量

3. **环境要求**: 
   - CMake 2.8或更高版本
   - Ninja构建系统
   - SDCC编译器
   - 以上工具需在系统PATH中

## 调试

STM8调试需要外部调试器（如ST-Link）。`launch.json`中已包含调试配置模板，但需要根据实际调试器进行配置。

## 故障排除

### CMake配置失败
- 检查SDCC是否在PATH中: `sdcc --version`
- 检查CMake是否在PATH中: `cmake --version`
- 检查Ninja是否在PATH中: `ninja --version`

### 构建失败
- 检查目标芯片名称是否正确
- 检查StdPeriph库路径是否正确
- 查看构建输出中的错误信息


