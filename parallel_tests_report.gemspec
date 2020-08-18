Gem::Specification.new do |s|
  s.name        = 'parallel_tests_report'
  s.version     = '0.0.0'
  s.date        = '2020-08-17'
  s.summary     = "Generate report for parallel_tests"
  s.description = "Works with parallel_tests ruby gem to generate a report having a list of slowest and failed examples."
  s.authors     = ["Akshat Birani"]
  s.email       = 'akshat@amagi.com'
  s.homepage    = 'https://github.com/amagimedia/parallel-tests-report'
  s.files       = Dir["lib/**/*", "README.md", "Rakefile"]
  s.add_dependency 'rake', '~> 12.3.3'
end
