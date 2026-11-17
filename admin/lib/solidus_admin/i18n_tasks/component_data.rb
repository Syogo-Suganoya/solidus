# frozen_string_literal: true

require "i18n/tasks"

module SolidusAdmin
  module I18nTasks
    # An i18n-tasks data adapter that, on top of regular locale files, knows
    # about the translations defined in component sidecar files.
    #
    # A sidecar file (`app/components/solidus_admin/foo/component.yml`) holds
    # keys relative to its component: at runtime ViewComponent nests them under
    # the component's i18n scope (`solidus_admin.foo.component`), and a
    # component also inherits the translations of its ancestors. Neither is
    # visible from the YAML files alone, so this adapter rebuilds both.
    #
    # Inheritance is resolved statically, from the `class A < B` line of each
    # component, so that no application code needs to be loaded.
    #
    # Sidecar files are read-only for i18n-tasks: tasks that write locale data
    # (`normalize`, `add-missing`, `remove-unused`...) must not be used with
    # this adapter, as they would write the component keys to the regular
    # locale files.
    #
    # Configuration (in `config/i18n-tasks.yml`):
    #
    #   data:
    #     adapter: SolidusAdmin::I18nTasks::ComponentData
    #     components_root: app/components
    class ComponentData < ::I18n::Tasks::Data::FileSystem
      # File format adapters are registered per class, and not inherited.
      register_adapter :yaml, "*.yml", ::I18n::Tasks::Data::Adapter::YamlAdapter

      SIDECAR_EXTENSION = ".yml"
      SUPERCLASS_PATTERN = /^\s*class\s+[\w:]+\s*<\s*([\w:]+)/

      protected

      def read_locale(locale, paths: config[:read])
        tree = super
        return tree unless paths.equal?(config[:read])

        component_scopes.each do |scope, sidecar_files|
          sidecar_files.each do |path|
            data = (load_file(path) || {})[locale]
            next if data.blank?

            nested = scope.split(".").reverse.inject(data) { |memo, key| {key => memo} }
            tree.merge!(
              ::I18n::Tasks::Data::Tree::Siblings.from_nested_hash(locale => nested).tap do |siblings|
                siblings.leaves { |leaf| leaf.data.update(path:, locale:) }
              end
            )
          end
        end

        tree
      end

      private

      def components_root
        config[:components_root] || "app/components"
      end

      # @return [Hash{String => Array<String>}] for each component i18n scope,
      #   the sidecar files providing its translations, ancestors first so
      #   that a component overrides what it inherits.
      def component_scopes
        @component_scopes ||= Dir.glob(File.join(components_root, "**", "*.rb")).sort.to_h do |component_file|
          [scope_for(component_file), lineage(component_file).reverse.flat_map { sidecar_files(_1) }]
        end
      end

      def scope_for(component_file)
        relative_path(component_file).delete_suffix(".rb").tr("/", ".")
      end

      # @return [Array<String>] the component file followed by its ancestors
      def lineage(component_file, seen = [])
        return seen if component_file.nil? || seen.include?(component_file)

        lineage(superclass_file(component_file), seen + [component_file])
      end

      def superclass_file(component_file)
        superclass = File.read(component_file)[SUPERCLASS_PATTERN, 1] or return
        path = File.join(components_root, "#{ActiveSupport::Inflector.underscore(superclass)}.rb")

        path if File.exist?(path)
      end

      def sidecar_files(component_file)
        [component_file.sub(/\.rb\z/, SIDECAR_EXTENSION)].select { File.exist?(_1) }
      end

      def relative_path(path)
        path.delete_prefix(components_root).delete_prefix("/")
      end
    end
  end
end
