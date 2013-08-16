module RubyAtdd
  class SourceCodeMatcherExtractor
    def initialize(params)
      @file_name = params.fetch(:file)
      @method_line = params.fetch(:line).to_i
      @match = /# english: ?(.*)/i
    end

    def extract
      list = []
      cur_line = @method_line
      while (mm = match_line?(cur_line - 1))
        regex = Regexp.new(mm)
        list << regex
        cur_line -= 1
      end
      list
    end

    private

    def match_line?(line)
      mm = @match.match(src_line(line))
      mm.nil? ? false : mm[1]
    end

    def src_line(line)
      src_array[line-1]
    end

    def src
      @src ||= File.read(@file_name)
    end

    def src_array
      @src_array ||= src.lines.to_a
    end

  end
end

