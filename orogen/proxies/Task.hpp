/* Generated from orogen/lib/orogen/templates/proxies/Task.hpp */

#ifndef <%= project.name.upcase %>_<%= task.basename.upcase %>_PROXY_TASK_HPP
#define <%= project.name.upcase %>_<%= task.basename.upcase %>_PROXY_TASK_HPP


#include <rtt/transports/corba/TaskContextProxy.hpp>

#include <<%= task.superclass.header_file %>>
<% if !task.new_operations.empty? %>
#include <rtt/Operation.hpp>
<% end %>
<% if !task.all_ports.empty? %>
#include <rtt/Port.hpp>
#include <orocos_cpp_base/ProxyPort.hpp>
<% end %>
<% if task.extended_state_support? %>
#include <<%= project.typekit.name %>/TaskStates.hpp>
<% end %>

<% task.self_properties.sort_by(&:name).each do |p| %>
<%   type = p.type %>
<%=  project.typekit.cxx_gen_includes(*project.typekit.include_for_type(type)) %>
extern template class RTT::Property< <%= type.cxx_name %> >;
<% end %>

<% task.self_attributes.sort_by(&:name).each do |a| %>
<%   type = a.type %>
<%=  project.typekit.cxx_gen_includes(*project.typekit.include_for_type(type)) %>
extern template class RTT::Attribute< <%= type.cxx_name %> >;
<% end %>

<% task.self_ports.sort_by(&:name).each do |p| %>
<%   type = p.type %>
<%=  project.typekit.cxx_gen_includes(*project.typekit.include_for_type(type)) %>
extern template class <%= p.orocos_class %>< <%= type.cxx_name %> >;
extern template class RTT::base::ChannelElement< <%= type.cxx_name %> >;
<% end %>

<% types = task.self_dynamic_ports.
        map { |p| [p.orocos_class, p.type] if p.type }.
        compact %>
<% types.each do |orocos_class, type| %>
<%=    project.typekit.cxx_gen_includes(*project.typekit.include_for_type(type)) %>
extern template class <%= orocos_class %>< <%= type.cxx_name %> >;
extern template class RTT::base::ChannelElement< <%= type.cxx_name %> >;
<% end %>

<% task.self_operations.sort_by(&:name).each do |op| %>
<%    op.used_types.each do |type| %>
<%=       project.typekit.cxx_gen_includes(*project.typekit.include_for_type(type)) %>
<%    end %>
<% end %>

namespace <%= project.name %> {

namespace proxies {
    
class <%= task.basename %>Initializer : public RTT::corba::TaskContextProxy
{
    public:
        <%= task.basename %>Initializer(std::string location, bool is_ior = false);

        static void initTypes();
};

class <%= task.basename %> : public <%= task.basename %>Initializer
{
    protected:

    public:
        /** TaskContext constructor for <%= task.basename %>
         * \param name Name of the task. This name needs to be unique to make it identifiable via nameservices.
         * \param initial_state The initial TaskState of the TaskContext. Default is Stopped state.
         */
        <%= task.basename %>(std::string location, bool is_ior = false);

        void synchronize();
<%= 
result = ""
task.each_input_port do |port|
    result << "        InputProxyPort< #{port.type.cxx_name} > #{port.name};\n"
end

task.each_output_port do |port|
    result << "        OutputProxyPort< #{port.type.cxx_name} > #{port.name};\n"    
end

result

%>

<%= 
result = ""
task.each_property.to_a.uniq{|s| s.name}.each do |property|
    result << "        RTT::Property< #{property.type.cxx_name} > &#{property.name};\n"
end
result
%>

<%= 
result = ""
task.each_operation do |operation|
    result << "        #{operation.signature};\n"
end
result
%>

};
}
}
#endif // TASK_H
