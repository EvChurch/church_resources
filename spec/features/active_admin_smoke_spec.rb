# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ActiveAdmin Smoke Tests', :js do
  let(:password) { 'testpassword123' }
  let(:admin) { create(:user, :admin, password: password, password_confirmation: password) }

  before do
    login_as(admin, scope: :user)
  end

  it 'loads Sermon index (with filter sidebar) without error' do
    visit admin_sermons_path
    expect(page).to have_css('.filter_form_field')
  end

  it 'loads User index (with filter sidebar) without error' do
    visit admin_users_path
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
end
