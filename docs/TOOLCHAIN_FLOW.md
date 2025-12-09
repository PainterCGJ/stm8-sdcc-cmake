# STM8 编译工具链查找机制详解

## 概述

本工程使用 **SDCC (Small Device C Compiler)** 作为STM8微控制器的编译工具链。整个工具链查找和配置过程通过CMake工具链文件机制实现。

## 工具链查找流程图

```
┌─────────────────────────────────────────────────────────────┐
│ 1. CMake配置阶段（CMakePresets.json 或命令行参数）          │
│    - CMAKE_TOOLCHAIN_FILE = cmake/sdcc-generic.cmake        │
│    - CMAKE_MODULE_PATH = cmake                              │
│    - STM8_CHIP = stm8l052c6                                 │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. CMake加载工具链文件（sdcc-generic.cmake）                │
│    在CMake初始化阶段，在检测编译器之前执行                  │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. 工具链文件查找SDCC编译器                                  │
│    find_program(SDCC_COMPILER sdcc REQUIRED)                │
│    ↓                                                         │
│    在系统PATH中查找 "sdcc" 可执行文件                       │
│    - Windows: 查找 sdcc.exe                                 │
│    - Linux/Mac: 查找 sdcc                                   │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. 设置编译器变量                                           │
│    CMAKE_C_COMPILER = <找到的sdcc完整路径>                  │
│    CMAKE_C_COMPILER_ID = "SDCC"                             │
│    CMAKE_C_COMPILER_WORKS = TRUE                            │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. 查找SDCC相关工具                                          │
│    - sdobjcopy (objcopy工具)                                │
│    - packihx (打包工具)                                     │
│    - sdcclib (库管理工具)                                   │
│    优先在SDCC安装目录查找，然后在PATH中查找                │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. 配置编译和链接规则                                        │
│    - 编译命令模板                                            │
│    - 链接命令模板                                            │
│    - 库创建命令模板                                          │
│    - 输出文件扩展名 (.ihx, .rel, .lib)                     │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. CMakeLists.txt使用工具链                                 │
│    include(sdcc-stm8)                                       │
│    ↓                                                         │
│    根据STM8_CHIP确定芯片系列和类型                          │
│    设置芯片特定的编译定义                                   │
└─────────────────────────────────────────────────────────────┘
```

## 详细步骤说明

### 步骤1: CMake配置入口

**方式A: 使用CMake预设（推荐）**

```json
// CMakePresets.json
{
    "cacheVariables": {
        "CMAKE_TOOLCHAIN_FILE": {
            "type": "FILEPATH",
            "value": "${sourceDir}/cmake/sdcc-generic.cmake"
        }
    }
}
```

**方式B: 命令行参数**

```bash
cmake -DCMAKE_TOOLCHAIN_FILE=cmake/sdcc-generic.cmake ...
```

**方式C: VSCode设置**

```json
// .vscode/settings.json
{
    "cmake.configureSettings": {
        "CMAKE_TOOLCHAIN_FILE": "${workspaceFolder}/cmake/sdcc-generic.cmake"
    }
}
```

### 步骤2: 工具链文件加载时机

**关键点**: 工具链文件必须在CMake第一次检测编译器**之前**加载。

CMake的执行顺序：
1. 读取 `CMakeLists.txt`
2. **加载工具链文件**（如果指定了 `CMAKE_TOOLCHAIN_FILE`）
3. 检测编译器（如果工具链文件未设置编译器）
4. 配置项目

### 步骤3: SDCC编译器查找

```cmake
# cmake/sdcc-generic.cmake (第5行)
find_program(SDCC_COMPILER sdcc REQUIRED)
```

**查找顺序**：
1. 在CMake的 `CMAKE_PROGRAM_PATH` 中查找
2. 在系统 `PATH` 环境变量中查找
3. 在CMake的默认搜索路径中查找

**查找结果**：
- 如果找到：`SDCC_COMPILER` 变量包含完整路径，例如：
  - Windows: `C:/SDCC/bin/sdcc.exe`
  - Linux: `/usr/bin/sdcc`
- 如果未找到：CMake配置失败，报错 `REQUIRED` 关键字确保必须找到

### 步骤4: 编译器设置

```cmake
# cmake/sdcc-generic.cmake (第6-10行)
set(CMAKE_C_COMPILER "${SDCC_COMPILER}" CACHE FILEPATH "SDCC Compiler" FORCE)
set(CMAKE_C_COMPILER_WORKS TRUE CACHE INTERNAL "")
set(CMAKE_C_COMPILER_ID "SDCC" CACHE INTERNAL "")
```

**说明**：
- `FORCE` 关键字：强制覆盖CMake可能已经检测到的编译器
- `CMAKE_C_COMPILER_WORKS = TRUE`：跳过CMake的编译器测试（因为SDCC是交叉编译器）
- `CMAKE_C_COMPILER_ID = "SDCC"`：明确标识编译器类型

### 步骤5: 相关工具查找

```cmake
# 获取SDCC安装目录
get_filename_component(SDCC_LOCATION "${CMAKE_C_COMPILER}" DIRECTORY)

# 查找sdobjcopy（优先在SDCC目录，然后在PATH）
find_program(CMAKE_OBJCOPY sdobjcopy PATHS "${SDCC_LOCATION}" NO_DEFAULT_PATH)
find_program(CMAKE_OBJCOPY sdobjcopy)

# 查找packihx
find_program(CMAKE_PACKIHX packihx PATHS "${SDCC_LOCATION}" NO_DEFAULT_PATH)
find_program(CMAKE_PACKIHX packihx)

# 查找sdcclib（库管理工具）
find_program(SDCCLIB_EXECUTABLE sdcclib PATHS "${SDCC_LOCATION}" NO_DEFAULT_PATH)
find_program(SDCCLIB_EXECUTABLE sdcclib)
```

