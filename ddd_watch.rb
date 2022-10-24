require 'filewatcher'
require 'pry'
require 'io/console'
require 'bundler/setup'
require 'webpack5/builder'
require 'handlebars/helpers/configuration'

def process_file(file)
  parser = Webpack5::Builder::DddMarkupParser.new

  rc_file = File.join(File.dirname(file), '.dddrc.json')
  clean_markdown_file = File.join(File.dirname(file), 'DOMAIN-RO.MD')

  # Needs a refactor
  parser
    .load_file(file)
    .parse
    .parse_to_markdown(clean_markdown_file)
    .group
    .filter
    .print_artifacts
    .print_filtered_stats
    .print_all_stats
    .print_configuration
    .generate_rc(rc_file, file, 'Monopoly')

  dddrc = JSON.parse(File.read(rc_file))

  # Extra settings that may belong in the dddrc
  opts = {
    settings: {
      namespace: 'p04_domain_monopoly_v1'
    }
  }

  # Needs a refactor
  generate_csharp_builders(dddrc, opts)
  generate_csharp_code(dddrc, opts)

  puts ''
  puts "Watching: #{file}"
end

# , code_folder)
def generate_csharp_builders(dddrc, opts)
  puts 'generate csharp builders'

  target_folder = '/Users/davidcruwys/dev/c#/P04DomainMonopolyV1/_/Builder'

  generate(Webpack5::Builder::DddGenerateResources, dddrc, target_folder, opts)
end

def generate_csharp_code(dddrc, opts)
  puts 'generate csharp code'

  target_folder = '/Users/davidcruwys/dev/c#/P04DomainMonopolyV1/_/Code'

  generate(Webpack5::Builder::DddGenerateCsharp, dddrc, target_folder, opts)
end

# , code_folder)
def generate(generator, dddrc, target_folder, opts)
  context = configure_builder(target_folder)

  FileUtils.rm_rf(target_folder) if File.directory?(target_folder)

  # sleep(2)

  generate = generator.new(context, dddrc)
  generate.debug
  generate.generate(opts)
end

def configure_builder(target_folder)
  Handlebars::Helpers.configure do |config|
    config_file = File.join(Gem.loaded_specs['handlebars-helpers'].full_gem_path, '.handlebars_helpers.json')
    config.helper_config_file = config_file
  end

  Webpack5::Builder.configure do |config|
    config.target_folder = target_folder
    config.template_folder = '/Users/davidcruwys/dev/kgems/k_dsl/_/.template/csharp-samples'
  end

  puts Webpack5::Builder.configuration.debug

  Webpack5::Builder::Context.new(Webpack5::Builder.configuration)
end

directory = '/Users/davidcruwys/dev/c#/P04DomainMonopolyV1'
watch_file = File.join(directory, 'DOMAIN_INSTRUCTIONS.MD')

puts 'Watching for file changes'
puts "Directory: #{directory}"
puts "Watch File: #{watch_file}"

process_file(watch_file)

Filewatcher.new(directory).watch do |filename, event|
  if (event == :updated) && filename.casecmp(watch_file).zero?
    puts "\n" * 70
    $stdout.clear_screen

    process_file(watch_file)
  end

  puts 'File deleted: ' + filename if event == :delete
  puts 'Added file: ' + filename if event == :new
end

puts 'Ending......................'
