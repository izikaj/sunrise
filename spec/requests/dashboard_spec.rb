# frozen_string_literal: true

require 'spec_helper'

describe 'Sunrise Manager Dashboard' do
  subject { page }
  before(:all) do
    @admin = FactoryGirl.create(:admin_user, email: "#{Time.now.to_i}@gmail.com")

    @post = FactoryGirl.create(:post)
    @user = FactoryGirl.create(:redactor_user)
  end

  context 'admin' do
    before(:each) { login_as @admin }

    describe 'GET /manage' do
      before(:each) do
        visit dashboard_path
      end

      it 'should show page title' do
        expect(page).to have_content('Dashboard')
      end
    end
  end

  describe 'anonymous user' do
    before(:each) do
      visit dashboard_path
    end

    it 'should redirect to login page' do
      expect(page).to have_content('Log in')
    end
  end
end
