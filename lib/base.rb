require_relative 'source_code_matcher_extractor'

module RubyAtdd

  class Base

    def self.scenarios(attrs)
      file_name = attrs.fetch(:file_name, nil)
      called_by = caller.first.split(':')[0]
      require 'dotenv'
      Dotenv.load ".env.#{ENV['ENV']}", '.env'
      subject = Atdd::CreateServer.new({uri_base: ENV['BASE_URL']})

      puts '', '-'*30, "TEST RUN STARTED", File.basename(called_by), "#{called_by}", "URL_BASE=#{ENV['BASE_URL']}", Time.now.to_s, '-'*30, ''

      if file_name
        str = File.read(file_name)
        str = str.split("__END__")[1]
      else
        str = attrs.fetch(:str)
      end

      scenarios = str.split("\n\n").compact.map{|e| e.strip.empty? ? nil : e }.compact

      results = scenarios.map do |scenario_str|
        subject.scenario(scenario_str)
        .tap{|r| puts } # blank line between scenario results
      end

      failing_tests_count = results.reduce(:+)
      puts "#{failing_tests_count} tests failed."
      exit(failing_tests_count)
    end

    def scenario(str)
      response_code = 0
      begin
        ii = str.each_line
        loop do
          line = CleanLine.new(ii.next).strip
          next if line.skip?
          print line
          line.skip_first_word!
          multiline_text = extract_multiline_text(ii)
          execute_line(line.to_s, multiline_text)
        end
      # rescue MiniTest::Assertion => e
      #   puts "FAIL: #{e.message} #{'-'*30}"
      #   response_code = 1
      rescue Exception => e # must rescue Exception because Minitest::Assertion subclasses Exception
        puts "FAIL: #{e.message}"
        puts e.backtrace unless e.class.to_s == 'Minitest::Assertion'
        response_code = 1
      end
      puts
      response_code
    end

    def extract_multiline_text(ii)
      return unless CleanLine.new(ii.peek).is_fence?
      indent = CleanLine.new(ii.next).compute_indent_size
      lines = []
      loop do
        line = CleanLine.new(ii.next)
        break if line.is_fence?
        line.remove_indent!(indent)
        lines << line.to_s
      end
      str = lines.join
      str.empty? ? nil : str
    end

    def self.method_added(name)
      hst = caller
      file_name = hst.first.split(':')[0]
      file_line = hst.first.split(':')[1].to_i
      extractor = SourceCodeMatcherExtractor.new(file_name: file_name, line: file_line)
      matcher_lines = extractor.extract
      @matchers ||= []
      @matchers << [name, matcher_lines] unless matcher_lines.empty?
      super
    end

    def self.matchers
      @matchers
    end

    private

    def execute_line(line, multiline_text)
      method, matcher = self.class.find_matcher(line)
      if method && matcher
        puts
        args = matcher.match(line).captures
        args << multiline_text if multiline_text
        self.send(method, *args)
      else
        puts " (no match)"
      end
      puts multiline_text if multiline_text
    end

    def self.find_matcher(line)
      match = nil
      matchers.each do |list|
        actual_match = list[1].find do |matcher|
          matcher.match(line)
        end
        (match = [list[0], actual_match]; break) if actual_match
      end
      match
    end

  end

  class CleanLine
    def initialize(line)
      @line = String(line)
    end

    def strip
      @line.strip
      self
    end

    def skip?
      @line.empty? || @line =~ /\A\w*#/ # skip comments
    end

    def skip_first_word!
      @line = @line.split(' ',2)[1].strip
      self
    end

    def is_fence?
      @line =~ /"""/
    end

    def compute_indent_size
      @line.match(/\A\s*/)[0].size rescue 0
    end

    def remove_indent!(indent)
      @line.sub!(/\A {0,#{indent}}/,'')
        self
    end

    def to_s
      @line
    end
  end

end

