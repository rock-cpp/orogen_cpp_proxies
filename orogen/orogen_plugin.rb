require 'set'

module Orocos
    module Generation
        class CppProxyGeneration
            attr_reader :project
            attr_reader :proxy_gen
            attr_reader :task
            def initialize(cmp, t)
                @project = cmp
                @task = t
                @proxy_gen = self
            end
            
            def dependencies(includeSelf = true)
                result = []
                if(includeSelf and project.typekit)
                    tk = project.typekit
                    result << BuildDependency.new(
                        "#{tk.name}_TYPEKIT",
                        "#{tk.name}-typekit-gnulinux").
                        in_context('core', 'include').
                        in_context('core', 'link')
                        
                    project.enabled_transports.each do |transport_name|
                        result << BuildDependency.new(
                                "#{tk.name}_TRANSPORT_#{transport_name.upcase}",
                                "#{tk.name}-transport-#{transport_name}-gnulinux").
                                in_context('core', 'include').
                                in_context('core', 'link')
                    end
                end
                project.used_typekits.each do |tk|
                    next if tk.name == "rtt"
                    next if tk.name == "logger"
                    result << BuildDependency.new(
                        "#{tk.name}_TYPEKIT",
                        tk.pkg_name).
                        in_context('core', 'include').
                        in_context('core', 'link')
                        
                    project.enabled_transports.each do |transport_name|
                        result << BuildDependency.new(
                            "#{tk.name}_TRANSPORT_#{transport_name.upcase}",
                            tk.pkg_transport_name(transport_name)).
                            in_context('core', 'include').
                            in_context('core', 'link')
                    end                    
                end
                result << BuildDependency.new(
                            "orocos_cpp_base",
                            "orocos_cpp_base").
                            in_context('core', 'include').
                            in_context('core', 'link')
                
                result
            end

            # Generates the code associated with cpp proxies
            def generate
                template_dir = File.join(File.dirname(__FILE__), "../templates")
                proxy_hpp = Generation.render_template template_dir, "proxies", "Task.hpp", binding
                proxy_cpp = Generation.render_template template_dir, "proxies", "Task.cpp", binding
                file_proxy_hpp = Generation.save_automatic("proxies", "#{task.basename}.hpp", proxy_hpp)
                file_proxy_cpp = Generation.save_automatic("proxies", "#{task.basename}.cpp", proxy_cpp)

                cmake = Generation.render_template template_dir, 'proxies', 'CMakeLists.txt', binding
                Generation.save_automatic('proxies', "CMakeLists.txt", cmake)
                
                pc = Generation.render_template template_dir, "proxies", "proxies.pc", binding
                Generation.save_automatic("proxies", "#{project.name}-proxies.pc.in", pc)
            end
        end
    end
end

class CPPProxyPlugin <  OroGen::Spec::TaskModelExtension

    def initialize()
        super("CPPProxyPlugin")
    end

    # implement extension for task
    def pre_generation_hook(task)
#         opName = "getExtendedStateMapping"
#         if task.extended_state_support? && !task.operations.include?(opName)
#             method = "    std::vector<std::string> ret;\n"
#             states = task.each_state.to_a
#             states.each_with_index do |(state_name, state_type), i|
#                 method += "    ret.push_back(\"#{task.state_local_value_name(state_name, state_type)}\"); \n"
#             end
#             method += "    return ret;"
# 
#             task.hidden_operation(opName).
#                 returns("std::vector<std::string>").
#                 base_body(method).
#                 doc("returns a vector of string, that corresponds to the extended task states on the state port").
#                 runs_in_caller_thread
#         end        
    end
    
    def post_generation_hook(task)
        proxyGen = Orocos::Generation::CppProxyGeneration.new(task.project, task)
        proxyGen.generate()
    end
    
    def each_auto_gen_source_directory(&block)
        return enum_for(:each_test) unless block_given?
        yield "proxies"
    end

    def registered_on(task_context)
        #generate empty CMakeList as default
        #this is needed, as the build is included
        #even if no task is generated
        Orocos::Generation.save_automatic('proxies', "CMakeLists.txt", "")
    end

end

class OroGen::Spec::TaskContext
    def cpp_proxies
        if !find_extension("CPPProxyPlugin")
            register_extension(CPPProxyPlugin.new)
            puts("CPPProxyPlugin active")
        end
    end
end