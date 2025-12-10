cmake_minimum_required(VERSION 2.8)
set(PROJECT stm8l-app)
project(${PROJECT} C)

# 生成compile_commands.json供clangd使用
set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "Generate compile_commands.json for clangd" FORCE)

include(sdcc-stm8)

find_package(STM8_StdPeriph COMPONENTS gpio usart syscfg clk REQUIRED)

include_directories(
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_SOURCE_DIR}/source/StdPeriph
        ${STM8_StdPeriph_INCLUDE_DIR}
)

set(C_FILES main.c)

add_executable(${PROJECT} ${C_FILES} ${STM8_StdPeriph_SOURCES})
STM8_SET_TARGET_PROPERTIES(${PROJECT})

# 生成hex文件并复制到bin文件夹
# 定义输出路径
set(HEX_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/bin)
set(HEX_FILE ${HEX_OUTPUT_DIR}/${PROJECT}.hex)
set(IHX_FILE ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT}.ihx)

# 创建bin目录
file(MAKE_DIRECTORY ${HEX_OUTPUT_DIR})

# 使用packihx将ihx转换为hex
# packihx输出到标准输出，需要重定向到文件
# 创建转换脚本文件
set(HEX_CONVERT_SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/convert_ihx_to_hex)

# 检测Windows系统（使用多种方法确保可靠性）
# 由于工具链文件设置了CMAKE_SYSTEM_NAME Generic，需要检测主机系统
# 检查环境变量OS（Windows上为"Windows_NT"）或CMAKE_HOST_SYSTEM_NAME
if("$ENV{OS}" MATCHES "Windows" OR CMAKE_HOST_SYSTEM_NAME MATCHES "Windows" OR CMAKE_HOST_WIN32 OR WIN32 OR MSVC)
    # Windows批处理脚本
    file(WRITE ${HEX_CONVERT_SCRIPT}.bat "@echo off\n\"${CMAKE_PACKIHX}\" \"${IHX_FILE}\" > \"${HEX_FILE}\"\n")
    add_custom_command(
        TARGET ${PROJECT}
        POST_BUILD
        COMMAND ${HEX_CONVERT_SCRIPT}.bat
        COMMENT "Converting ${PROJECT}.ihx to ${PROJECT}.hex in bin folder"
    )
else()
    # Unix/Linux shell脚本
    file(WRITE ${HEX_CONVERT_SCRIPT}.sh "#!/bin/sh\n\"${CMAKE_PACKIHX}\" \"${IHX_FILE}\" > \"${HEX_FILE}\"\n")
    # 直接使用sh执行脚本，无需设置执行权限
    add_custom_command(
        TARGET ${PROJECT}
        POST_BUILD
        COMMAND sh ${HEX_CONVERT_SCRIPT}.sh
        COMMENT "Converting ${PROJECT}.ihx to ${PROJECT}.hex in bin folder"
    )
endif()

# 为 Ninja 生成器创建 compile_commands.json 符号链接
# 注意：Ninja 生成器不会自动生成 compile_commands.json
if(CMAKE_GENERATOR STREQUAL "Ninja" AND CMAKE_EXPORT_COMPILE_COMMANDS)
    # 在构建目录创建 compile_commands.json
    # 这会在配置阶段执行
    file(WRITE ${CMAKE_BINARY_DIR}/compile_commands.json "[]")
    # 实际内容会在构建时由 CMake 填充（如果 CMake 版本 >= 3.20）
endif()