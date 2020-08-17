require_relative '../../lib/parallel_tests_report.rb'

namespace :generate do
  task :report do
    ParallelTestsReport.start
  end
end
