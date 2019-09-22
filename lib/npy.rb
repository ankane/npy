# dependencies
require "numo/narray"
require "zip"

# stdlib
require "stringio"
require "tempfile"

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
      case path
      when IO, StringIO
        load_io(path)
      else
        load_file(path)
      end
    end

    def load_npz(path)
      case path
      when IO, StringIO
        load_npz_io(path)
      else
        load_npz_file(path)
      end
    end

    def load_string(byte_str)
      load_io(StringIO.new(byte_str))
    end

    def load_npz_string(byte_str)
      # not playing nicely with StringIO
      file = Tempfile.new("npy")
      begin
        file.write(byte_str)
        load_npz_io(file)
      ensure
        file.close
        file.unlink
      end
    end

    # TODO make private
    def load_io(io)
      magic = io.read(6)
      raise Error, "Invalid npy format" unless magic&.b == MAGIC_STR

      version = io.read(2)

      header_len =
        case version
        when "\x01\x00".b
          io.read(2).unpack1("S<")
        when "\x02\x00".b, "\x03\x00".b
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

    # TODO make private
    def load_npz_io(io)
      File.new(io)
    end

    def save(path, arr)
      case path
      when IO, StringIO
        save_io(path, arr)
      else
        save_file(path, arr)
      end
      true
    end

    def save_npz(path, arrs)
      case path
      when IO, StringIO
        save_npz_io(path, arrs)
      else
        save_npz_file(path, arrs)
      end
      true
    end

    private

    def load_file(path)
      with_file(path, "rb") do |f|
        load_io(f)
      end
    end

    def load_npz_file(path)
      with_file(path, "rb") do |f|
        load_npz_io(f)
      end
    end

    def save_file(path, arr)
      with_file(path, "wb") do |f|
        save_io(f, arr)
      end
    end

    def save_io(f, arr)
      unless arr.is_a?(Numo::NArray)
        begin
          arr = Numo::NArray.cast(arr)
        rescue TypeError
          # do nothing
        end
      end

      # desc
      descr = TYPE_MAP.find { |_, v| arr.is_a?(v) }
      raise Error, "Unsupported type: #{arr.class.name}" unless descr

      # shape
      shape = arr.shape

      # header
      header = "{'descr': '#{descr[0]}', 'fortran_order': False, 'shape': (#{shape.join(", ")}#{shape.size == 1 ? "," : nil}), }".b
      padding_len = 64 - (11 + header.length) % 64
      padding = "\x20".b * padding_len
      header = "#{header}#{padding}\n"

      f.write(MAGIC_STR)
      f.write("\x01\x00".b)
      f.write([header.bytesize].pack("S<"))
      f.write(header)
      f.write(arr.to_string)
    end

    def save_npz_file(path, arrs)
      with_file(path, "wb") do |f|
        save_npz_io(f, arrs)
      end
    end

    def save_npz_io(f, arrs)
      Zip::File.open(f, Zip::File::CREATE) do |zipfile|
        arrs.each do |k, v|
          zipfile.get_output_stream("#{k}.npy") do |f2|
            save_io(f2, v)
          end
        end
      end
    end

    def with_file(path, mode)
      ::File.open(path, mode) do |f|
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
      shape = m[1].strip.split(",").map(&:to_i)

      [descr, fortran_order, shape]
    end
  end
end
