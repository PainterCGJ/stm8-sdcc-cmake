# GenerateCompileCommands.cmake
# 为 Ninja 生成器生成 compile_commands.json 的辅助脚本

# 这个函数会在配置后生成 compile_commands.json
function(generate_compile_commands_for_ninja)
    if(CMAKE_GENERATOR STREQUAL "Ninja" AND CMAKE_EXPORT_COMPILE_COMMANDS)
        # 获取所有目标的编译命令
        set(COMPILE_COMMANDS_CONTENT "[\n")
        
        # 遍历所有目标
        get_directory_property(TARGETS BUILDSYSTEM_TARGETS)
        
        foreach(TARGET ${TARGETS})
            get_target_property(TARGET_TYPE ${TARGET} TYPE)
            
            # 只处理可执行文件和库
            if(TARGET_TYPE STREQUAL "EXECUTABLE" OR TARGET_TYPE STREQUAL "STATIC_LIBRARY")
                get_target_property(SOURCES ${TARGET} SOURCES)
                
                foreach(SOURCE ${SOURCES})
                    # 只处理 C/C++ 源文件
                    if(SOURCE MATCHES "\\.(c|cpp|cxx|cc)$")
                        # 获取源文件的完整路径
                        get_source_file_property(SOURCE_LOCATION ${SOURCE} LOCATION)
                        if(NOT SOURCE_LOCATION)
                            if(IS_ABSOLUTE ${SOURCE})
                                set(SOURCE_LOCATION ${SOURCE})
                            else()
                                set(SOURCE_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE})
                            endif()
                        endif()
                        
                        # 获取包含目录
                        get_target_property(INCLUDE_DIRS ${TARGET} INCLUDE_DIRECTORIES)
                        set(INCLUDE_FLAGS "")
                        foreach(INCLUDE_DIR ${INCLUDE_DIRS})
                            if(IS_ABSOLUTE ${INCLUDE_DIR})
                                list(APPEND INCLUDE_FLAGS "-I${INCLUDE_DIR}")
                            else()
                                list(APPEND INCLUDE_FLAGS "-I${CMAKE_CURRENT_SOURCE_DIR}/${INCLUDE_DIR}")
                            endif()
                        endforeach()
                        
                        # 获取编译定义
                        get_target_property(COMPILE_DEFS ${TARGET} COMPILE_DEFINITIONS)
                        set(DEFINE_FLAGS "")
                        foreach(DEF ${COMPILE_DEFS})
                            list(APPEND DEFINE_FLAGS "-D${DEF}")
                        endforeach()
                        
                        # 获取编译选项
                        get_target_property(COMPILE_OPTIONS ${TARGET} COMPILE_OPTIONS)
                        set(OPTION_FLAGS "")
                        foreach(OPT ${COMPILE_OPTIONS})
                            # 移除 SDCC 特定选项
                            if(NOT OPT MATCHES "^-mstm8$" AND NOT OPT MATCHES "^--std-c99$")
                                list(APPEND OPTION_FLAGS "${OPT}")
                            endif()
                        endforeach()
                        
                        # 构建编译命令
                        set(COMMAND "sdcc -std=c99 ${DEFINE_FLAGS} ${INCLUDE_FLAGS} ${OPTION_FLAGS} -c \"${SOURCE_LOCATION}\"")
                        
                        # 添加到 JSON
                        set(COMPILE_COMMANDS_CONTENT "${COMPILE_COMMANDS_CONTENT}  {\n")
                        set(COMPILE_COMMANDS_CONTENT "${COMPILE_COMMANDS_CONTENT}    \"directory\": \"${CMAKE_BINARY_DIR}\",\n")
                        set(COMPILE_COMMANDS_CONTENT "${COMPILE_COMMANDS_CONTENT}    \"command\": \"${COMMAND}\",\n")
                        set(COMPILE_COMMANDS_CONTENT "${COMPILE_COMMANDS_CONTENT}    \"file\": \"${SOURCE_LOCATION}\"\n")
                        set(COMPILE_COMMANDS_CONTENT "${COMPILE_COMMANDS_CONTENT}  },\n")
                    endif()
                endforeach()
            endif()
        endforeach()
        
        # 移除最后一个逗号
        string(REGEX REPLACE ",\n$" "\n" COMPILE_COMMANDS_CONTENT "${COMPILE_COMMANDS_CONTENT}")
        set(COMPILE_COMMANDS_CONTENT "${COMPILE_COMMANDS_CONTENT}]\n")
        
        # 写入文件
        file(WRITE ${CMAKE_BINARY_DIR}/compile_commands.json "${COMPILE_COMMANDS_CONTENT}")
        message(STATUS "已生成 compile_commands.json 在 ${CMAKE_BINARY_DIR}")
    endif()
endfunction()


