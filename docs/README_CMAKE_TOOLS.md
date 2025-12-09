# CMake Tools 使用指南

## 概述

本项目已配置好 CMake Tools 扩展，提供了便捷的 CMake 项目管理功能。

## 安装扩展

1. 打开 VSCode
2. 按 `Ctrl+Shift+X` 打开扩展市场
3. 搜索并安装 **CMake Tools** (ms-vscode.cmake-tools)

## 快速开始

### 1. 选择配置预设

安装 CMake Tools 后，VSCode 状态栏会显示 CMake 相关信息。

#### 方式A：在根目录工作（推荐用于多项目管理）

1. 在项目根目录打开 VSCode
2. 点击状态栏的 **"CMake: [选择配置预设]"** 或按 `Ctrl+Shift+P`
3. 选择 **"CMake: Select Configure Preset"**
4. 选择以下预设之一：
   - **stm8l052c6** - 默认配置（根目录，用于整体管理）
   - **stm8l-gpio** - GPIO 示例项目
   - **stm8l-blinky** - Blinky 示例项目

#### 方式B：在子项目目录工作（推荐用于单个项目开发）

1. 打开子项目目录作为工作区（例如：`stm8l-gpio` 文件夹）
2. CMake Tools 会自动检测该目录的 `CMakePresets.json`
3. 使用默认预设即可，无需选择

### 2. 配置项目

选择预设后，CMake Tools 会自动配置项目。也可以手动触发：

- 点击状态栏的 **"CMake: [配置]"** 按钮
- 或按 `Ctrl+Shift+P`，选择 **"CMake: Configure"**

### 3. 选择构建目标

1. 点击状态栏的 **"CMake: [选择目标]"** 或按 `Ctrl+Shift+P`
2. 选择 **"CMake: Select Build Target"**
3. 选择要构建的目标（例如：`stm8l-gpio`）

### 4. 构建项目

有多种方式构建：

- **快捷键**: `F7` 或 `Ctrl+Shift+B`
- **状态栏**: 点击 **"CMake: [构建]"** 按钮
- **命令面板**: `Ctrl+Shift+P` → **"CMake: Build"**

## CMake 预设说明

### 配置预设 (Configure Presets)

| 预设名称 | 显示名称 | 说明 |
|---------|---------|------|
| `stm8l052c6` | STM8L052C6 (默认) | 根目录配置，目标芯片 STM8L052C6 |
| `stm8l-gpio` | STM8L052C6 - GPIO示例 | GPIO 示例项目配置 |
| `stm8l-blinky` | STM8L052C6 - Blinky示例 | Blinky 示例项目配置 |

### 构建预设 (Build Presets)

| 预设名称 | 显示名称 | 说明 |
|---------|---------|------|
| `default` | 默认构建 | 使用 stm8l052c6 配置 |
| `gpio` | 构建 GPIO 示例 | 构建 GPIO 示例项目 |
| `blinky` | 构建 Blinky 示例 | 构建 Blinky 示例项目 |

## 状态栏说明

CMake Tools 在 VSCode 状态栏显示以下信息：

- **[配置预设名称]** - 当前选择的配置预设
- **[构建目标]** - 当前选择的构建目标
- **[构建类型]** - Debug/Release（如果配置）
- **构建按钮** - 点击快速构建
- **调试按钮** - 点击启动调试（如果配置）

## 常用命令

通过命令面板 (`Ctrl+Shift+P`) 可以访问以下 CMake 命令：

### 配置相关
- **CMake: Select Configure Preset** - 选择配置预设
- **CMake: Configure** - 配置项目
- **CMake: Clean Rebuild** - 清理并重新配置

### 构建相关
- **CMake: Select Build Target** - 选择构建目标
- **CMake: Build** - 构建项目
- **CMake: Build Target** - 构建特定目标
- **CMake: Clean** - 清理构建文件
- **CMake: Clean Rebuild** - 清理并重新构建

### 调试相关
- **CMake: Debug** - 启动调试（需要配置调试器）

