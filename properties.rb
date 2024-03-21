module RuboCop
  module Cop
    module Chromebrew
      class PackageProperties < Base
        MSG = "Packages should have properties for description, homepage, version, license and compatibility, in that order."
        def_node_matcher :is_package, <<~PATTERN
          (class
            (const nil?  _)
            (const nil? {:Package | :Autotools | :CMake | :Meson | :PERL | :Pip | :Python | :Qmake | :Ruby})
            ...)
        PATTERN

        def_node_matcher :package_properties, <<~PATTERN
          (class
            (const nil? _)
            (const nil? {:Package | :Autotools | :CMake | :Meson | :PERL | :Pip | :Python | :Qmake | :Ruby})
            (begin
              (send nil? $_
                ...)
              (send nil? $_
                ...)
              (send nil? $_
                ...)
              (send nil? $_
                ...)
              (send nil? $_
                ...)
            ...)
          )
        PATTERN
        def on_class(node)
          # Less than ideal hack to skip buildsystems
          return if processed_source.buffer.name.include?('buildsystems')
          return if is_package(node).nil?
          add_offense(node, message: "Packages should have a description property") unless package_properties(node).include?(:description)
          add_offense(node, message: "Packages should have a homepage property") unless package_properties(node).include?(:homepage)
          add_offense(node, message: "Packages should have a version property") unless package_properties(node).include?(:version)
          add_offense(node, message: "Packages should have a license property") unless package_properties(node).include?(:license)
          add_offense(node, message: "Packages should have a compatibility property") unless package_properties(node).include?(:compatibility)
          # if is_package(node) != [ "description", "homepage", "version", "license", "compatibility" ]
          #   add_offense(node, message: "")
          # puts node
          # puts is_package(node)
          # puts is_package(node).join
          # is_package(node).each do |uh|
          #   puts "NODE: #{uh}"
          # end
          # add_offense(node)
        end
      end
    end
  end
end
