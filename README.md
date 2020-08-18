# parallel-tests-report
Works with parallel_tests ruby gem to generate a report having a list of slowest and failed examples.

# Installation
Include the gem in your Gemfile and bundle install:
 - gem 'parallel_tests_report', :git => git@github.com:amagimedia/parallel-tests-report.git

Add the following to the Rakefile before load_task(In Rails application):
 - require 'parallel_tests_report'

# Usage
## In Rails application
To use formatter, include the following in .rspec or .rspec_parallel:
 - --format ParallelTestsReport::Formatter --out tmp/test-results/rspec.json

To generate report, run the following rake task:
 - bundle exec rake generate:report

## In Non-Rails application
To generate report, run the following:
 - bundle exec parallel_tests_report rake generate:report
