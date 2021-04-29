# frozen_string_literal: true

require 'spec_helper'

describe PagesController, type: :controller do
  render_views

  before(:all) do
    @root = FactoryGirl.create(:structure_main)
  end

  context 'page' do
    before(:each) { @page = FactoryGirl.create(:structure_page, parent: @root) }

    it 'should render show action' do
      get :show, id: @page.slug

      # assigns(:structure).should == @page
      expect(assigns(:structure)).to eq @page

      # response.should be_success
      expect(response).to be_success
      # response.should render_template('show')
      expect(response).to render_template('show')
    end
  end
end
