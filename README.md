# Octopress Include Tag

This tag replaces Jekyll's include and adds support for conditional rendering, in-line filters and including partials from Octopress Ink plugins.

## Installation

Add this line to your application's Gemfile:

    gem 'octopress-include-tag'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install octopress-include-tag

## Usage

Use this just like the regular Jekyll include tag.

    {% include foo.html %}                // renders _includes/foo.html
    {% include foo.html happy="yep"  %}   // samea as above but {{ include.happy }} == "yep"

Include partials stored as a variable.

    {% assign post_sidebar = "post_sidebar.html" %}
    {% include post_sidebar %}   // renders _includes/post_sidebar.html

Include partials conditionally, using `if`, `unless` and ternary logic.

    {% include sidebar.html if site.theme.sidebar %}
    {% include comments.html unless page.comments == false %}
    {% include (post ? post_sidebar : page_sidebar) %}

Filter included partials.

    {% include foo.html %}           //=> Yo, what's up
    {% include foo.html | upcase %}  //=> YO, WHAT'S UP

Yes, it can handle a complex combination of features… but can you?

    {% include (post ? post_sidebar : page_sidebar) | smart_quotes unless site.theme.sidebar == false %}

### Include partials with an Octopress Ink plugin.

It's easy to include a partial from an Ink theme or plugin.

Here's the syntax

    {% include [plugin-slug]:[partial-name] %}

Some examples:

    {% include theme:sidebar.html %}   // Include the sidebar from a theme plugin
    {% include twitter:feed.html %}    // Include the feed from a twitter plugin

#### Overriding theme/plugin partials

Plugins and themes use this tag internally too. For example, the [octopress-feeds plugin](https://github.com/octopress/feeds/blob/master/assets/pages/article-feed.xml#L10) uses the include tag to
render partials for the RSS feed.

    {% for post in site.articles %}
      <entry>
        {% include feeds:entry.xml %}
      </entry>
    {% endfor %}


If you want to make a change to the `entry.xml` partial, you could create your own version at `_plugins/feeds/includes/entry.xml`.
Now whenever `{% include feeds:entry.xml %}` is called, the include tag will use *your* local partial instead of the plugin's partial.

Note: To make overriding partials easier, you can copy all of a plugin's partials to your local override path with the Octopress Ink command:

    octopress ink copy [plugin-slug] [options]

To copy all includes from the feeds plugin, you'd run:

    octopress ink copy feeds --includes

This will copy all of the partials from octopress-feeds to `_plugins/feeds/includes/`. Modify any of the partials, and delete those that you want to be read from the plugin.

To list all partials from a plugin, run:

    octopress ink list [plugin-slug] --includes

Note: When a plugin is updated, your local partials may be out of date, but will still override the plugin's partials. Be sure to watch changelogs and try to keep your modifications current.

## Contributing

1. Fork it ( https://github.com/octopress/include-tag/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
