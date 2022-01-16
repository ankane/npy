require "bundler/gem_tasks"
require "rake/testtask"

task default: :test
Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

task :benchmark do
  require "benchmark/ips"
  require "numo/narray"
  require "npy"

  x = Numo::Int32[1..1_000_000]

  tempdir = File.dirname(Tempfile.new("npy"))

  File.binwrite("#{tempdir}/x.dump", Marshal.dump(x))
  Npy.save("#{tempdir}/x.npy", x)

  x1 = Marshal.load(File.binread("#{tempdir}/x.dump"))
  x2 = Npy.load("#{tempdir}/x.npy")

  raise "Mismatch: x1" unless x1 == x
  raise "Mismatch: x2" unless x2 == x

  Benchmark.ips do |bx|
    bx.report("numo") { Marshal.load(File.binread("#{tempdir}/x.dump")) }
    bx.report("npy") { Npy.load("#{tempdir}/x.npy") }
  end
end
