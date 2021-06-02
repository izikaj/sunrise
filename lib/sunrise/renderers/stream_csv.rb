# frozen_string_literal: true

module Sunrise
  module Renderers
    class StreamCsv
      class << self
        def declare!
          ::ActionController::Renderers.add :stream_csv do |collection, options|
            doc = ::Sunrise::Utils::CsvDocument.new(collection, options)

            # add headers for streaming
            headers.delete('Content-Length')
            headers['Cache-Control'] = 'no-cache'
            headers['Content-Type'] = 'text/csv'
            headers['Content-Disposition'] = "attachment; filename=\"#{doc.filename}\""
            headers['X-Accel-Buffering'] = 'no'

            response.status = 200
            # pass enumerator to body (should use ActionController::Live in modern rails)
            self.response_body = doc.stream
          end
        end
      end
    end
  end
end