### 其他
- **CMake: Set Default Build Target** - 设置默认构建目标
- **CMake: Show Build Command** - 显示构建命令
- **CMake: Open CMakeLists.txt** - 打开 CMakeLists.txt

## 工作流程示例

### 示例1：在根目录构建 GPIO 项目

1. **在项目根目录打开 VSCode**

2. **选择配置预设**:
   ```
   Ctrl+Shift+P → CMake: Select Configure Preset → stm8l-gpio
   ```

3. **等待配置完成**（自动或手动触发）

4. **选择构建目标**:
   ```
   Ctrl+Shift+P → CMake: Select Build Target → stm8l-gpio
   ```

5. **构建项目**:
   ```
   按 F7 或点击状态栏构建按钮
   ```

6. **查看输出**:
   - 构建输出在终端面板显示
   - 输出文件位于: `build/stm8l-gpio/stm8l-gpio.ihx`

### 示例2：在子目录构建 GPIO 项目（推荐）

1. **打开子项目目录**:
   ```
   文件 → 打开文件夹 → 选择 stm8l-gpio 目录
   ```

2. **CMake Tools 自动检测配置**:
   - 会自动使用该目录的 `CMakePresets.json`
   - 无需手动选择预设

3. **构建项目**:
   ```
   按 F7 或点击状态栏构建按钮
   ```

4. **查看输出**:
   - 输出文件位于: `../build/stm8l-gpio/stm8l-gpio.ihx`

## 自定义配置

### 修改目标芯片

编辑 `CMakePresets.json`，修改 `STM8_CHIP` 的值：

```json
"STM8_CHIP": {
    "type": "STRING",
    "value": "stm8l152c6"  // 修改为其他芯片
}
```

### 添加新的预设

在 `CMakePresets.json` 的 `configurePresets` 数组中添加新项：

```json
{
    "name": "my-project",
    "displayName": "我的项目",
    "generator": "Ninja",
    "binaryDir": "${sourceDir}/build/my-project",
    "sourceDir": "${sourceDir}/my-project",
    "cacheVariables": {
        // ... 配置变量
    }
}
```

## 故障排除

### CMake Tools 未显示在状态栏

1. 确保已安装 CMake Tools 扩展
2. 确保工作区包含 `CMakeLists.txt` 或 `CMakePresets.json`
3. 重新加载窗口: `Ctrl+Shift+P` → "Developer: Reload Window"

### 配置失败

1. 检查工具是否在 PATH 中：
   - `cmake --version`
   - `ninja --version`
   - `sdcc --version`

2. 查看输出面板的错误信息

3. 手动运行配置命令检查错误

### 找不到预设

1. 确保 `CMakePresets.json` 在项目根目录
2. 检查 JSON 语法是否正确
3. 重新加载窗口

## 提示

- **快速构建**: 使用 `F7` 快捷键最快
- **查看构建命令**: `Ctrl+Shift+P` → "CMake: Show Build Command"
- **清理构建**: `Ctrl+Shift+P` → "CMake: Clean"
- **切换预设**: 点击状态栏的配置预设名称快速切换

## 相关文件

- `CMakePresets.json` - 根目录 CMake 预设配置（版本控制）
- `CMakeUserPresets.json` - 用户自定义预设（不版本控制，可添加到.gitignore）
- `stm8l-gpio/CMakePresets.json` - GPIO 项目预设配置
- `stm8l-blinky/CMakePresets.json` - Blinky 项目预设配置
- `.vscode/settings.json` - VSCode 工作区设置

## 项目结构说明

本项目包含多个独立的示例项目，每个项目都有自己的 `CMakeLists.txt`：

- **根目录**: 用于整体项目管理和CMake工具链配置
- **stm8l-gpio/**: GPIO示例项目，包含独立的CMake配置
- **stm8l-blinky/**: Blinky示例项目，包含独立的CMake配置

**推荐工作方式**：
- 开发单个项目时，打开对应的子目录作为工作区
- 管理多个项目时，在根目录打开工作区

