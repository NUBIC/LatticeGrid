require 'utilities'

namespace :setup do
  task :wordle => :environment do
    block_timing("setup:wordle") {
      WordFrequency.save_abstract_frequency_map
      WordFrequency.save_investigator_frequency_map
    }
  end
end