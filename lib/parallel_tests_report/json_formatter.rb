require 'parallel_tests_report'

class ParallelTestsReport::JsonFormatter < RSpec::Core::Formatters::BaseFormatter
  RSpec::Core::Formatters.register self, :message, :dump_profile, :seed, :stop, :close
  attr_reader :output_hash, :output
  def initialize(output)
    super
    @output ||= output
    if String === @output
      #open the file given as argument in --out
      FileUtils.mkdir_p(File.dirname(@output))
      # overwrite previous results
      File.open(@output, 'w'){}
      @output = File.open(@output, 'a')
      # close and restart in append mode
    elsif File === @output
      @output.close
      @output = File.open(@output.path, 'a')
    end
    @output_hash = {}

    if ENV['TEST_ENV_NUMBER'].to_i != 0
      @n = ENV['TEST_ENV_NUMBER'].to_i
    else
      @n = 1
    end
  end

  def message(notification)
    (@output_hash[:messages] ||= []) << notification.message
  end

  def seed(notification)
    return unless notification.seed_used?
    @output_hash[:seed] = notification.seed
  end

  def close(_notification)
    #close the file after all the processes are finished
    @output.close if (IO === @output) & (@output != $stdout)
  end

  def stop(notification)
    #adds to @output_hash, an array of examples which run in a particular processor
    @output_hash[:examples] = notification.examples.map do |example|
      format_example(example).tap do |hash|
        e = example.exception
        if e
          hash[:exception] =  {
            :class => e.class.name,
            :message => e.message,
            :backtrace => e.backtrace,
          }
        end
      end
    end
  end

  def dump_profile(profile)
    dump_profile_slowest_examples(profile)
  end

  def dump_profile_slowest_examples(profile)
    #adds to @output_hash, an array of 20 slowest examples
    lock_output do
      @output_hash[:profile] = {}
      @output_hash[:profile][:examples] = profile.slowest_examples.map do |example|
        format_example(example)
      end
    end
    #write the @output_hash to the file
    output.puts @output_hash.to_json
    output.flush
  end

protected
  #to make a single file for all the parallel processes
  def lock_output
    if File === @output
      begin
        @output.flock File::LOCK_EX
        yield
      ensure
        @output.flock File::LOCK_UN
      end
    else
      yield
    end
  end

private

  def format_example(example)
    {
      :full_description => example.full_description,
      :status => example.execution_result.status.to_s,
      :file_path => example.metadata[:file_path],
      :line_number  => example.metadata[:line_number],
      :run_time => example.execution_result.run_time,
      :parallel_test_proessor => @n,
      :seed => @output_hash[:seed]
    }
  end
end
