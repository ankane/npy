require_relative "test_helper"

class SaveTest < Minitest::Test
  def test_save_npy
    arr = Numo::Int64.cast([[1, 2, 3], [4, 5, 6]])
    Npy.save(tempfile, arr)
    assert_equal arr, Npy.load(tempfile)
    # Npy.save("test/support/generated.npy", arr)
  end

  def test_save_npy_array
    arr = Numo::Int64.cast([[1, 2, 3], [4, 5, 6]])
    Npy.save(tempfile, arr.to_a)
    assert_equal arr, Npy.load(tempfile)
    # Npy.save("test/support/generated_array.npy", arr)
  end

  # make sure no conflict with bool
  # need to check output in verify.py
  def test_save_npy_uint8
    arr = Numo::UInt8.cast([[1, 2, 3], [4, 5, 6]])
    Npy.save(tempfile, arr)
    assert_equal arr, Npy.load(tempfile)
    # Npy.save("test/support/generated_uint8.npy", arr)
  end

  def test_save_npy_rank0
    arr = 1
    Npy.save(tempfile, arr)
    assert_equal arr, Npy.load(tempfile)
    # Npy.save("test/support/generated_rank0.npy", arr)
  end

  def test_save_npy_bad_type
    arr = "hello"
    error = assert_raises Npy::Error do
      Npy.save(tempfile, arr)
    end
    assert_equal "Unsupported type: String", error.message
  end

  def test_save_npy_float64
    arr = Numo::DFloat.cast([[1, 2, 3], [4, 5, 6]])
    Npy.save(tempfile, arr)
    assert_equal arr, Npy.load(tempfile)
  end

  def test_save_npy_1d
    arr = Numo::Int64.cast([1, 2, 3, 4, 5, 6])
    Npy.save(tempfile, arr)
    assert_equal arr, Npy.load(tempfile)
    # Npy.save("test/support/generated_1d.npy", arr)
  end

  def test_save_npy_string
    io = StringIO.new
    arr = Numo::Int64.cast([[1, 2, 3], [4, 5, 6]])
    Npy.save(io, arr)
    assert_equal arr, Npy.load_string(io.string)
    io.rewind
    assert_equal arr, Npy.load(io)
  end

  def test_save_npz
    x = Numo::Int64.cast([[1, 2, 3], [4, 5, 6]])
    y = x * 2
    Npy.save_npz(tempfile, x: x, y: y)
    data = Npy.load_npz(tempfile)
    assert_equal ["x", "y"], data.keys
    assert_equal x, data["x"]
    assert_equal y, data["y"]
    # Npy.save_npz("test/support/generated.npz", x: x, y: y)
  end

  def test_save_npz_overwrites
    x = Numo::Int64.cast([[1, 2, 3], [4, 5, 6]])
    Npy.save_npz(tempfile, x: x)
    Npy.save_npz(tempfile, x2: x)
    data = Npy.load_npz(tempfile)
    assert_equal ["x2"], data.keys
  end
end
