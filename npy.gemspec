require_relative "lib/npy/version"

Gem::Specification.new do |spec|
  spec.name          = "npy"
  spec.version       = Npy::VERSION
  spec.summary       = "Save and load NumPy npy and npz files in Ruby"
  spec.homepage      = "https://github.com/ankane/npy"
  spec.license       = "MIT"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@chartkick.com"

  spec.files         = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 2.4"

  spec.add_dependency "numo-narray"
  spec.add_dependency "rubyzip"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", ">= 5"
  spec.add_development_dependency "benchmark-ips"
end
