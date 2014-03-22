require_relative 'lib/gitsh/version'

Gem::Specification.new do |s|
  s.author = 'Mike Burns'
  s.email = 'hello@thoughtbot.com'
  s.homepage = 'http://github.com/thoughtbot/gitsh'
  s.platform = Gem::Platform::RUBY
  s.summary = 'An interactive shell for git'
  s.description = %Q{The gitsh program is an interactive shell for git. \
  From within gitsh you can issue any git command, even using your local aliases and configuration.}
  s.name = 'gitsh'
  s.version = Gitsh::VERSION
  s.license = 'MIT'
  s.add_dependency('parslet')
  s.add_development_dependency('rspec')
  s.add_development_dependency('bourne')
  s.add_development_dependency('pry')
  s.require_path = 'lib'
  s.bindir = 'bin'
  s.executables << 'gitsh'
  s.files = Dir['README.md', 'LICENSE',
    'bin',
    'lib/**/*.rb',
    'man/**/*',
    'spec/**/*']
  s.test_files = Dir.glob('spec/**/*_spec.rb')
end
