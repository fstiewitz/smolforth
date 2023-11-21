cmake_minimum_required(VERSION 3.26)
project(smolforth C ASM)

set(CMAKE_C_STANDARD 11)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Os")

add_library(smolforth library.c boot.S core.S
        config.h)

add_executable(sfinterp main.c)
target_link_libraries(sfinterp PUBLIC smolforth)
