# frozen_string_literal: true

require_relative "../command"
require_relative "../interaction_tree"

module Dip
  module Commands
    class List < Dip::Command
      def execute
        tree = InteractionTree.new(Dip.config.interaction).list

        longest_name = tree.keys.map(&:size).max

        tree.each do |name, command|
          puts "#{name.ljust(longest_name)}  ##{command[:description] ? " #{command[:description]}" : ""}"
        end
      end
    end
  end
end
