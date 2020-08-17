require "rspec/core"
require "rspec/core/formatters/base_formatter"

module ParallelTestsReport
  require 'parallel_tests_report/railtie' if defined?(Rails)
end
