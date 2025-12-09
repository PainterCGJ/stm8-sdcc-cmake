# Clangd 配置说明

本项目已配置 clangd 语言服务器，用于代码导航、静态检查和代码补全。

## 配置文件说明

### 1. `.clangd`
clangd 语言服务器的主配置文件，包含：
- 编译标志和包含路径
- 诊断配置
- 索引配置
- 代码补全设置

### 2. `.clang-format`
代码格式化配置文件（可选），用于统一代码风格。

### 3. `compile_commands.json`
由 CMake 自动生成的编译数据库，clangd 使用它来理解项目结构和编译选项。

## 使用前准备

### 1. 安装 clangd

#### Windows
```powershell
# 使用 Chocolatey
choco install llvm

# 或下载安装包
# https://github.com/clangd/clangd/releases
```

#### Linux
```bash
# Ubuntu/Debian
sudo apt-get install clangd

# 或使用 snap
sudo snap install clangd --classic
```

#### macOS
```bash
brew install llvm
```

### 2. 安装 VSCode 扩展

在 VSCode 中安装以下扩展：
- **clangd** (LLVM 官方扩展)
  - 扩展ID: `llvm-vs-code-extensions.vscode-clangd`

**注意**：如果已安装 Microsoft C/C++ 扩展，建议禁用它以避免冲突。

### 3. 生成 compile_commands.json

运行 CMake 配置以生成 `compile_commands.json`：

```bash
# 使用预设配置
cmake --preset stm8l-gpio

# 或手动配置
cmake -B build/stm8l-gpio -S stm8l-gpio \
  -DCMAKE_TOOLCHAIN_FILE=cmake/sdcc-generic.cmake \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

`compile_commands.json` 将生成在构建目录中（如 `build/stm8l-gpio/compile_commands.json`）。

## 功能说明

### 代码导航
- **跳转到定义**：`F12` 或 `Ctrl+Click`
- **查找引用**：`Shift+F12`
- **查看符号信息**：鼠标悬停
- **符号搜索**：`Ctrl+T`

### 静态检查
clangd 会自动进行静态分析，显示：
- 语法错误
- 类型错误
- 未使用的变量/函数
- 潜在的 bug

### 代码补全
- 自动补全函数、变量、类型
- 参数提示
- 代码片段

### 代码格式化
使用 clang-format 格式化代码：
- **格式化当前文件**：`Shift+Alt+F`
- **格式化选中代码**：选中后 `Shift+Alt+F`

## 配置说明

### 修改包含路径

如果项目结构发生变化，需要更新 `.clangd` 文件中的包含路径：

```yaml
CompileFlags:
  Add:
    - -I${workspaceFolder}/your/include/path
```

### 修改编译定义

在 `.clangd` 中添加或修改编译定义：

```yaml
CompileFlags:
  Add:
    - -DSTM8L05X_MD_VL
    - -D__SDCC__
```

### 调整诊断级别

在 `.clangd` 中配置诊断：

```yaml
Diagnostics:
  UnusedIncludes: Strict  # 或 Relaxed, None
  MissingIncludes: Strict
```

## 常见问题

### 1. clangd 无法找到头文件

**解决方案**：
- 确保 `compile_commands.json` 已生成
- 检查 `.clangd` 中的包含路径是否正确
- 重启 clangd 服务器：`Ctrl+Shift+P` -> `clangd: Restart language server`

### 2. 误报错误（SDCC 特定语法）

由于 clangd 使用标准 C 语法，可能无法理解 SDCC 的某些扩展。可以在 `.clangd` 中忽略这些诊断：

```yaml
Diagnostics:
  Suppress:
    - unused-includes
    - missing-includes
```

### 3. compile_commands.json 未更新

**解决方案**：
- 重新运行 CMake 配置
- 确保 `CMAKE_EXPORT_COMPILE_COMMANDS` 已启用
- 检查构建目录是否正确

### 4. 性能问题

如果项目很大，clangd 索引可能需要一些时间：
- 首次打开项目时等待索引完成
- 可以在 `.clangd` 中调整索引设置：

```yaml
Index:
  Background: Build  # 后台索引
```

## 与 SDCC 的兼容性

**重要提示**：clangd 使用标准 C 语法，无法完全理解 SDCC 的所有扩展。因此：
- 代码导航和跳转功能正常工作
- 某些 SDCC 特定的语法可能显示为错误（但实际可以编译）
- 静态检查主要针对标准 C 代码

对于实际的编译错误，请使用 SDCC 编译器进行编译。

## 参考资源

- [clangd 官方文档](https://clangd.llvm.org/)
- [clang-format 配置选项](https://clang.llvm.org/docs/ClangFormatStyleOptions.html)
- [compile_commands.json 规范](https://clang.llvm.org/docs/JSONCompilationDatabase.html)



