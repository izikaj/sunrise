# frozen_string_literal: true

module Sunrise
  module Renderers
    class StreamJson
      class << self
        def declare!
          ::ActionController::Renderers.add :stream_json do |collection, options|
            exporter = ::Sunrise::Utils::Exporter.new(collection, options.merge(ext: :json))

            # add headers for streaming
            headers.delete('Content-Length')
            headers['Cache-Control'] = 'no-cache'
            headers['Content-Type'] = Mime::JSON
            headers['Content-Disposition'] = "attachment; filename=\"#{exporter.filename}\""
            headers['X-Accel-Buffering'] = 'no'

            response.status = 200
            # pass enumerator to body (should use ActionController::Live in modern rails)
            self.response_body = exporter.enumerator do |yielder|
              yielder << '['
              exporter.each_with_index do |record, index|
                yielder << "#{',' if index > 0}#{JSON.dump(exporter.columns_as_hash(record))}"
              end
              yielder << ']'
            end
          end
        end
      end
    end
  end
end
