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

```
{% include foo.html %}                // renders _includes/foo.html
{% include foo.html happy="yep"  %}   // samea as above but {{ include.happy }} == "yep"
```

Include partials stored as a variable.

```
{% assign post_sidebar = "post_sidebar.html" %}
{% include post_sidebar %}   // renders _includes/post_sidebar.html
```

Include partials conditionally, using `if`, `unless` and ternary logic.

```
{% include sidebar.html if site.theme.sidebar %}
{% include comments.html unless page.comments == false %}
{% include (post ? post_sidebar : page_sidebar) %}
```

Filter included partials.

```
{% include foo.html %}           //=> Yo, what's up
{% include foo.html | upcase %}  //=> YO, WHAT'S UP
```

Include partials from an Octopress Ink plugin.

```
{% include [plugin-slug]:[plugin-name] %}  // Syntax
{% include theme:sidebar.html %}           // Include the sidebar from a theme plugin
{% include twitter:feed.html %}            // Include the feed from a twitter plugin
```

## Contributing

1. Fork it ( https://github.com/octopress/include-tag/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
