require File.expand_path('../lib/jekyll-nginx-config/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'jekyll-nginx-config'
  s.version = Jekyll::NginxConfig::VERSION
  s.date = '2015-06-17'
  s.summary = 'Nginx proxy config for Jekyll'
  s.description = 'Generate nginx proxy config for Jekyll.'
  s.authors = ['Bez Hermoso']
  s.email = 'bez@activelamp.com'
  s.files = Dir["lib/**/*"]
  s.homepage = 'https://github.com/activelamp/jekyll-nginx-config'
  s.license = 'MIT'
  s.add_development_dependency 'jekyll', '~> 2.0'
end
