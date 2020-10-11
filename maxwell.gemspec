require_relative 'lib/maxwell/version'

Gem::Specification.new do |spec|
  spec.name          = "maxwell"
  spec.version       = Maxwell::VERSION
  spec.authors       = ["aisaac"]
  spec.email         = ["no@aisaac.jp"]

  spec.summary       = %q{simple}
  spec.description   = %q{simple}
  spec.homepage      = "https://aisaac.jp"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency 'httpclient', '2.8.3'
  spec.add_dependency 'woothee'
end
