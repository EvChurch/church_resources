# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public resource redirects', :aggregate_failures do
  let(:sermon_library_url) { 'https://www.ev.church/sermons' }

  describe 'resource pages' do
    it 'permanently redirects the HTML index without carrying its query string' do
      get resources_path, params: { page: 2 }

      expect(response).to redirect_to(sermon_library_url)
      expect(response).to have_http_status(:moved_permanently)
    end

    it 'permanently redirects HEAD requests to the index' do
      head resources_path

      expect(response).to redirect_to(sermon_library_url)
      expect(response).to have_http_status(:moved_permanently)
    end

    it 'falls back to the sermon library for an existing sermon' do
      sermon = create(:sermon, name: 'A Message With An Apparent Match')

      get resource_path(sermon)

      expect(response).to redirect_to(sermon_library_url)
      expect(response).to have_http_status(:moved_permanently)
    end

    it 'falls back to the sermon library for a missing sermon' do
      get resource_path('missing-sermon')

      expect(response).to redirect_to(sermon_library_url)
      expect(response).to have_http_status(:moved_permanently)
    end

    it 'does not externally redirect unsupported index formats' do
      expect { get resources_path(format: :json) }.to raise_error(ActionController::UnknownFormat)
    end
  end

  describe 'taxonomy indexes' do
    {
      authors_path: 'authors',
      series_index_path: 'series',
      topics_path: 'topics',
      scriptures_path: 'scriptures'
    }.each do |path_helper, label|
      it "permanently redirects the #{label} index to the sermon library" do
        get public_send(path_helper)

        expect(response).to redirect_to(sermon_library_url)
        expect(response).to have_http_status(:moved_permanently)
      end
    end
  end

  describe 'taxonomy details' do
    it 'maps authors to speaker pages using the church-web slug algorithm' do
      author = create(:author, name: "Renée & O'Connor")

      get author_path(author.id)

      expect(response).to redirect_to("#{sermon_library_url}/speakers/ren-e-o-connor")
      expect(response).to have_http_status(:moved_permanently)
    end

    it 'maps series to series pages' do
      series = create(:series, name: 'Hebrews: Jesus is Better')

      get series_path(series.id)

      expect(response).to redirect_to("#{sermon_library_url}/series/hebrews-jesus-is-better")
      expect(response).to have_http_status(:moved_permanently)
    end

    it 'maps topics to topic pages' do
      topic = create(:category_topic, name: 'Faith & Life', category: create(:category))

      get topic_path(topic.id)

      expect(response).to redirect_to("#{sermon_library_url}/topics/faith-life")
      expect(response).to have_http_status(:moved_permanently)
    end

    it 'maps scriptures to scripture pages even when the source URL uses a UUID' do
      scripture = create(:scripture, name: '1 Corinthians')

      get scripture_path(scripture.id)

      expect(response).to redirect_to("#{sermon_library_url}/scriptures/1-corinthians")
      expect(response).to have_http_status(:moved_permanently)
    end

    it 'falls back when a taxonomy record is missing' do
      get author_path('missing-author')

      expect(response).to redirect_to(sermon_library_url)
      expect(response).to have_http_status(:moved_permanently)
    end

    it 'falls back when a taxonomy name cannot produce a target slug' do
      author = create(:author, name: '---')

      get author_path(author.id)

      expect(response).to redirect_to(sermon_library_url)
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  describe 'static public pages' do
    {
      '/' => 'home page',
      '/home' => 'legacy home path',
      '/permissions' => 'permissions page',
      '/privacy' => 'privacy page',
      '/terms' => 'terms page'
    }.each do |path, label|
      it "permanently redirects the #{label} to the sermon library" do
        get path

        expect(response).to redirect_to(sermon_library_url)
        expect(response).to have_http_status(:moved_permanently)
      end
    end
  end
end
