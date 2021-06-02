# frozen_string_literal: true

module Sunrise
  module Renderers
    class Csv
      class << self
        def declare!
          ::ActionController::Renderers.add :csv do |collection, options|
            doc = ::Sunrise::Utils::CsvDocument.new(collection, options)
            send_data(
              doc.render,
              filename: doc.filename,
              type: ::Mime::CSV,
              disposition: 'attachment'
            )
          end
        end
      end
    end
  end
end
