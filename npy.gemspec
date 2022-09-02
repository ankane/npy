require_relative "lib/npy/version"

Gem::Specification.new do |spec|
  spec.name          = "npy"
  spec.version       = Npy::VERSION
  spec.summary       = "Save and load NumPy npy and npz files in Ruby"
  spec.homepage      = "https://github.com/ankane/npy"
  spec.license       = "MIT"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@ankane.org"

  spec.files         = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 2.7"

  spec.add_dependency "numo-narray"
  spec.add_dependency "rubyzip", ">= 2.3"
end
