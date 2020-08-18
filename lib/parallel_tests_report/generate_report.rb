require 'parallel_tests_report'
require 'json'
require 'nokogiri'

class ParallelTestsReport::GenerateReport
  def start(time_limit = 10)
    all_examples = []
    slowest_examples = []
    failed_examples = []
    time_exceeding_examples = []
    rerun_failed = []

    return if File.zero?('./tmp/test-results/rspec.json')

    File.foreach('./tmp/test-results/rspec.json') do |line|
      parallel_suite = JSON.parse(line)
      all_examples += parallel_suite["examples"]
      slowest_examples += parallel_suite["profile"]["examples"]
      failed_examples += parallel_suite["examples"].select {|ex| ex["status"] == "failed" }
      time_exceeding_examples += parallel_suite["examples"].select {|ex| ex["run_time"] >= time_limit}
    end

    if slowest_examples.size > 0
      slowest_examples = slowest_examples.sort_by do |ex|
        -ex["run_time"]
      end.first(20)
    end

    if slowest_examples.size > 0
      puts "Top #{slowest_examples.size} slowest examples\n"
      slowest_examples.each do |ex|
        puts <<-TEXT
  #{ex["full_description"]}
      #{ex["run_time"]} #{"seconds"} #{ex["file_path"]} #{ex["line_number"]}
        TEXT
      end
    end

    if failed_examples.size > 0
      puts "\nFailed Examples:\n"
      failed_examples.each do |ex|
        puts <<-TEXT
  => #{ex["full_description"]}
      #{ex["run_time"]} #{"seconds"} #{ex["file_path"]} #{ex["line_number"]}
        #{ex["exception"]["message"]}
        TEXT
        all_examples.each do |e|
          rerun_failed << e["file_path"].to_s if e["parallel_test_proessor"] == ex["parallel_test_proessor"] && !rerun_failed.include?(e["file_path"])
        end
        str = ""
        rerun_failed.each do |e|
          str += e + " "
        end
        puts <<-TEXT
  \n\s\sIn case the failure: "#{ex["full_description"]}" is due to random ordering, run the following command to isolate the minimal set of examples that reproduce the same failures:
    `bundle exec rspec #{str} --seed #{ex['seed']} --bisect`\n
        TEXT
        rerun_failed.clear
      end
    end

    if time_exceeding_examples.length > 0
      puts "\nExecution time is exceeding the threshold of #{time_limit} seconds for following tests:"
      time_exceeding_examples.each do |ex|
        puts <<-TEXT
  => #{ex["full_description"]}: #{ex["run_time"]} #{"Seconds"}
        TEXT
      end
<<<<<<< HEAD
=======
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.root {
          xml.message_ "Execution time is exceeding the threshold of 300 seconds for following tests:"
          xml.examples {
            time_exceeding_examples.each do |ex|
              xml.example {
                xml.failure {
                  xml.full_description_   ex["full_description"]
                  xml.runtime_  "#{ex["run_time"]}" + "\sSeconds"
                }
              }
            end
          }
        }
      end
      File.open('tmp/test-results/rspec1.xml', 'w') do |file|
        file << builder.to_xml
      end
>>>>>>> correct typo
      raise
    else
      puts "Runtime check Passed."
    end

    if failed_examples.size > 0
      fail_message = "Tests Failed"
      puts "\e[31m#{fail_message}\e[0m"
      raise
    end
  end
end
