# parallel-tests-report

Works with [parallel_tests](https://github.com/grosser/parallel_tests) gem to generate a consolidated report for the spec groups executed by paralle_tests.

The report generated will include:
- List of top 20 slowest examples.
- Rspec command to reproduce the failed example with the bisect option and seed value used.

This gem will also verify the time taken for a test against configured threshold value and report if the time has exceeded.

atestcase has exceeded the configured time limit

## How it works
- parallel_tests gem is configured to use a custom formatter provided by this gem using `--format` and `--out` options.
- Once tests are executed a rake task provided by this gem can be executed to parse the json and generate the report.

## Installation
Include the gem in your Gemfile

`gem 'parallel_tests_report'`

`$ bundle install`

Add the following to the Rakefile before load_task(In Rails application):

`require 'parallel_tests_report'`

## Usage
- add `--format` and `--out` option to `.rspec` or `.rspec_parallel`
  - `--format ParallelTestsReport::JsonFormatter --out tmp/test-results/rspec.json`
- execute the rake task after specs are executed 
  - `bundle exec parallel_tests_report rake generate:report <TIME_LIMIT_IN_SECONDS> tmp/test-results/rspec.json`
  - <TIME_LIMIT_IN_SECONDS> is the maximum time an example can take. Default is 10 seconds.
  - <OUTPUT_FILE> is the file specified in the --out option. Default is 'tmp/test-results/rspec.json'

#### This rake task can be configured to run after specs are executed in a continuous integration setup, it also produces a junit xml file for time limit exceeding check.
