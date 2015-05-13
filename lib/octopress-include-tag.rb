require "octopress-include-tag/version"
require "octopress-tag-helpers"
require "jekyll"

module Octopress
  module Tags
    module Include
      class Tag < Jekyll::Tags::IncludeTag
        PLUGIN_SYNTAX = /(?<plugin>.+?):(?<path>\S+)\s?(?<other>.*)/
        attr_accessor :path
        attr_reader :tag_markup
        attr_reader :tag_name
        attr_accessor :filters

        def initialize(tag_name, markup, tokens)
          @tag_markup = markup
          @tag_name = tag_name

          if matched = markup.strip.match(PLUGIN_SYNTAX)
            @plugin = matched['plugin'].strip
            @path = matched['path'].strip
          end

          # Trigger Jekyll's Include tag with compatible markup
          #
          super(tag_name, safe_markup(markup).join(' '), tokens)
        end

        # Strip specials out of markup so that it is suitable for Jekyll include tag
        #
        def safe_markup(markup)
          file = markup.strip.match(/\S+/)[0]
          params = ''

          if matched = markup.match(VALID_SYNTAX)
            params = matched[0]
          end

          if matched = tag_markup.match(VARIABLE_SYNTAX)
            file = matched['variable']
          end

          [file, params]
        end

        def render(context)

          # Parse special markup until markup is simplified
          return unless markup = parse_markup(context)

          # If markup references a plugin e.g. plugin-name:include-file.html
          #
          if matched = markup.strip.match(PLUGIN_SYNTAX)

            # Call Octopress Ink to render the plugin's include file
            #
            content = render_ink_include(matched['plugin'], matched['path'], context)
            
          else

            # use Jekyll's default include tag
            #
            # Why safe_markup again? In initialize we didn't know what the path would be becuase 
            # we needed the context to parse vars and conditions. Now that we know them, we'll 
            # reset @file and @params as intended in order to render with Jekyll's include tag.
            # 
            @file, @params = safe_markup(markup)
            content = super(context).strip
          end

          unless content.nil? || filters.nil?
            content = TagHelpers::Var.render_filters(content, filters, context)
          end

          content
        end

        # Parses special markup, handling vars, conditions, and filters
        # Returns:
        #  - include path or nil if markup conditionals evaluate false
        #
        def parse_markup(context)
          # If conditional statements are present, only continue if they are true
          #
          return unless markup = TagHelpers::Conditional.parse(tag_markup, context)

          # If there are filters, store them for use later and strip them out of markup
          #
          if matched = markup.match(TagHelpers::Var::HAS_FILTERS)
            markup = matched['markup']
            @filters = matched['filters']
          end

          # If there is a ternary expression, replace it with the true result
          #
          markup = TagHelpers::Var.evaluate_ternary(markup, context)

          # Paths may be variables, check context to retrieve proper path
          #
          markup = TagHelpers::Path.parse(markup, context)

          markup
        end

        # Call Octopress Ink to render the plugin's include file
        #
        def render_ink_include(plugin, file, context)
          begin
            content = Octopress::Ink::Plugins.include(plugin, path).read
          rescue => error
            msg = "Include failed: {% #{tag_name} #{tag_markup}%}.\n"
            if !defined?(Octopress::Ink)
              msg += "To include plugin partials, first install Octopress Ink."
            else
              msg += "The plugin '#{plugin}' does not have an include named '#{path}'."
            end
            raise IOError.new(msg)
          end

          partial = Liquid::Template.parse(content)

          context.stack {
            context['include'] = parse_params(context)
            context['plugin'] = Octopress::Ink::Plugins.plugin(plugin).config(context['lang'])
            partial.render!(context)
          }.strip
        end
      end
    end
  end
end

Liquid::Template.register_tag('include', Octopress::Tags::Include::Tag)

if defined? Octopress::Docs
  Octopress::Docs.add({
    name:        "Octopress Include Tag",
    gem:         "octopress-include-tag",
    version:     Octopress::Tags::Include::VERSION,
    description: "Replaces Jekyll's include tag and adds conditional rendering, in-line filters and Octopress Ink features.",
    path:        File.expand_path(File.join(File.dirname(__FILE__), "../")),
    type:        "tag",
    source_url:  "https://github.com/octopress/include-tag"
  })
end

