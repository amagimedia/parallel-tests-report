require_relative '../../parallel_tests_report/generate_report.rb'

namespace :generate do
  task :report, [:time_limit] do |t,args|
    time_limit = args[:time_limit].to_f
    if time_limit == 0.0
      ParallelTestsReport::GenerateReport.new.start
    else
      ParallelTestsReport::GenerateReport.new.start time_limit
    end
  end
end
