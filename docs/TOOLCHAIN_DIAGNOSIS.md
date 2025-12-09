# CMake 工具链查找机制说明

## 问题：为什么找到了Qt的CMake？

### CMake工具链查找顺序

CMake Tools扩展查找CMake的顺序：

1. **CMake Tools设置中的cmake路径**
2. **系统PATH中的cmake**
3. **Qt安装目录中的cmake**（如果Qt在PATH中）
4. **其他常见安装位置**

### 当前工程的工具链配置

本工程使用**SDCC编译器**，通过工具链文件指定：

```cmake
# cmake/sdcc-generic.cmake
set(CMAKE_C_COMPILER sdcc)  # 只设置编译器名称，CMake会在PATH中查找
```

**关键点**：
- `CMAKE_C_COMPILER` 设置为 `sdcc`（只是名称，不是完整路径）
- CMake会在系统PATH中查找 `sdcc` 可执行文件
- **工具链文件必须在CMake初始化阶段加载**（通过 `CMAKE_TOOLCHAIN_FILE`）

## 问题原因分析

### 1. CMake Tools使用了Qt的CMake

如果CMake Tools找到了Qt的CMake，可能原因：
- Qt的CMake在PATH中优先级更高
- CMake Tools自动检测到了Qt安装
- VSCode设置中指定了Qt的CMake路径

### 2. 工具链文件未正确加载

即使使用了Qt的CMake，只要工具链文件正确加载，应该也能工作。但如果：
- `CMAKE_TOOLCHAIN_FILE` 未在CMake初始化前设置
- 工具链文件路径不正确
- CMake缓存中已有旧的编译器设置

## 解决方案

### 方案1：指定系统CMake路径（推荐）

在 `.vscode/settings.json` 中明确指定CMake路径：

```json
{
    "cmake.cmakePath": "C:/Program Files/CMake/bin/cmake.exe"  // 替换为你的CMake路径
}
```

### 方案2：确保工具链文件优先加载

工具链文件必须在CMake第一次运行前设置。当前配置已通过 `CMAKE_TOOLCHAIN_FILE` 设置，但需要确保：

1. **使用CMake预设**（已配置）
2. **清理旧的CMake缓存**：
   ```bash
   # 删除build目录
   rm -rf build
   # 或
   rmdir /s build
   ```

### 方案3：在工具链文件中使用完整路径

修改 `cmake/sdcc-generic.cmake`，使用完整路径查找编译器：

```cmake
# 优先使用PATH中的sdcc
find_program(SDCC_EXECUTABLE sdcc REQUIRED)
set(CMAKE_C_COMPILER "${SDCC_EXECUTABLE}" CACHE FILEPATH "SDCC Compiler" FORCE)
```

### 方案4：设置环境变量优先级

确保SDCC在PATH中，且优先级高于Qt：

1. 检查PATH顺序：
   ```powershell
   $env:PATH -split ';' | Select-String -Pattern "sdcc|qt"
   ```

2. 调整PATH顺序，将SDCC路径放在Qt路径之前

## 诊断步骤

### 1. 检查当前使用的CMake

在VSCode中：
1. 打开命令面板：`Ctrl+Shift+P`
2. 运行：`CMake: Show CMake Cache`
3. 查看 `CMAKE_COMMAND` 的值

或查看CMake输出：
- 打开输出面板
- 选择 "CMake" 输出
- 查看CMake版本和路径信息

### 2. 检查编译器设置

查看CMake缓存中的编译器设置：
- `CMAKE_C_COMPILER` - 应该是 `sdcc` 或SDCC的完整路径
- `CMAKE_C_COMPILER_ID` - 应该显示为 `SDCC`

### 3. 检查工具链文件是否加载

在CMake配置输出中查找：
```
-- The C compiler identification is SDCC
```

如果显示其他编译器（如GCC、MSVC），说明工具链文件未正确加载。

## 验证工具链是否正确

运行以下命令验证：

```powershell
# 检查sdcc是否在PATH中
sdcc --version

# 检查cmake版本
cmake --version

# 手动配置CMake（查看输出）
cmake -DCMAKE_TOOLCHAIN_FILE=cmake/sdcc-generic.cmake -DCMAKE_MODULE_PATH=cmake -DSTM8_CHIP=stm8l052c6 -DSTM8_StdPeriph_DIR=StdPeriph -GNinja -S . -B build/test
```

## 推荐配置

### 更新 .vscode/settings.json

添加CMake路径设置（如果知道系统CMake位置）：

```json
{
    "cmake.cmakePath": "",  // 留空使用系统PATH中的cmake，或指定完整路径
    "cmake.preferredGenerators": ["Ninja"],
    "cmake.generator": "Ninja"
}
```

### 更新工具链文件

使用 `find_program` 确保找到正确的编译器。

