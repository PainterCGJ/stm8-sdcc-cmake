# CMake Tools 快速开始

## 第一步：安装扩展

1. 打开 VSCode
2. 按 `Ctrl+Shift+X` 打开扩展市场
3. 搜索并安装 **CMake Tools** (ms-vscode.cmake-tools)

## 第二步：选择工作方式

### 方式1：开发单个项目（推荐）

1. **打开子项目目录**（例如：`stm8l-gpio`）
2. CMake Tools 会自动检测配置
3. 按 **`F7`** 构建项目

### 方式2：管理多个项目

1. **在根目录打开 VSCode**
2. 按 `Ctrl+Shift+P` → **"CMake: Select Configure Preset"**
3. 选择预设（如：`stm8l-gpio`）
4. 按 **`F7`** 构建项目

## 快捷键

- **`F7`** - 构建项目
- **`Ctrl+Shift+P`** - 打开命令面板
- **`Ctrl+Shift+B`** - 构建（如果设置了默认任务）

## 状态栏按钮

CMake Tools 在状态栏显示：
- **[预设名称]** - 点击选择配置预设
- **[目标名称]** - 点击选择构建目标  
- **[构建]** - 点击快速构建
- **[调试]** - 点击启动调试

## 构建输出位置

- GPIO项目: `build/stm8l-gpio/stm8l-gpio.ihx`
- Blinky项目: `build/stm8l-blinky/stm8.ihx`

## 常见问题

**Q: 状态栏没有显示CMake信息？**
- 确保已安装CMake Tools扩展
- 确保工作区包含 `CMakeLists.txt` 或 `CMakePresets.json`
- 重新加载窗口：`Ctrl+Shift+P` → "Developer: Reload Window"

**Q: 配置失败？**
- 检查工具是否在PATH中：`cmake --version`、`ninja --version`、`sdcc --version`
- 查看输出面板的错误信息

**Q: 找不到预设？**
- 确保 `CMakePresets.json` 在项目目录中
- 检查JSON语法是否正确

## 详细文档

更多信息请查看：
- `README_CMAKE_TOOLS.md` - 完整使用指南
- `README_VSCODE.md` - VSCode环境配置说明

