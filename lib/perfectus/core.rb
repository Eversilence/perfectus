require 'rubycritic'
require 'rubycritic/cli/options'
require 'rubycritic/command_factory'
require 'rails_best_practices'
require 'launchy'

module Perfectus
  class Core
    OUTPUT_DIR = "perfectus_output"

    def initialize
      Dir.mkdir(OUTPUT_DIR) unless Dir.exist?(OUTPUT_DIR)

      rails_best_practices
      metric_fu
      rubycritic
    end

    private
    
    def rubycritic
      options = {
          mode: nil,
          root: File.join(OUTPUT_DIR, "rubycritic"),
          format: 'html',
          deduplicate_symlinks: false,
          paths: ['.'],
          suppress_ratings: false,
          help_text: "",
          minimum_score: 0,
          no_browser: true
      }
      reporter = Rubycritic::CommandFactory.create(options).execute
      print(reporter.status_message)
      reporter.status
      Launchy.open File.join(OUTPUT_DIR, "rubycritic", "overview.html")
    end

    def rails_best_practices
      output_file = File.join(OUTPUT_DIR, "rails_best_practices.html")
      options = {
          "format" => "html",
          "output-file" => output_file
      }
      analyzer = RailsBestPractices::Analyzer.new(".", options)
      analyzer.analyze
      analyzer.output
      analyzer.runner.errors.size
      Launchy.open(output_file)
    end
  end
end
