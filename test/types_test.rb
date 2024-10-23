require_relative "test_helper"

class TypesTest < Minitest::Test
  def test_int8
    act = Npy.load("test/support/types/int8.npy")
    assert_array Numo::Int8[0...10], act
  end

  def test_int16
    act = Npy.load("test/support/types/int16.npy")
    assert_array Numo::Int16[0...10], act
  end

  def test_int32
    act = Npy.load("test/support/types/int32.npy")
    assert_array Numo::Int32[0...10], act
  end

  def test_int64
    act = Npy.load("test/support/types/int64.npy")
    assert_array Numo::Int64[0...10], act
  end

  def test_uint8
    act = Npy.load("test/support/types/uint8.npy")
    assert_array Numo::UInt8[0...10], act
  end

  def test_uint16
    act = Npy.load("test/support/types/uint16.npy")
    assert_array Numo::UInt16[0...10], act
  end

  def test_uint32
    act = Npy.load("test/support/types/uint32.npy")
    assert_array Numo::UInt32[0...10], act
  end

  def test_uint64
    act = Npy.load("test/support/types/uint64.npy")
    assert_array Numo::UInt64[0...10], act
  end

  def test_float16
    error = assert_raises Npy::Error do
      Npy.load("test/support/types/float16.npy")
    end
    assert_includes error.message, "Type not supported"
  end

  def test_float32
    act = Npy.load("test/support/types/float32.npy")
    assert_array Numo::SFloat[0...10], act
  end

  def test_float64
    act = Npy.load("test/support/types/float64.npy")
    assert_array Numo::DFloat[0...10], act
  end

  def test_complex64
    act = Npy.load("test/support/types/complex64.npy")
    assert_array Numo::SComplex[0...10], act
  end

  def test_complex128
    act = Npy.load("test/support/types/complex128.npy")
    assert_array Numo::DComplex[0...10], act
  end

  def test_bool
    act = Npy.load("test/support/types/bool.npy")
    assert_array Numo::UInt8.cast([0] + ([1] * 9)), act
  end
end
