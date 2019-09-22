require_relative "test_helper"

class NpyTest < Minitest::Test
  def test_load_npy_file
    act = Npy.load("test/support/single.npy")
    assert_equal Numo::UInt64[0...10], act
  end

  def test_load_npz_file
    data = Npy.load_npz("test/support/multiple.npz")
    assert_equal ["x", "y"], data.keys
    assert_equal Numo::UInt64[0...10], data["x"]
    assert_equal Numo::UInt64[0...10] * 2, data["y"]
    assert_equal ["x", "y"], data.to_h.keys
    assert_nil data["z"]
  end

  def test_load_npy_string
    byte_str = File.binread("test/support/single.npy")
    act = Npy.load_string(byte_str)
    assert_equal Numo::UInt64[0...10], act
  end

  def test_empty_shape
    act = Npy.load("test/support/empty_shape.npy")
    assert_equal 1, act
  end

  def test_load_npz_string
    byte_str = File.binread("test/support/multiple.npz")
    data = Npy.load_npz_string(byte_str)
    assert_equal ["x", "y"], data.keys
    assert_equal Numo::UInt64[0...10], data["x"]
    assert_equal Numo::UInt64[0...10] * 2, data["y"]
    assert_equal ["x", "y"], data.to_h.keys
    assert_nil data["z"]
  end

  def test_invalid_format
    error = assert_raises Npy::Error do
      Npy.load_string("hi")
    end
    assert_equal "Invalid npy format", error.message
  end

  def test_type_int8
    act = Npy.load("test/support/types/int8.npy")
    assert_equal Numo::Int8[0...10], act
  end

  def test_type_int16
    act = Npy.load("test/support/types/int16.npy")
    assert_equal Numo::Int16[0...10], act
  end

  def test_type_int32
    act = Npy.load("test/support/types/int32.npy")
    assert_equal Numo::Int32[0...10], act
  end

  def test_type_int64
    act = Npy.load("test/support/types/int64.npy")
    assert_equal Numo::Int64[0...10], act
  end

  def test_type_uint8
    act = Npy.load("test/support/types/uint8.npy")
    assert_equal Numo::UInt8[0...10], act
  end

  def test_type_uint16
    act = Npy.load("test/support/types/uint16.npy")
    assert_equal Numo::UInt16[0...10], act
  end

  def test_type_uint32
    act = Npy.load("test/support/types/uint32.npy")
    assert_equal Numo::UInt32[0...10], act
  end

  def test_type_uint64
    act = Npy.load("test/support/types/uint64.npy")
    assert_equal Numo::UInt64[0...10], act
  end

  def test_type_float16
    error = assert_raises Npy::Error do
      Npy.load("test/support/types/float16.npy")
    end
    assert_includes error.message, "Type not supported"
  end

  def test_type_float32
    act = Npy.load("test/support/types/float32.npy")
    assert_equal Numo::SFloat[0...10], act
  end

  def test_type_float64
    act = Npy.load("test/support/types/float64.npy")
    assert_equal Numo::DFloat[0...10], act
  end

  def test_type_complex64
    act = Npy.load("test/support/types/complex64.npy")
    assert_equal Numo::SComplex[0...10], act
  end

  def test_type_complex128
    act = Npy.load("test/support/types/complex128.npy")
    assert_equal Numo::DComplex[0...10], act
  end

  def test_type_bool
    act = Npy.load("test/support/types/bool.npy")
    assert_equal Numo::UInt8.cast([0] + ([1] * 9)), act
  end

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

  def test_save_npy_empty_shape
    arr = 1
    Npy.save(tempfile, arr)
    assert_equal arr, Npy.load(tempfile)
    # Npy.save("test/support/generated_empty.npy", arr)
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
