# 解决Qt CMake问题

## 问题说明

如果CMake Tools找到了Qt的CMake而不是系统的CMake，可能会导致工具链配置问题。

## 原因

1. **Qt的CMake在PATH中优先级更高**
2. **CMake Tools自动检测到了Qt安装**
3. **工具链文件未在CMake初始化前正确加载**

## 解决方案

### 方案1：在VSCode中指定CMake路径（最简单）

1. 打开 `.vscode/settings.json`
2. 找到 `cmake.cmakePath` 设置
3. 设置为系统CMake的完整路径，例如：
   ```json
   {
       "cmake.cmakePath": "C:/Program Files/CMake/bin/cmake.exe"
   }
   ```

### 方案2：清理CMake缓存

如果之前使用Qt的CMake配置过项目，需要清理缓存：

1. **删除build目录**：
   ```powershell
   Remove-Item -Recurse -Force build
   ```

2. **重新配置项目**：
   - 在VSCode中：`Ctrl+Shift+P` → `CMake: Delete Cache and Reconfigure`
   - 或手动运行：`cmake --build build --target clean`

### 方案3：检查并调整PATH顺序

1. **查看当前PATH**：
   ```powershell
   $env:PATH -split ';' | Select-String -Pattern "cmake|qt"
   ```

2. **确保系统CMake路径在Qt路径之前**

3. **或者在VSCode设置中指定CMake路径**（推荐）

### 方案4：验证工具链是否正确加载

配置项目后，检查CMake输出：

1. 打开VSCode输出面板
2. 选择 "CMake" 输出
3. 查找以下信息：
   ```
   -- The C compiler identification is SDCC
   -- Check for working C compiler: SDCC
   ```

如果显示其他编译器（如GCC、MSVC），说明工具链文件未正确加载。

## 验证步骤

### 1. 运行诊断脚本

```powershell
.\script\check_toolchain.bat
```

### 2. 手动测试工具链

```powershell
# 清理旧配置
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue

# 手动配置（查看详细输出）
cmake `
    -DCMAKE_TOOLCHAIN_FILE=cmake/sdcc-generic.cmake `
    -DCMAKE_MODULE_PATH=cmake `
    -DSTM8_CHIP=stm8l052c6 `
    -DSTM8_StdPeriph_DIR=StdPeriph `
    -GNinja `
    -S stm8l-gpio `
    -B build/stm8l-gpio

# 查看编译器设置
cmake -L -N build/stm8l-gpio | Select-String -Pattern "CMAKE_C_COMPILER"
```

应该显示：
```
CMAKE_C_COMPILER:FILEPATH=C:/path/to/sdcc.exe
```

## 已修复的问题

### 1. 工具链文件改进

已更新 `cmake/sdcc-generic.cmake`：
- 使用 `find_program` 确保找到SDCC的完整路径
- 强制设置编译器ID为SDCC
- 禁用CMake的自动编译器检测

### 2. VSCode设置更新

已更新 `.vscode/settings.json`：
- 添加了 `cmake.cmakePath` 配置选项（注释状态）
- 优先使用CMake预设

## 推荐操作

1. **运行诊断脚本**：`.\script\check_toolchain.bat`
2. **如果检测到Qt CMake问题**：
   - 在 `.vscode/settings.json` 中设置 `cmake.cmakePath`
   - 或调整系统PATH顺序
3. **清理并重新配置**：
   - 删除 `build` 目录
   - 在VSCode中重新配置项目
4. **验证配置**：
   - 查看CMake输出，确认编译器是SDCC

## 相关文件

- `cmake/sdcc-generic.cmake` - SDCC工具链文件（已修复）
- `.vscode/settings.json` - VSCode配置（已更新）
- `script/check_toolchain.bat` - 诊断脚本
- `TOOLCHAIN_DIAGNOSIS.md` - 详细诊断说明

