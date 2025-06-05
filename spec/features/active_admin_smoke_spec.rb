# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ActiveAdmin Smoke Tests', :js do
  let(:password) { 'testpassword123' }
  let(:admin) { create(:user, :admin, password: password, password_confirmation: password) }

  before do
    visit new_user_session_path
    fill_in 'Email', with: admin.email
    fill_in 'Password', with: password
    click_button 'Log in'
  end

  it 'loads Resource::Article index (with filter sidebar) without error' do
    visit admin_resource_articles_path
    expect(page).to have_css('.filter_form_field')
  end

  it 'loads Resource::Sermon index (with filter sidebar) without error' do
    visit admin_resource_sermons_path
    expect(page).to have_css('.filter_form_field')
  end

  it 'loads User index (with filter sidebar) without error' do
    visit admin_users_path
    expect(page).to have_css('.filter_form_field')
  end

  it 'loads Location index (with filter sidebar) without error' do
    visit admin_locations_path
    expect(page).to have_css('.filter_form_field')
  end

  it 'loads Step index (with filter sidebar) without error' do
    visit admin_steps_path
    expect(page).to have_css('.filter_form_field')
  end

  it 'loads Series index (with filter sidebar) without error' do
    visit admin_series_path
    expect(page).to have_css('.filter_form_field')
  end

  it 'loads Scripture index (with filter sidebar) without error' do
    visit admin_scriptures_path
    expect(page).to have_css('.filter_form_field')
  end

  it 'loads Author index (with filter sidebar) without error' do
    visit admin_authors_path
    expect(page).to have_css('.filter_form_field')
  end

  it 'loads Category::Topic index (with filter sidebar) without error' do
    visit admin_category_topics_path
    expect(page).to have_css('.filter_form_field')
  end
end
