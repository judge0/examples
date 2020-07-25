cmake_minimum_required(VERSION 3.13)
project(judge0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)

add_executable(hello ${CMAKE_CURRENT_LIST_DIR}/src/main.cpp ${CMAKE_CURRENT_LIST_DIR}/src/judge0.cpp)
target_include_directories(hello PRIVATE ${CMAKE_CURRENT_LIST_DIR}/include)