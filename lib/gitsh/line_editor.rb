require 'gitsh/line_editor_native'

module Gitsh
  module LineEditor
    def self.delete_text(*args)
      return if line_buffer.nil?

      if args.length.zero?
        beg = 0
        len = line_buffer.length
      elsif args.length == 1 && args[0].is_a?(Range)
        beg = args[0].begin
        len = line_buffer[args[0]].length
      elsif args.length == 1
        beg = args[0]
        len = line_buffer.length - beg
      elsif args.length == 2
        beg = args[0]
        len = args[1]
      else
        raise ArgumentError,
          "wrong number of arguments (given #{args.length}, expected 0..2)"
      end

      byte_beg = line_buffer[0...beg].bytesize
      byte_len = line_buffer[beg, len].bytesize

      self.delete_bytes(byte_beg, byte_len)
    end
  end
end
