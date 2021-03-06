# Generated from orogen/lib/orogen/templates/proxies/CMakeLists.txt


SET(PROXYLIB_NAME <%= project.name %>-proxies)

add_definitions(-DRTT_COMPONENT)

<% 
    pkg_conf_deps = proxy_gen.dependencies(false)
%>
<%= Orocos::Generation.cmake_pkgconfig_require(pkg_conf_deps) %>

include(<%= project.name %>TaskLib)

ADD_LIBRARY(${PROXYLIB_NAME} SHARED 
<%= 
   task_files = String.new
   project.self_tasks.each do |task| 
     task_files << "    #{task.basename}.cpp\n"
   end
   task_files
%>)

<%= 
    result = ""
if(project.typekit)
    tk = project.typekit
    result +=
"target_link_libraries(${PROXYLIB_NAME} PRIVATE #{tk.name}-typekit-gnulinux)
"
        
    project.enabled_transports.each do |transport_name|
    result +=
"target_link_libraries(${PROXYLIB_NAME} PRIVATE #{tk.name}-transport-#{transport_name}-gnulinux)
"
    end
end
    result
%>

find_package(RTTPlugin COMPONENTS rtt-typekit rtt-transport-corba rtt-transport-mqueue)
target_link_libraries(${PROXYLIB_NAME} PRIVATE ${RTT_PLUGIN_rtt-typekit_LIBRARY})
target_link_libraries(${PROXYLIB_NAME} PRIVATE ${RTT_PLUGIN_rtt-transport-corba_LIBRARY})
target_link_libraries(${PROXYLIB_NAME} PRIVATE ${RTT_PLUGIN_rtt-transport-mqueue_LIBRARY})

<% Orocos::Generation.each_pkgconfig_link_dependency('core', pkg_conf_deps) do |dep| %>
<%= "target_link_libraries(${PROXYLIB_NAME} PRIVATE #{dep})\n" %>
<% end %>

target_link_libraries(${PROXYLIB_NAME} INTERFACE ${<%= project.name.upcase %>_TASKLIB_INTERFACE_LIBRARIES})

INSTALL(TARGETS ${PROXYLIB_NAME}
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib/orocos)

    
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${PROXYLIB_NAME}.pc.in
            ${CMAKE_CURRENT_BINARY_DIR}/${PROXYLIB_NAME}.pc @ONLY)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROXYLIB_NAME}.pc
            DESTINATION lib/pkgconfig)

INSTALL(FILES 
<%= 
   include_files = String.new
   project.self_tasks.each do |task| 
     include_files << "    #{task.basename}.hpp\n"
     include_files << "    #{task.basename}Forward.hpp\n"
   end
   include_files
%>
    DESTINATION include/orocos/<%= project.name.downcase %>/proxies/)

