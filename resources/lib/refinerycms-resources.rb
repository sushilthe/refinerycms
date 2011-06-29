require 'dragonfly'
require 'rack/cache'
require 'refinerycms-core'

module Refinery
  module Resources

    class << self
      attr_accessor :root
      def root
        @root ||= Pathname.new(File.expand_path('../../', __FILE__))
      end
    end

    autoload :Dragonfly, File.expand_path('../refinery/resources/dragonfly', __FILE__)

    class Engine < ::Rails::Engine
      isolate_namespace ::Refinery

      initializer 'resources-with-dragonfly', :before => "init plugin" do |app|
        ::Refinery::Resources::Dragonfly.attach!(app)
      end

      initializer "init plugin", :after => :set_routes_reloader do |app|
        ::Refinery::Plugin.register do |plugin|
          plugin.pathname = root
          plugin.name = 'refinery_files'
          plugin.url = app.routes.url_helpers.refinery_admin_resources_path
          plugin.menu_match = /(refinery|admin)\/(refinery_)?(files|resources)$/
          plugin.version = %q{1.1.0}
          plugin.activity = {
            :class => ::Refinery::Resource
          }
          plugin.submenu_items = {
            "Upload a file" => app.routes.url_helpers.new_refinery_admin_resource_path(:dialog => true,
                                                                                       :width => 600,
                                                                                       :height => 300)
          }
        end
      end
    end
  end
end

::Refinery.engines << 'resources'
