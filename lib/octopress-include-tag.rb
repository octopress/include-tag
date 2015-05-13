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

        def initialize(tag_name, markup, tokens)
          @tag_markup = markup
          @tag_name = tag_name

          plugin_matched = markup.strip.match(PLUGIN_SYNTAX)

          if plugin_matched
            @plugin = plugin_matched['plugin'].strip
            @path = plugin_matched['path'].strip
          end

          super(tag_name, safe_markup(markup).join(' '), tokens)
        end

        # Strip specials out of markup so that it is suitable for Jekyll 
        def safe_markup(markup)
          file = markup.strip.match(/\S+/)[0]
          params = ''

          if matched = markup.match(VALID_SYNTAX)
            params = matched[0]
          end

          if match_var = tag_markup.match(VARIABLE_SYNTAX)
            file = match_var['variable']
          end

          [file, params]
        end

        def render(context)

          # If conditional statements are present, only continue if they are true
          #
          markup = TagHelpers::Conditional.parse(tag_markup, context)
          return unless markup

          # If there are filters, store them for use later and strip them out of markup
          #
          if matched = markup.match(TagHelpers::Var::HAS_FILTERS)
            markup = matched['markup']
            filters = matched['filters']
          end

          # If there is a ternary expression, replace it with the true result
          #
          markup = TagHelpers::Var.evaluate_ternary(markup, context)

          # Paths may be variables, check context to retrieve proper path
          #
          markup = TagHelpers::Path.parse(markup, context)

          # If markup references a plugin e.g. plugin-name:include-file.html
          #
          if matched = markup.strip.match(PLUGIN_SYNTAX)

            content = render_ink_include(matched['plugin'], matched['path'], context)
            
          # Otherwise, use Jekyll's default include tag
          else
            @file, @params = safe_markup(markup)
            content = super(context).strip
          end

          unless content.nil? || filters.nil?
            content = TagHelpers::Var.render_filters(content, filters, context)
          end

          content
        end

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

