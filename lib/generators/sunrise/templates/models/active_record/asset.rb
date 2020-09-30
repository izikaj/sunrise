# frozen_string_literal: true

require 'rails-uploader'

class Asset < ActiveRecord::Base
  include Uploader::Asset
  include Sunrise::Models::Asset

  validates_presence_of :data

  default_scope -> { order("#{quoted_table_name}.sort_order") }
end
