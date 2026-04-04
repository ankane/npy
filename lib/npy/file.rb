module Npy
  class File
    def initialize(io)
      @streams = {}
      Zip::File.open_buffer(io) do |zipfile|
        zipfile.each do |entry|
          name = entry.name.delete_suffix(".npy")
          @streams[name] = entry
        end
      end
      @data = {}
    end

    def keys
      @streams.keys
    end

    def [](name)
      @data[name] ||= Npy.load_io(@streams[name].get_input_stream) if @streams[name]
    end

    def to_h
      keys.map { |k| [k, self[k]] }.to_h
    end
  end
end
