# frozen_string_literal: true

module Sunrise
  module Renderers
    autoload :Csv, 'sunrise/renderers/csv'
    autoload :StreamCsv, 'sunrise/renderers/stream_csv'
    autoload :StreamJson, 'sunrise/renderers/stream_json'
  end
end
