cmake_minimum_required(VERSION 3.2)

project(imgtool)

add_definitions(-D_REENTRANT)
add_compile_options(-Wall -Werror-implicit-function-declaration)

add_library(img img.c sha256.c)

add_executable(imgcreate imgcreate.c)
target_link_libraries(imgcreate img)

add_executable(imginfo imginfo.c)
target_link_libraries(imginfo img)
