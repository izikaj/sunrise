# frozen_string_literal: true

require 'spec_helper'

describe Sunrise::ManagerController, type: :controller do
  routes { Sunrise::Engine.routes }
  describe '#current_ability' do
    before(:each) { @ability = controller.send(:current_ability) }

    it 'should have namespace sunrise' do
      expect(@ability.context).to eq :sunrise
    end

    it 'should be a guest user' do
      expect(@ability.user).to be_new_record
    end
  end

  describe 'admin' do
    login_admin

    context 'index' do
      before(:all) do
        @root = FactoryGirl.create(:structure_main)
        @page = FactoryGirl.create(:structure_page, parent: @root)
      end

      it 'should respond successfully' do
        get :index, model_name: 'structures'

        expect(assigns(:records)).to include(@root)
        expect(assigns(:records)).not_to include(@page)
        expect(response).to render_template('index')
      end

      it 'should render 404 page' do
        expect {
          get :index, model_name: 'wrong'
        }.to raise_error ActionController::RoutingError
      end

      it 'should not destroy root structure' do
        expect(@root.structure_type_id).to eq ::StructureType.main.id

        expect(controller).not_to receive(:destroy)
        delete :destroy, model_name: 'structures', id: @root.id
      end
    end

    context 'posts' do
      before(:all) do
        @post = FactoryGirl.create(:post)
      end

      it 'should respond successfully' do
        get :index, model_name: 'posts'

        expect(assigns(:records)).to include(@post)
        expect(response).to render_template('index')
      end
    end
  end
end
