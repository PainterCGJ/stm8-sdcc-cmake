cmake_minimum_required(VERSION 2.8)
set(PROJECT stm8l-app)
project(${PROJECT} C)

# 生成compile_commands.json供clangd使用
set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "Generate compile_commands.json for clangd" FORCE)

include(sdcc-stm8)

find_package(STM8_StdPeriph COMPONENTS gpio REQUIRED)

include_directories(
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_SOURCE_DIR}/source/StdPeriph
        ${STM8_StdPeriph_INCLUDE_DIR}
)

set(C_FILES main.c)

add_executable(${PROJECT} ${C_FILES} ${STM8_StdPeriph_SOURCES})
STM8_SET_TARGET_PROPERTIES(${PROJECT})

# 为 Ninja 生成器创建 compile_commands.json 符号链接
# 注意：Ninja 生成器不会自动生成 compile_commands.json
if(CMAKE_GENERATOR STREQUAL "Ninja" AND CMAKE_EXPORT_COMPILE_COMMANDS)
    # 在构建目录创建 compile_commands.json
    # 这会在配置阶段执行
    file(WRITE ${CMAKE_BINARY_DIR}/compile_commands.json "[]")
    # 实际内容会在构建时由 CMake 填充（如果 CMake 版本 >= 3.20）
endif()