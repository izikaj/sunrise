# frozen_string_literal: true

module Sunrise
  class ManagerController < Sunrise::ApplicationController
    include Sunrise::Utils::SearchWrapper

    before_action :build_record, only: %i[new create]
    before_action :find_record, only: %i[show edit update destroy]
    before_action :authorize_resource

    helper :all
    helper_method :abstract_model, :apply_scope, :scoped_index_path

    respond_to(*Sunrise::Config.navigational_formats)
    respond_to :xml, :csv, :xlsx, only: %i[export]

    def index
      @records = abstract_model.apply_scopes(params)

      respond_with(@records) do |format|
        format.html { render_with_scope(abstract_model.current_list) }
      end
    end

    def show
      respond_with(@record) do |format|
        format.html { render_with_scope }
      end
    end

    def new
      @record.assign_attributes(abstract_model.model_params)

      respond_with(@record) do |format|
        format.html { render_with_scope }
      end
    end

    def create
      @record.update_attributes(model_params)
      respond_with(@record, location: redirect_after_update(@record))
    end

    def edit
      respond_with(@record) do |format|
        format.html { render_with_scope }
      end
    end

    def update
      @record.update_attributes(model_params)
      respond_with(@record, location: redirect_after_update(@record))
    end

    def destroy
      @record.destroy
      respond_with(@record, location: scoped_index_path)
    end

    def export
      @records = abstract_model.apply_scopes(params, false)
      export_options = abstract_model.export_options

      respond_to do |format|
        format.xml  { render xml: @records }

        # streaming json/csv
        format.json { render export_options.merge(stream_json: @records) }
        format.csv  { render export_options.merge(stream_csv: @records) }

        # render xlsx spreadsheet
        format.xlsx { render export_options.merge(xlsx: @records) } if defined?(Mime::XLSX)

        format.all { redirect_to scoped_index_path }
      end
    end

    def import
      return render plain: 'Unacceptable', status: 422 unless import_possible?

      abstract_model.model.sunrise_dnd_import(self, params)
    end

    def sort
      abstract_model.update_sort(params)

      respond_to do |format|
        format.html { redirect_to redirect_after_update }
        format.json { render json: params }
      end
    end

    def mass_destroy
      abstract_model.destroy_all(params)

      respond_to do |format|
        format.html { redirect_to redirect_after_update }
        format.json { render json: params }
      end
    end

    protected

    def import_possible?
      abstract_model.model.respond_to?(:sunrise_dnd_import)
    end

    def find_model
      @abstract_model = Utils.get_model(params[:model_name], params)
      return @abstract_model if @abstract_model.present?

      raise ActionController::RoutingError, "Sunrise model #{params[:model_name]} not found"
    end

    def abstract_model
      @abstract_model ||= find_model
    end

    def build_record
      @record = abstract_model.build_record
    end

    def find_record
      @record = abstract_model.model.find(params[:id])
    end

    # Render a view for the specified scope. Turned off by default.
    # Accepts just :controller as option.
    def render_with_scope(scope = nil, action = action_name, path = controller_path)
      templates = [[path, action]]
      templates << [path, scope, action] if scope

      templates << [path, abstract_model.plural, scope, action] if Sunrise::Config.scoped_views?

      templates.reverse.each do |keys|
        name = File.join(*keys.compact.map(&:to_s))
        return render(template: name) if template_exists?(name)
      end
    end

    def apply_scope(scope, path = controller_path)
      templates = [[path, scope]]
      templates << [path, abstract_model.current_list, scope]

      if Sunrise::Config.scoped_views?
        templates << [path, abstract_model.plural, scope]
        templates << [path, abstract_model.plural, abstract_model.current_list, scope]
      end

      templates.reverse.each do |keys|
        name = File.join(*keys.compact.map(&:to_s))
        return name if template_exists?(name, nil, true)
      end

      # not found ... try render first
      templates.first.join('/')
    end

    def authorize_resource
      authorize!(action_name.to_sym, @record || abstract_model.model, context: :sunrise)
    end

    def scoped_index_path(options = {})
      options = options.merge(abstract_model.parent_hash)
      query = Rack::Utils.parse_query(cookies[:params])

      index_path(query.merge(options))
    end

    def redirect_after_update(_record = nil)
      if abstract_model.without_index?
        index_path(model_name: abstract_model.plural)
      else
        scoped_index_path
      end
    end

    def model_params
      abstract_model.permit_attributes(params, current_user)
    end
  end
end
