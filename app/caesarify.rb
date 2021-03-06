require 'dotenv/load'
require 'optparse'
require 'panoptes-client'
require 'pry'
require 'symbolized'

require './app/caesar'
require './app/config'
require './app/panoptes'
require './app/version'

module Caesarify
  class OptionsError < StandardError; end

  class App
    attr_accessor :args

    include Caesarify::App::Caesar
    include Caesarify::App::Config
    include Caesarify::App::Panoptes
    include Caesarify::App::Version

    def initialize(args)
      @args = SymbolizedHash.new args
      raise OptionsError.new("Please specify a workflow") unless App::Config.valid_args? args
    end

    def run
      panoptes_workflow = get_workflow workflow_id
      tasks = extract_tasks panoptes_workflow

      create_workflow(workflow_id)
      tasks.map do |task|
        create_extractor(workflow_id, task)
        create_reducer(workflow_id, task)
      end
    end
  end
end