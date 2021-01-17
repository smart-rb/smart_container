# frozen_string_literal: true

require_relative 'lib/smart_core/container/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = Gem::Requirement.new('>= 2.4.10')

  spec.name    = 'smart_container'
  spec.version = SmartCore::Container::VERSION
  spec.authors = ['Rustam Ibragimov']
  spec.email   = ['iamdaiver@gmail.com']

  spec.summary     = 'IoC/DI Container'
  spec.description = 'Thread-safe semanticaly-defined IoC/DI Container'
  spec.homepage    = 'https://github.com/smart-rb/smart-container'
  spec.license     = 'MIT'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/smart-rb/smart-container'
  spec.metadata['changelog_uri']   = 'https://github.com/smart-rb/smart-container/CHANGELOG.md'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'smart_engine', '~> 0.5'

  spec.add_development_dependency 'bundler', '~> 2.2'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'armitage-rubocop', '~> 1.7'
  spec.add_development_dependency 'simplecov', '~> 0.21'
  spec.add_development_dependency 'pry', '~> 0.13'
end
