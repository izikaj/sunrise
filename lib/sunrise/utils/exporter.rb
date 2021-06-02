# frozen_string_literal: true

require 'csv'

module Sunrise
  module Utils
    class Exporter
      def initialize(source, options = {})
        @source = source
        @options = options
        @extname = options[:ext]
        @klass = (@options.delete(:klass) || extract_klass)
      end

      def columns_names
        @columns_names ||= (@options[:columns] || @klass.column_names)
      end

      def size
        @size ||= @source.respond_to?(:count) ? @source.count : @source.size
      end

      def enumerator(&block)
        Enumerator.new(&block)
      end

      def human_columns_names
        @human_columns_names ||= columns_names.map { |column| @klass.human_attribute_name(column.to_s) }
      end

      def extname
        @extname.presence || 'csv'
      end

      def basename
        @basename ||= @options[:filename] || @klass.model_name.plural || 'document'
      end

      def filename
        @filename ||= "#{basename}.#{extname}"
      end

      def columns_as_hash(record)
        return record.slice(*columns_names) if record.respond_to?(:slice)

        columns_names.each_with_object({}) do |column, result|
          result[column] = record.send(column)
        end
      end

      def columns_as_array(record)
        return record.slice(*columns_names).values if record.respond_to?(:slice)

        columns_names.each_with_object([]) do |column, result|
          result << record.send(column)
        end
      end

      def each(&block)
        return @source.find_each(&block) if @source.respond_to?(:find_each)

        Array.wrap(@source).each(&block)
      end

      def each_with_index
        count = 0

        each do |item|
          yield item, count
          count += 1
        end
      end

      protected

      def extract_klass
        if @source.respond_to?(:klass)
          @source.klass
        elsif @source.is_a?(Array)
          @source.first.try(:class)
        else
          @source.class
        end
      end
    end
  end
end
