# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Resources RSS Feed' do
  around do |example|
    # Enable caching for this test
    original_caching_value = ActionController::Base.perform_caching
    ActionController::Base.perform_caching = true
    Rails.cache.clear

    example.run

    # Restore original caching setting
    ActionController::Base.perform_caching = original_caching_value
    Rails.cache.clear
  end

  let!(:sermon) { create(:resource, type: 'Resource::Sermon', name: 'The Main Event', published_at: 1.day.ago) }

  describe 'response' do
    before { get resources_path(format: :rss) }

    it 'is successful' do
      expect(response).to have_http_status(:ok)
    end

    it 'has the correct content type' do
      expect(response.content_type).to eq('application/rss+xml; charset=utf-8')
    end
  end

  describe 'feed content' do
    subject(:body) do
      get(resources_path(format: :rss))
      response.body
    end

    it { is_expected.to include('<rss version="2.0"') }
    it { is_expected.to include('<channel>') }
    it { is_expected.to include('<title>Ev Church - Resources</title>') }
    it { is_expected.to include('<item>') }
    it { is_expected.to include("<title>#{sermon.name}</title>") }
  end

  it 'calls the cache store' do
    # Spy on Rails.cache.fetch to ensure it's being used
    allow(Rails.cache).to receive(:fetch).and_call_original

    get resources_path(format: :rss)

    expect(Rails.cache).to have_received(:fetch).once
  end
end
