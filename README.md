# Jekyll::NginxConfig

This tool was written to fulfill the need of generating the necessary URL rewrite directives for use in an `nginx` reverse
proxy. The primary objective is to generate rewrites from post URL formats you have used in the past so that they will redirect to the current URL format 
that you are using.

### Installation

Add this to your `Gemfile`:

```
group :jekyll_plugins do
  gem 'jekyll-nginx-config'
end
```

> You have to specify it under the `:jekyll_plugins` group otherwise Jekyll won't recognize the `nginx_config` command.

Then run `bundle isntall`.

> If using a global Jekyll installation, just do `gem install jekyll-nginx-config`

### Basic Configuration & Usage

In your Jekyll config file (typically `_config.yml`), tell it what the older post URL format was:

```yaml
permalink: "/blog/:category/:title/" # Used to be 'pretty'

nginx:
  from_format: "/:category/:year/:month/:day/:title/" # Equivalent to 'pretty'
  proxy_host: 'static.youraddress.com'
  proxy_port: 80
```

Run the following command to generate the nginx configuration:

```bash
jekyll nginx_config > redirects.conf
```

> If installed with Bundler, do `bundle exec jekyll ...` instead.

### Advance Configuration

#### Custom redirects

```yaml
nginx:
  from_format: ...
  proxy_host: ...
  proxy_port: ...
  redirects:
    - from: "^/some/path(/.*)?"
      to: "/new-destination$1"
      type: redirect
      
    - from: "^/another-path(/.*)?"
      to: "/another-destination$1"
      type: permanent
```

Items under `nginx.redirects` are simply translated straight into `rewrite` directives. In this case:

```nginx

...

rewrite ^/some/path(/.*)? /new-destination$1 redirect;
rewrite ^/another-path(/.*)? /another-destination$1 permanent;

... 

```

To know more, [see documentation about Nginx's `rewrite` directives](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html)

#### Configuring past URLs in a post's front-matter

You can specify past URLs of certain posts like this:

```yaml
---
title: "Some awesome blog post"
layout: post
past_urls:
  - /blog/development/some-awesom-blog-post/ # Typo in title from last week's blog-post
---

Hello, world! ...
```

#### CLI overrides

You can specify proxy host and proxy port settings through the command line. You can use this if you wish to override the values hard-coded in your configuration file:

```
jekyll nginx_config --proxy_host=staging-static.youradress.com --proxy_host=8080 > staging-redirects.conf
```

The command also take the same set of options as `jekyll build`, like `--source`, `--config`, `--drafts`, etc. They mean the same thing in this command as they do in `jekyll build`.

You can also specify your own Liquid template file to use if you wish to have complete control on the resulting nginx config file. Use `--config_template <PATH TO LIQUID TEMPLATE>`.


