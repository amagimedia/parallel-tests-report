require_relative '../../parallel_tests_report/generate_report.rb'

namespace :generate do
  task :report do
    ParallelTestsReport::GenerateReport.start
  end
end
