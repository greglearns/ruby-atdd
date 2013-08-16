require_relative 'source_code_matcher_extractor'
require 'ostruct'
require 'dotenv'

module RubyAtdd

  class Base

    def self.scenarios(attrs)
      load_dot_env
      called_by = called_by(caller)

      puts '', '-'*30, "TEST RUN STARTED", File.basename(called_by.file), "#{called_by.file}", "URL_BASE=#{ENV['BASE_URL']}", Time.now.to_s, '-'*30, ''

      failing_tests_count = handle_multiple_scenarios(get_scenarios_str(attrs))
      exit(failing_tests_count)
    end

    def self.handle_multiple_scenarios(str)
      failures = ScenariosParser.new(str).map do |scenario_str|
        subject = new({uri_base: ENV['BASE_URL']})
        subject.scenario(scenario_str)
        .tap{|r| puts } # blank line between scenario results
      end

      failures.reduce(:+)
      .tap{|cnt| puts "#{failures.size} scenarios. #{cnt} tests failed." }
    end

    def self.load_dot_env
      Dotenv.load ".env.#{ENV['ENV']}", '.env'
    end

    def self.get_scenarios_str(attrs)
      file_name = attrs.fetch(:file_name, nil)
      if file_name
        str = File.read(file_name)
        str = str.split("__END__")[1]
      else
        str = attrs.fetch(:str)
      end
      str
    end

    def scenario(str)
      response_code = 0
      begin
        ScenarioParser.new(str).each_line do |line, multiline_text|
          execute_line(line.to_s, multiline_text)
        end
      rescue Exception => e # must rescue Exception because Minitest::Assertion subclasses Exception
        puts "FAIL: #{e.message}"
        puts e.backtrace unless e.class.to_s == 'Minitest::Assertion'
        response_code = 1
      end
      puts
      response_code
    end

    def self.method_added(name)
      extractor = SourceCodeMatcherExtractor.new(called_by(caller).to_h)
      matcher_lines = extractor.extract
      @matchers ||= []
      @matchers << [name, matcher_lines] unless matcher_lines.empty?
      super
    end

    def self.called_by(history)
      last = history.first.split(':')
      OpenStruct.new({file: last[0], line: last[1].to_i})
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

  class ScenariosParser
    def initialize(str)
      @scenarios = breakup_scenarios(str)
    end

    def map
      @scenarios.map{|scenario_str| yield scenario_str }
    end

    private

    def breakup_scenarios(str)
      str.split("\n\n").compact.map{|e| e.strip.empty? ? nil : e }.compact
    end

  end

  class ScenarioParser
    def initialize(str)
      @str = str
    end

    def each_line(&block)
      ii = @str.each_line
      loop do
        line = CleanLine.new(ii.next).strip
        next if line.skip?
        print line
        line.skip_first_word!
        multiline_text = extract_multiline_text(ii)
        yield line.to_s, multiline_text
      end
    end

    private

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

