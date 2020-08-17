require 'parallel_tests_report'
require 'rails'

module ParallelTestsReport
  class Railtie < Rails::Railtie
    railtie_name :parallel_tests_report

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end
  end
end
