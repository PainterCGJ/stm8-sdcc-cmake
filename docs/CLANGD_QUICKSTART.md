# Clangd 快速启动指南

## ✅ 配置已完成

以下文件已创建/修改：

1. **`.clangd`** - clangd 语言服务器配置文件
2. **`.clang-format`** - 代码格式化配置文件
3. **`.vscode/settings.json`** - 已更新，启用 clangd
4. **CMakeLists.txt** - 已修改，启用 `CMAKE_EXPORT_COMPILE_COMMANDS`

## 🚀 快速开始

### 步骤 1: 安装 clangd

**Windows:**
```powershell
# 使用 Chocolatey
choco install llvm

# 或下载安装包
# https://github.com/clangd/clangd/releases
```

**Linux:**
```bash
sudo apt-get install clangd
```

**macOS:**
```bash
brew install llvm
```

### 步骤 2: 安装 VSCode 扩展

1. 打开 VSCode
2. 按 `Ctrl+Shift+X` 打开扩展市场
3. 搜索并安装 **clangd** (LLVM 官方扩展)
   - 扩展ID: `llvm-vs-code-extensions.vscode-clangd`

### 步骤 3: 生成 compile_commands.json

运行 CMake 配置（使用预设或手动配置）：

```bash
# 方式1: 使用预设（推荐）
cmake --preset stm8l-gpio

# 方式2: 手动配置
cd stm8l-gpio
cmake -B ../build/stm8l-gpio -S . \
  -DCMAKE_TOOLCHAIN_FILE=../cmake/sdcc-generic.cmake \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

### 步骤 4: 重启 VSCode 或重启 clangd

- **重启 clangd**: `Ctrl+Shift+P` -> 输入 `clangd: Restart language server`
- **或重启 VSCode**

## 📝 使用方法

### 代码导航
- **跳转到定义**: `F12` 或 `Ctrl+Click`
- **查找引用**: `Shift+F12`
- **返回**: `Alt+Left`
- **前进**: `Alt+Right`
- **符号搜索**: `Ctrl+T`

### 代码补全
- 输入时自动显示补全建议
- `Ctrl+Space` 手动触发补全

### 静态检查
- 错误和警告会显示在代码下方（红色/黄色波浪线）
- 鼠标悬停查看详细信息
- `Ctrl+.` 查看快速修复建议

### 代码格式化
- **格式化文件**: `Shift+Alt+F`
- **格式化选中**: 选中代码后 `Shift+Alt+F`

## 🔧 配置说明

### 修改芯片型号定义

如果使用不同的芯片，编辑 `.clangd` 文件：

```yaml
CompileFlags:
  Add:
    - -DSTM8L05X_MD_VL  # 改为你的芯片定义
```

### 调整诊断级别

在 `.clangd` 中修改：

```yaml
Diagnostics:
  UnusedIncludes: Strict  # Strict, Relaxed, 或 None
  MissingIncludes: Strict
```

## ⚠️ 注意事项

1. **SDCC 兼容性**: clangd 使用标准 C，可能无法理解所有 SDCC 扩展
   - 代码导航和跳转正常工作
   - 某些 SDCC 特定语法可能显示为错误（但实际可以编译）

2. **compile_commands.json 位置**: 
   - clangd 会自动从当前文件向上查找 `compile_commands.json`
   - 如果文件在 `build/` 目录，clangd 会自动找到

3. **性能**: 首次打开项目时，clangd 需要索引代码，可能需要一些时间

## 🐛 故障排除

### clangd 无法找到头文件

1. 确认 `compile_commands.json` 已生成
2. 检查文件位置（应在构建目录中）
3. 重启 clangd: `Ctrl+Shift+P` -> `clangd: Restart language server`

### 显示太多误报错误

编辑 `.clangd`，添加更多抑制规则：

```yaml
Diagnostics:
  Suppress:
    - unused-includes
    - missing-includes
    - unused-variable
```

### 查看 clangd 日志

在 VSCode 输出面板中查看 clangd 日志：
1. `View` -> `Output`
2. 选择 "clangd" 输出通道

## 📚 更多信息

详细配置说明请参考 `README_CLANGD.md`



