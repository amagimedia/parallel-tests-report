require 'parallel_tests_report'
require 'json'
require 'nokogiri'

class ParallelTestsReport::GenerateReport
  def start(time_limit, output)
    all_examples = []
    slowest_examples = []
    failed_examples = []
    time_exceeding_examples = []
    rerun_failed = []
    errors = []

    return if File.zero?(output)

    File.foreach(output) do |line|
      parallel_suite = JSON.parse(line)
      all_examples += parallel_suite["examples"]
      slowest_examples += parallel_suite["profile"]["examples"]
      failed_examples += parallel_suite["examples"].select {|ex| ex["status"] == "failed" }
      time_exceeding_examples += parallel_suite["examples"].select {|ex| ex["run_time"] >= time_limit}
      errors << parallel_suite["messages"][0] if parallel_suite["examples"].size == 0
    end

    if slowest_examples.size > 0
      slowest_examples = slowest_examples.sort_by do |ex|
        -ex["run_time"]
      end.first(20)
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

    if errors.size > 0
      puts "\Errors:\n"
      errors.each do |err|
        puts <<-TEXT
        #{err}
        TEXT
      end
    end

    if time_exceeding_examples.size > 0 || errors.size > 0
      generate_xml(errors, time_exceeding_examples, time_limit)
    end

    if time_exceeding_examples.size > 0
      puts "\nExecution time is exceeding the threshold of #{@time_limit} seconds for following tests:"
      time_exceeding_examples.each do |ex|
        puts <<-TEXT
  => #{ex["full_description"]}: #{ex["run_time"]} #{"Seconds"}
        TEXT
      end
    else
      puts "Runtime check Passed."
    end

    if failed_examples.size > 0 || errors.size > 0 || time_exceeding_examples.size > 0
      fail_message = "Tests Failed"
      puts "\e[31m#{fail_message}\e[0m"
      exit 1
    end
  end

  def generate_xml(errors, time_exceeding_examples, time_limit)
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.testsuite {
        time_exceeding_examples.each do |arr|
          classname = "#{arr["file_path"]}".sub(%r{\.[^/]*\Z}, "").gsub("/", ".").gsub(%r{\A\.+|\.+\Z}, "")
          xml.testcase("classname" => "#{classname}", "name" => "#{arr["full_description"]}", "file" => "#{arr["file_path"]}", "time" => "#{arr["run_time"]}") {
            xml.failure "Execution time is exceeding the threshold of #{time_limit} seconds"
          }
        end
        errors.each do |arr|
          file_path = arr[/(?<=An error occurred while loading ).*/]
          classname = "#{file_path}".sub(%r{\.[^/]*\Z}, "").gsub("/", ".").gsub(%r{\A\.+|\.+\Z}, "")
          xml.testcase("classname" => "#{classname}", "name" => "An error occurred while loading", "file" => "#{file_path}", "time" => "0.0") {
            xml.failure arr.gsub(/\e\[([;\d]+)?m/, "")
          }
        end
      }
    end
    File.open('tmp/test-results/time_limit_exceeded.xml', 'w') do |file|
      file << builder.to_xml
    end
  end
end
