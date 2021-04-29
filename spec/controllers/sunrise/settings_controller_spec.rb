# frozen_string_literal: true

require 'spec_helper'

describe Sunrise::SettingsController, type: :controller do
  routes { Sunrise::Engine.routes }
  render_views

  before(:all) do
    Settings.some_setting = 'value'
    Settings.some_setting2 = 'value2'
  end

  describe 'admin' do
    login_admin

    it 'should render edit action' do
      get :edit

      expect(assigns(:settings)).not_to be_empty
      expect(response).to render_template('edit')
    end

    it 'should update settings' do
      put :update, settings: { some_setting: 'blablabla' }

      expect(Settings.some_setting).to eq 'blablabla'
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'anonymous user' do
    it 'should not render update action' do
      expect(controller).not_to receive(:update)
      put :update
    end

    it 'should not render edit action' do
      expect(controller).not_to receive(:edit)
      get :edit
    end

    it 'should redirect to login page' do
      get :edit

      expect(response).to redirect_to('/users/sign_in')
    end
  end
end
