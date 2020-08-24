require_relative '../../parallel_tests_report/generate_report.rb'

namespace :generate do
  task :report, [:time_limit, :output] do |t,args|
    output = args[:output].to_s
    if output == ""
      if(args[:time_limit] != nil && args[:time_limit].to_f == 0.0 && args[:time_limit] != '0.0') # If only one argument is given while calling the rake_task and that is :output.
        #Since, first argument is :time_limit, assigning that to output.
        output = args[:time_limit].to_s
      else
        output = 'tmp/test-results/rspec.json' # default :output file
      end
    end
    time_limit = args[:time_limit].to_f
    if time_limit == 0.0
      if args[:time_limit] == "0.0" #if :time_limit itself is 0.0
        time_limit = 0.0
      else
        time_limit = 10.0 # default :time_limit
      end
    end
    ParallelTestsReport::GenerateReport.new.start time_limit,output
  end
end
