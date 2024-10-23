require_relative "test_helper"

class LoadTest < Minitest::Test
  def test_load_npy_file
    act = Npy.load("test/support/single.npy")
    assert_array Numo::Int64[0...10], act
  end

  def test_load_npz_file
    data = Npy.load_npz("test/support/multiple.npz")
    assert_equal ["x", "y"], data.keys
    assert_array Numo::Int64[0...10], data["x"]
    assert_array Numo::Int64[0...10] * 2, data["y"]
    assert_equal ["x", "y"], data.to_h.keys
    assert_nil data["z"]
  end

  def test_load_npy_string
    byte_str = File.binread("test/support/single.npy")
    act = Npy.load_string(byte_str)
    assert_array Numo::Int64[0...10], act
  end

  def test_rank0
    act = Npy.load("test/support/rank0.npy")
    assert_equal 0, act.rank
    assert_array Numo::Int64.cast(1), act
  end

  # this test fails when recreating multiple.npz
  # rubyzip 3.0.0.alpha fixes it
  def test_load_npz_string
    byte_str = File.binread("test/support/multiple.npz")
    data = Npy.load_npz_string(byte_str)
    assert_equal ["x", "y"], data.keys
    assert_array Numo::Int64[0...10], data["x"]
    assert_array Numo::Int64[0...10] * 2, data["y"]
    assert_equal ["x", "y"], data.to_h.keys
    assert_nil data["z"]
  end

  def test_invalid_format
    error = assert_raises Npy::Error do
      Npy.load_string("hi")
    end
    assert_equal "Invalid npy format", error.message
  end
end
