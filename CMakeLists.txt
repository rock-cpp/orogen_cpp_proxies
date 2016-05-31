PROJECT(CppProxies)
cmake_minimum_required(VERSION 2.6)
find_package(Rock)
rock_init(orocos_cpp_base 0.1)
set(OROCOS_TARGET "gnulinux")
rock_standard_layout()

install(FILES ${PROJECT_SOURCE_DIR}/orogen/proxies/Task.cpp
        DESTINATION ${CMAKE_INSTALL_PREFIX}/share/orogen/templates/proxies)

install(FILES ${PROJECT_SOURCE_DIR}/orogen/proxies/Task.hpp
        DESTINATION ${CMAKE_INSTALL_PREFIX}/share/orogen/templates/proxies)

install(FILES ${PROJECT_SOURCE_DIR}/orogen/proxies/Forward.hpp
        DESTINATION ${CMAKE_INSTALL_PREFIX}/share/orogen/templates/proxies)

install(FILES ${PROJECT_SOURCE_DIR}/orogen/proxies/proxies.pc
        DESTINATION ${CMAKE_INSTALL_PREFIX}/share/orogen/templates/proxies)

install(FILES ${PROJECT_SOURCE_DIR}/orogen/proxies/CMakeLists.txt
        DESTINATION ${CMAKE_INSTALL_PREFIX}/share/orogen/templates/proxies)

install(FILES ${PROJECT_SOURCE_DIR}/orogen/orogen_plugin.rb
        DESTINATION ${CMAKE_INSTALL_PREFIX}/share/orogen/plugins
        RENAME cpp_proxies_plugin.rb)