**查找策略**：
1. 首先在SDCC安装目录查找（`NO_DEFAULT_PATH`）
2. 如果未找到，在系统PATH中查找
3. 这样可以确保使用与编译器匹配的工具版本

### 步骤6: 编译规则配置

```cmake
# 编译命令模板
set(CMAKE_C_COMPILE_OBJECT 
    "<CMAKE_C_COMPILER> <DEFINES> <INCLUDES> <FLAGS> -o <OBJECT> -c <SOURCE>")

# 链接命令模板
set(CMAKE_C_LINK_EXECUTABLE 
    "<CMAKE_C_COMPILER> <FLAGS> <OBJECTS> --out-fmt-ihx -o <TARGET> ...")

# 库创建命令模板
set(CMAKE_C_CREATE_STATIC_LIBRARY
    "\"${CMAKE_COMMAND}\" -E remove <TARGET>"
    "<CMAKE_AR> -a <TARGET> <LINK_FLAGS> <OBJECTS>")
```

**输出文件格式**：
- 可执行文件：`.ihx` (Intel Hex格式)
- 目标文件：`.rel` (SDCC目标文件格式)
- 静态库：`.lib`

### 步骤7: 项目使用工具链

```cmake
# stm8l-gpio/CMakeLists.txt
include(sdcc-stm8)  # 包含STM8特定配置

# sdcc-stm8.cmake 会：
# 1. 从STM8_CHIP提取芯片系列（L或S）
# 2. 包含对应的配置文件（sdcc-stm8l.cmake或sdcc-stm8s.cmake）
# 3. 根据芯片型号设置编译定义（如STM8L05X_MD_VL）
```

## 关键文件说明

### 1. `cmake/sdcc-generic.cmake`
- **作用**: SDCC工具链的通用配置
- **职责**: 
  - 查找SDCC编译器
  - 配置编译/链接规则
  - 设置输出文件格式

### 2. `cmake/sdcc-stm8.cmake`
- **作用**: STM8系列特定配置
- **职责**:
  - 确定芯片系列（S或L）
  - 包含对应的子配置文件

### 3. `cmake/sdcc-stm8l.cmake`
- **作用**: STM8L系列特定配置
- **职责**:
  - 根据芯片型号确定芯片类型
  - 设置芯片特定的编译定义

### 4. `CMakePresets.json`
- **作用**: CMake预设配置
- **职责**:
  - 定义工具链文件路径
  - 设置项目变量
  - 简化配置过程

## 环境要求

### 必须的工具（在PATH中）

1. **SDCC编译器**
   ```bash
   sdcc --version  # 应该能执行
   ```

2. **CMake**
   ```bash
   cmake --version  # 应该能执行
   ```

3. **Ninja**（推荐）
   ```bash
   ninja --version  # 应该能执行
   ```

### 可选工具

- `sdobjcopy` - 对象文件转换工具
- `packihx` - Intel Hex打包工具
- `sdcclib` - 库管理工具

## 常见问题排查

### 问题1: 找不到SDCC编译器

**症状**: CMake配置失败，提示找不到 `sdcc`

**解决方法**:
1. 检查SDCC是否在PATH中：
   ```powershell
   where sdcc
   ```
2. 如果不在PATH中，添加到PATH或使用完整路径

### 问题2: 使用了错误的编译器

**症状**: CMake检测到GCC/MSVC而不是SDCC

**解决方法**:
1. 确保工具链文件正确加载（检查CMake输出）
2. 清理CMake缓存：
   ```bash
   rm -rf build
   ```
3. 重新配置项目

### 问题3: Qt的CMake被使用

**症状**: CMake Tools使用了Qt的CMake

**解决方法**:
1. 在 `.vscode/settings.json` 中指定CMake路径：
   ```json
   "cmake.cmakePath": "C:/Program Files/CMake/bin/cmake.exe"
   ```
2. 或调整系统PATH，将系统CMake放在Qt之前

## 验证工具链配置

### 方法1: 查看CMake输出

配置项目后，查看输出中的编译器信息：
```
-- The C compiler identification is SDCC
-- Check for working C compiler: SDCC
-- Found SDCC: C:/SDCC/bin/sdcc.exe
```

### 方法2: 查看CMake缓存

```bash
cmake -L -N build/stm8l-gpio | grep CMAKE_C_COMPILER
```

应该显示：
```
CMAKE_C_COMPILER:FILEPATH=C:/SDCC/bin/sdcc.exe
```

### 方法3: 运行诊断脚本

```powershell
.\script\check_toolchain.bat
```

## 总结

本工程的工具链查找机制：

1. **通过CMake工具链文件机制**指定SDCC编译器
2. **在CMake初始化阶段**查找和配置编译器
3. **使用find_program**在系统PATH中查找工具
4. **强制设置编译器ID**避免CMake自动检测冲突
5. **配置编译规则**适配SDCC的特殊要求

这种机制确保了：
- ✅ 使用正确的SDCC编译器
- ✅ 找到匹配的工具链工具
- ✅ 避免与其他编译器（如Qt的CMake）冲突
- ✅ 支持跨平台（Windows/Linux/Mac）

