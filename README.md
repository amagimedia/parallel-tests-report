# parallel-tests-report
Works with parallel_tests ruby gem to generate a report having a list of slowest and failed examples.

# Installation
Include the gem in your Gemfile and bundle install:
 - `gem 'parallel_tests_report', :git => 'git@github.com:amagimedia/parallel-tests-report.git'`

Add the following to the Rakefile before load_task(In Rails application):
 - `require 'parallel_tests_report'`

# Usage
## To use formatter, include the following in .rspec or .rspec_parallel:
 - `--format ParallelTestsReport::JsonFormatter --out tmp/test-results/rspec.json`
#### Note: The path to file provided in --out option will also be used while report generation

## To generate report, run the following:
 - `bundle exec parallel_tests_report rake generate:report <TIME_LIMIT> <OUTPUT_FILE>`
#### <TIME_LIMIT> is maximum time an example can take. Default is 10 seconds.
#### <OUTPUT_FILE> is the same file set in .rspec or .rspec_parallel, in the --out option for the formatter. Default is 'tmp/test-results/rspec.json'
