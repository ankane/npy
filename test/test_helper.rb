require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"

class Minitest::Test
  private

  def assert_array(exp, act)
    assert_equal exp, act
    assert_equal exp.class, act.class
  end

  def teardown
    @tempfile = nil
  end

  def tempfile
    @tempfile ||= "#{tempdir}/#{Time.now.to_f}"
  end

  def tempdir
    @tempdir ||= File.dirname(Tempfile.new("npy"))
  end
end
