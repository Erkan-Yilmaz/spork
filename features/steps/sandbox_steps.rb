Given /^I am in the directory "(.*)"$/ do |sandbox_dir_relative_path|
  path = File.join(SporkWorld::SANDBOX_DIR, sandbox_dir_relative_path)
  FileUtils.mkdir_p(path)
  @current_dir = File.join(path)
end

Given /^a file named "([^\"]*)"$/ do |file_name|
  create_file(file_name, '')
end

Given /^a file named "([^\"]*)" with:$/ do |file_name, file_content|
  create_file(file_name, file_content)
end

When /^I run (spork|spec)($| .*$)/ do |command, spork_opts|
  if command == 'spork'
    command = SporkWorld::BINARY
  else
    command = %x{which #{command}}.chomp
  end
  run "#{SporkWorld::RUBY_BINARY} #{command} #{spork_opts}"
end

When /^I fire up a spork instance with "spork(.*)"$/ do |spork_opts|
  run_in_background "#{SporkWorld::RUBY_BINARY} #{SporkWorld::BINARY} #{spork_opts}"
  output = ""
  begin
    status = Timeout::timeout(15) do
      # Something that should be interrupted if it takes too much time...
      while line = @bg_stderr.gets
        output << line
        puts line
        break if line.include?("Spork is ready and listening")
      end
    end
  rescue Timeout::Error
    puts "I can't seem to launch Spork properly.  Output was:\n#{output}"
    true.should == false
  end
end

Then /^the output should contain$/ do |text|
  last_stdout.should include(text)
end

Then /^the output should contain "(.+)"$/ do |text|
  last_stdout.should include(text)
end

Then /^the output should not contain$/ do |text|
  last_stdout.should_not include(text)
end

Then /^the output should not contain "(.+)"$/ do |text|
  last_stdout.should_not include(text)
end

Then /^the output should be$/ do |text|
  last_stdout.should == text
end
