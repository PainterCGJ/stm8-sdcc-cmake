cmake_minimum_required(VERSION 3.19)

# STM8-SDCC-CMAKE 主项目
# 此文件用于支持CMake Tools扩展
# 要构建特定示例项目，请打开对应的子目录作为工作区，或使用CMake预设
project(stm8-sdcc-cmake C)

# 生成compile_commands.json供clangd使用
set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "Generate compile_commands.json for clangd" FORCE)

# 可选：添加子项目
add_subdirectory(source/app)
# add_subdirectory(stm8l-blinky)
