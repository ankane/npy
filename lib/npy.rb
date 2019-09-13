# dependencies
require "numo/narray"
require "zip"

# modules
require "npy/file"
require "npy/version"

module Npy
  class Error < StandardError; end

  MAGIC_STR = "\x93NUMPY".b

  class << self
    def load(path)
      with_file(path) do |f|
        load_io(f)
      end
    end

    def load_npz(path)
      with_file(path) do |f|
        load_npz_io(f)
      end
    end

    def load_string(byte_str)
      load_io(StringIO.new(byte_str))
    end

    # rubyzip not playing nicely with StringIO
    # def load_npz_string(byte_str)
    #   load_npz_io(StringIO.new(byte_str))
    # end

    def load_io(io)
      magic = io.read(6)
      raise Error, "Invalid npy format" unless magic&.b == MAGIC_STR

      major_version = io.read(1)
      _minor_version = io.read(1)

      header_len =
        case major_version
        when "\x01".b
          io.read(2).unpack1("S<")
        when "\x02".b, "\x03".b
          io.read(4).unpack1("I<")
        else
          raise Error, "Unsupported version"
        end
      header = io.read(header_len)
      descr, fortran_order, shape = parse_header(header)
      raise Error, "Fortran order not supported" if fortran_order

      # numo can't handle empty shapes
      empty_shape = shape.empty?
      shape = [1] if empty_shape

      klass =
        case descr
        when "|i1"
          Numo::Int8
        when "<i2"
          Numo::Int16
        when "<i4"
          Numo::Int32
        when "<i8"
          Numo::Int64
        when "|u1"
          Numo::UInt8
        when "<u2"
          Numo::UInt16
        when "<u4"
          Numo::UInt32
        when "<u8"
          Numo::UInt64
        when "<f4"
          Numo::SFloat
        when "<f8"
          Numo::DFloat
        when "<c8"
          Numo::SComplex
        when "<c16"
          Numo::DComplex
        else
          raise Error, "Type not supported: #{descr}"
        end

      result = klass.from_binary(io.read, shape)
      result = result[0] if empty_shape
      result
    end

    def load_npz_io(io)
      File.new(io)
    end

    private

    def with_file(path)
      ::File.open(path, "rb") do |f|
        yield f
      end
    end

    # header is Python dict, so use regex to parse
    def parse_header(header)
      # sanity check
      raise "Bad header" unless header[-1] == "\n"

      # descr
      m = /'descr': *'([^']+)'/.match(header)
      descr = m[1]

      # fortran_order
      m = /'fortran_order': *([^,]+)/.match(header)
      fortran_order = m[1] == "True"

      # shape
      m = /'shape': *\(([^)]*)\)/.match(header)
      shape = m[1].split(", ").map(&:to_i)

      [descr, fortran_order, shape]
    end
  end
end
