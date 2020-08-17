require_relative '../../parallel_tests_report/generate_report.rb'

namespace :generate do
  task :report do
<<<<<<< HEAD
    ParallelTestsReport::GenerateReport.new.start
=======
    ParallelTestsReport::GenerateReport.start
>>>>>>> add gemfile and rake task
  end
end
