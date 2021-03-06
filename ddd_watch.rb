require 'filewatcher'
require 'pry'
require 'io/console'
require 'bundler/setup'
require 'webpack5/builder'

def process_file(file)
  parser = Webpack5::Builder::DddMarkupParser.new

  parser
    .load_file(file)
    .parse
    .group
    .print
    .print_stats

  puts ''
  puts "Watching: #{file}"

end

directory = '/Users/davidcruwys/dev/c#/P04DomainMonopolyV1'
watch_file = File.join(directory, 'DOMAIN_INSTRUCTIONS.MD')

puts 'Watching for file changes'
puts "Directory: #{directory}"
puts "Watch File: #{watch_file}"

process_file(watch_file)

Filewatcher.new(directory).watch() do |filename, event|
  if(event == :updated) && filename.casecmp(watch_file).zero?
    puts "\n" * 70
    $stdout.clear_screen

    process_file(watch_file)
  end

  if(event == :delete)
    puts "File deleted: " + filename
  end
  if(event == :new)
    puts "Added file: " + filename
  end
end

puts 'Ending......................'

