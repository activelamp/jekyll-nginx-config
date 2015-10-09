module Jekyll
  module NginxConfig
    class NginxConfigCommand < Jekyll::Command
      class << self
        def init_with_program(prog)
          prog.command(:nginx_config) do |c|
            c.syntax 'nginx_config [options]'
            c.description 'Generate Nginx proxy config'
            c.option 'proxy_host', '-H', '--proxy_host HOST', String, 'FQDN of Jekyll site to proxy to. Used for `proxy_set_header Host <proxy_host>`.'
            c.option 'proxy_port', '-P', '--proxy_port PORT', Integer, 'Port on proxy host serving the Jekyll site. Used for `proxy_pass http://<proxy_host>:<proxy_port>`. Defaults to `80`.'
            c.option 'config_template', '-T', '--config_template TEMPLATE_FILE', String, 'Your own Liquid template file that compose into an nginx config.'
            add_build_options(c)
            c.action do |args, options|
              options['quiet'] = true
              exit(1) unless process options
            end
          end
        end

        def process(options)


          options = configuration_from_options(options)
          site = ::Jekyll::Site.new(options)
          return nil unless site.config['nginx']

          site.config['nginx']['proxy_host'] = options['proxy_host'] || site.config['nginx']['proxy_host']
          site.config['nginx']['proxy_port'] = options['proxy_port'] || site.config['nginx']['proxy_port']

          unless site.config['nginx']['proxy_host'].length > 0
            Jekyll.logger.error 'You must at least specify `proxy_host`.'
            return nil
          end

          site.read
          redirects = Array.new
          raw_redirects = site.config['nginx']['redirects'] || Array.new
          raw_redirects = raw_redirects.map do |r|
            r['redirect'] ||= 'redirect'
            r
          end

          incomplete = raw_redirects.select do |r|
            !(r.has_key?('from') && r.has_key?('to') && r['from'].length > 0 && r['to'].length > 0)
          end

          if incomplete.length > 0
            Jekyll.logger.error 'Check [nginx][redirects] in your config for incomplete entries. Entries should at least have `from` and `to`'
            return nil
          end

          site.posts.each do |post|
            pretty_url = ::Jekyll::URL.new(
              :template => site.config['nginx']['from_format'] || "/:year/:month/:day/:title/",
              :placeholders => post.url_placeholders
            ).to_s
            redirects.push('from' => Regexp.escape(pretty_url), 'to' => post.url)

            if post.data.has_key?('past_urls') && post.data['past_urls'].is_a?(Array)
              post.data['past_urls'].each do |past_url|
                redirects.push('from' => Regexp.escape(past_url), 'to' => post.url)
              end
            end
          end

          if options['config_template']
            template = Liquid::Template.parse(File.read(options['config_template']))
          else
            template = Liquid::Template.parse(File.read(File.join(File.dirname(__FILE__), 'nginx-template.conf')))
          end

          conf = template.render({
            'proxy_host' => site.config['nginx']['proxy_host'],
            'proxy_port' => site.config['nginx']['proxy_port'],
            'redirects' => redirects,
            'raw_redirects' => site.config['nginx']['redirects']
          })
          puts conf
          true
        end
      end
    end
  end
end
