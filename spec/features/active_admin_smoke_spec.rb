# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ActiveAdmin Smoke Tests', :js do
  let(:password) { 'testpassword123' }
  let(:admin) { create(:user, :admin, password: password, password_confirmation: password) }

  before do
    login_as(admin, scope: :user)
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
    visit admin_series_index_path
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

  it 'loads Category index (with filter sidebar) without error' do
    visit admin_categories_path
    expect(page).to have_css('.filter_form_field')
  end

  it 'loads Location Connection Steps index (with filter sidebar) without error' do
    visit admin_location_connection_steps_path
    expect(page).to have_css('.filter_form_field')
  end

  it 'loads Location Events index (with filter sidebar) without error' do
    visit admin_location_events_path
    expect(page).to have_css('.filter_form_field')
  end

  it 'loads Location Prayers index (with filter sidebar) without error' do
    visit admin_location_prayers_path
    expect(page).to have_css('.filter_form_field')
  end

  it 'loads Location Services index (with filter sidebar) without error' do
    visit admin_location_services_path
    expect(page).to have_css('.filter_form_field')
  end
end
