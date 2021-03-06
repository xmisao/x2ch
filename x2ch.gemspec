lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'x2ch/version'

Gem::Specification.new do |s|
  s.name        = 'x2ch'
  s.version     = X2CH::VERSION
  s.date        = '2015-03-26'
  s.summary     = "2ch.sc downloader and parser library"
  s.description = "2ch.sc downloader and parser library"
  s.authors     = ["xmisao"]
  s.email       = 'mail@xmisao.com'
  s.files       = ["lib/x2ch.rb", "lib/x2ch/version.rb"]
  s.homepage    = 'https://github.com/xmisao/x2ch'
  s.license     = 'MIT'
end
