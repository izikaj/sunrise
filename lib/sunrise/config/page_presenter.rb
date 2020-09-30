# frozen_string_literal: true

module Sunrise
  module Config
    # A simple object that gets used to present different aspects of views
    #
    # Initialize with a set of options and a block. The options become
    # available using hash style syntax.
    #
    # Usage:
    #
    #     presenter = PagePresenter.new as: :table do
    #       # some awesome stuff
    #     end
    #
    #     presenter[:as]    #=> :table
    #     presenter.block   #=> The block passed in to new
    #
    class PagePresenter
      attr_reader :block, :options

      delegate :has_key?, to: :options

      def initialize(options = {}, &block)
        @options = options
        @block = block
      end

      def [](key)
        @options[key]
      end
    end
  end
end
