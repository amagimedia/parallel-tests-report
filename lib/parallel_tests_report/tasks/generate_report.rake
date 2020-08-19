require_relative '../../parallel_tests_report/generate_report.rb'

namespace :generate do
  task :report, [:time_limit, :output] do |t,args|
    output = args[:output].to_s
    if output == ""
      if(args[:time_limit] != nil && args[:time_limit].to_f == 0.0 && args[:time_limit] != '0.0')
        output = args[:time_limit].to_s
      else
        output = 'tmp/test-results/rspec.json'
      end
    end
    time_limit = args[:time_limit].to_f
    if time_limit == 0.0
      if args[:time_limit] == "0.0"
        time_limit = 0.0
      else
        time_limit = 10.0
      end
    end
    ParallelTestsReport::GenerateReport.new.start time_limit,output
  end
end
