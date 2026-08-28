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

    it 'permanently redirects a nested legacy sermon URL' do
      get '/resources/sermon/a-message-with-an-apparent-match'

      expect(response).to redirect_to(sermon_library_url)
      expect(response).to have_http_status(:moved_permanently)
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
    [
      ['authors', 'resources/authors'],
      ['scriptures', 'resources/scriptures'],
      ['series', 'resources/series'],
      ['topics', 'resources/topics']
    ].each do |segment, controller|
      it "recognizes the nested legacy #{segment} route" do
        expect(
          Rails.application.routes.recognize_path("/resources/sermon/#{segment}/legacy-slug")
        ).to include(controller:, action: 'show', id: 'legacy-slug')
      end
    end

    it 'maps authors to speaker pages using the church-web slug algorithm' do
      author = create(:author, name: "Renée & O'Connor")

      get author_path(author)

      expect(response).to redirect_to("#{sermon_library_url}/speakers/ren-e-o-connor")
      expect(response).to have_http_status(:moved_permanently)
    end

    it 'maps series to series pages' do
      series = create(:series, name: 'Hebrews: Jesus is Better')

      get series_path(series)

      expect(response).to redirect_to("#{sermon_library_url}/series/hebrews-jesus-is-better")
      expect(response).to have_http_status(:moved_permanently)
    end

    it 'maps topics to topic pages' do
      topic = create(:category_topic, name: 'Faith & Life', category: create(:category))

      get topic_path(topic)

      expect(response).to redirect_to("#{sermon_library_url}/topics/faith-life")
      expect(response).to have_http_status(:moved_permanently)
    end

    it 'maps scriptures to scripture pages even when the source URL uses a UUID' do
      scripture = create(:scripture, name: '1 Corinthians')

      get scripture_path(scripture.id)

      expect(response).to redirect_to("#{sermon_library_url}/scriptures/1-corinthians")
      expect(response).to have_http_status(:moved_permanently)
    end

    it 'passes a missing taxonomy slug through to the sermon library' do
      get author_path('missing-author')

      expect(response).to redirect_to("#{sermon_library_url}/speakers/missing-author")
      expect(response).to have_http_status(:moved_permanently)
    end

    it 'falls back when a taxonomy name cannot produce a target slug' do
      author = create(:author, name: '---')

      get author_path(author.id)

      expect(response).to redirect_to(sermon_library_url)
      expect(response).to have_http_status(:moved_permanently)
    end

    it 'maps nested legacy taxonomy URLs to the current sermon library' do
      series = create(:series, name: 'Colossians: Captivated')

      get "/resources/sermon/series/#{series.friendly_id}"

      expect(response).to redirect_to("#{sermon_library_url}/series/colossians-captivated")
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  describe 'legacy passage links' do
    it 'permanently redirects the supported query to BibleGateway' do
      get '/passage', params: { search: 'John 3:16', version: 'CSB', ignored: 'value' }

      expect(response).to redirect_to(
        'https://www.biblegateway.com/passage/?search=John+3%3A16&version=CSB'
      )
      expect(response).to have_http_status(:moved_permanently)
    end

    it 'redirects an empty passage request without adding an empty query string' do
      get '/passage'

      expect(response).to redirect_to('https://www.biblegateway.com/passage/')
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
