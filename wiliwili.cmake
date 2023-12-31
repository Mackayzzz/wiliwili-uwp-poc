cmake_minimum_required(VERSION 3.20)

# Project Info
project(wiliwili-uwp)

set(DISABLE_OPENCC ON)
set(VERIFY_SSL OFF)

set(TEMPLATE_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/wiliwili-uwp/Package.appxmanifest
    ${CMAKE_CURRENT_SOURCE_DIR}/wiliwili-uwp/Windows_TemporaryKey.pfx
)

file(GLOB_RECURSE PACKAGE_ASSETS_FILES "${CMAKE_CURRENT_SOURCE_DIR}/wiliwili-uwp/Assets/*")
set_property(SOURCE ${PACKAGE_ASSETS_FILES} PROPERTY VS_DEPLOYMENT_CONTENT 1)
set_property(SOURCE ${PACKAGE_ASSETS_FILES} PROPERTY VS_DEPLOYMENT_LOCATION "Assets")

# resource
set(PROJECT_RESOURCES "${CMAKE_CURRENT_SOURCE_DIR}/wiliwili/resources")

function(add_deployment_content BASE_PATH FILE)
    set_property(SOURCE ${FILE} PROPERTY VS_TOOL_OVERRIDE None)
    set_property(SOURCE ${FILE} PROPERTY VS_DEPLOYMENT_CONTENT 1)
    get_filename_component(FILE_DIR ${FILE} DIRECTORY ABSOLUTE)
    file(RELATIVE_PATH TARGET_PATH ${BASE_PATH} ${FILE_DIR})
    set_property(SOURCE ${FILE} PROPERTY VS_DEPLOYMENT_LOCATION ${TARGET_PATH})
endfunction(add_deployment_content)

file(GLOB_RECURSE PROJECT_RESOURCES_FILES "${PROJECT_RESOURCES}/*")

foreach(FILE IN LISTS PROJECT_RESOURCES_FILES)
    add_deployment_content("${PROJECT_RESOURCES}/.." "${FILE}")
endforeach()
source_group(TREE "${PROJECT_RESOURCES}" PREFIX "resource" FILES ${PROJECT_RESOURCES_FILES})

# source 
set(HEADER_INCLUDES)

file(GLOB_RECURSE MAIN_SRC "${CMAKE_CURRENT_SOURCE_DIR}/wiliwili/wiliwili/source/*.cpp")
list(APPEND HEADER_INCLUDES ${CMAKE_CURRENT_SOURCE_DIR}/wiliwili/wiliwili/include)
list(APPEND HEADER_INCLUDES ${CMAKE_CURRENT_SOURCE_DIR}/wiliwili/wiliwili/include/api)

file(GLOB_RECURSE PDR_SRC ${CMAKE_CURRENT_SOURCE_DIR}/wiliwili/library/libpdr/src/*.cpp)
list(APPEND HEADER_INCLUDES ${CMAKE_CURRENT_SOURCE_DIR}/wiliwili/library/libpdr/include)

file(GLOB_RECURSE PYSTRING_SRC ${CMAKE_CURRENT_SOURCE_DIR}/wiliwili/library/pystring/*.cpp)
list(APPEND HEADER_INCLUDES ${CMAKE_CURRENT_SOURCE_DIR}/wiliwili/library/pystring)

source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}/wiliwili" PREFIX "sources" FILES ${MAIN_SRC} ${PDR_SRC} ${PYSTRING_SRC})

# Target
add_executable(${PROJECT_NAME} WIN32 ${MAIN_SRC} ${PDR_SRC} ${PYSTRING_SRC} ${TEMPLATE_FILES} ${PROJECT_RESOURCES_FILES} ${PACKAGE_ASSETS_FILES})

find_package(cppwinrt CONFIG REQUIRED)
target_link_libraries(${PROJECT_NAME} Microsoft::CppWinRT)

find_package(unofficial-lunasvg CONFIG REQUIRED)
target_link_libraries(${PROJECT_NAME} unofficial::lunasvg::lunasvg)

find_package(unofficial-mongoose CONFIG REQUIRED)
target_link_libraries(${PROJECT_NAME} unofficial::mongoose::mongoose)

find_package(unofficial-nayuki-qr-code-generator CONFIG REQUIRED)
target_link_libraries(${PROJECT_NAME} unofficial::nayuki-qr-code-generator::nayuki-qr-code-generator)

# this is heuristically generated, and may not be correct
# find_package(pystring CONFIG REQUIRED)
# target_link_libraries(${PROJECT_NAME} pystring::pystring)
# find_path(PYSTRING_INCLUDE_DIR pystring.h PATH_SUFFIXES pystring REQUIRED)
# list(APPEND HEADER_INCLUDES ${PYSTRING_INCLUDE_DIR})

find_package(OpenSSL REQUIRED)
target_link_libraries(${PROJECT_NAME} OpenSSL::SSL OpenSSL::Crypto)

find_package(CURL REQUIRED)
target_link_libraries(${PROJECT_NAME} CURL::libcurl)

find_package(ZLIB REQUIRED)
target_link_libraries(${PROJECT_NAME}  ZLIB::ZLIB)

find_package(cpr CONFIG REQUIRED)
target_link_libraries(${PROJECT_NAME} cpr::cpr)

#set(CPR_USE_SYSTEM_CURL ON)
#set(CPR_FORCE_WINSSL_BACKEND ON)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/wiliwili/library/cpr EXCLUDE_FROM_ALL)
#target_link_libraries(${PROJECT_NAME} cpr::cpr)

target_link_libraries(${PROJECT_NAME} borealis)

target_include_directories(${PROJECT_NAME} PUBLIC  ${HEADER_INCLUDES} )
target_compile_options(${PROJECT_NAME} PRIVATE -DBRLS_RESOURCES_DIR=".")
target_compile_definitions(${PROJECT_NAME} PRIVATE  BOREALIS_USE_STD_THREAD __WINRT__ BOREALIS_USE_D3D11 __SDL2__ __PLAYER_WINRT__ NOMINMAX _SILENCE_ALL_CXX17_DEPRECATION_WARNINGS _WINSOCK_DEPRECATED_NO_WARNINGS _CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_WARNINGS)
