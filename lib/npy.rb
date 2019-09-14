# dependencies
require "numo/narray"
require "zip"

# modules
require "npy/file"
require "npy/version"

module Npy
  class Error < StandardError; end

  MAGIC_STR = "\x93NUMPY".b

  TYPE_MAP = {
    "|i1" => Numo::Int8,
    "<i2" => Numo::Int16,
    "<i4" => Numo::Int32,
    "<i8" => Numo::Int64,
    "|u1" => Numo::UInt8,
    "<u2" => Numo::UInt16,
    "<u4" => Numo::UInt32,
    "<u8" => Numo::UInt64,
    "<f4" => Numo::SFloat,
    "<f8" => Numo::DFloat,
    "<c8" => Numo::SComplex,
    "<c16" => Numo::DComplex
  }

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

      klass = TYPE_MAP[descr]
      raise Error, "Type not supported: #{descr}" unless klass

      # use from_string instead of from_binary for max compatibility
      # from_binary introduced in 0.9.0.4
      result = klass.from_string(io.read, shape)
      result = result[0] if empty_shape
      result
    end

    def load_npz_io(io)
      File.new(io)
    end

    def save(path, arr)
      ::File.open(path, "wb") do |f|
        save_io(f, arr)
      end
      true
    end

    def save_npz(path, **arrs)
      Zip::File.open(path, Zip::File::CREATE) do |zipfile|
        arrs.each do |k, v|
          zipfile.get_output_stream("#{k}.npy") do |f|
            save_io(f, v)
          end
        end
      end
      true
    end

    private

    def save_io(f, arr)
      empty_shape = arr.is_a?(Numeric)
      arr = Numo::NArray.cast([arr]) if empty_shape
      arr = Numo::NArray.cast(arr) if arr.is_a?(Array)

      # desc
      descr = TYPE_MAP.find { |k, v| arr.is_a?(v) }
      raise Error, "Unsupported type: #{arr.class.name}" unless descr

      # shape
      shape = arr.shape
      shape << "" if shape.size == 1
      shape = [] if empty_shape

      # header
      header = "{'descr': '#{descr[0]}', 'fortran_order': False, 'shape': (#{shape.join(", ")}), }".b
      padding_len = 64 - (11 + header.length) % 64
      padding = "\x20".b * padding_len
      header = "#{header}#{padding}\n"

      f.write(MAGIC_STR)
      f.write("\x01\x00".b)
      f.write([header.bytesize].pack("S<"))
      f.write(header)
      f.write(arr.to_string)
    end

    def with_file(path)
      ::File.open(path, "rb") do |f|
        yield f
      end
    end

    # header is Python dict, so use regex to parse
    def parse_header(header)
      # sanity check
      raise Error, "Bad header" if !header || header[-1] != "\n"

      # descr
      m = /'descr': *'([^']+)'/.match(header)
      descr = m[1]

      # fortran_order
      m = /'fortran_order': *([^,]+)/.match(header)
      fortran_order = m[1] == "True"

      # shape
      m = /'shape': *\(([^)]*)\)/.match(header)
      # no space in split for max compatibility
      shape = m[1].split(",").map(&:to_i)

      [descr, fortran_order, shape]
    end
  end
end
