# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Operational routes', :aggregate_failures do
  let(:sermon_library_url) { 'https://www.ev.church/sermons' }
  let(:direct_upload_params) do
    {
      blob: {
        filename: 'sample.mp3', byte_size: 12,
        checksum: Digest::MD5.base64digest('sample audio'), content_type: 'audio/mpeg'
      }
    }
  end

  it 'keeps the admin authentication redirect on the resource application' do
    get admin_root_path

    expect(response).to redirect_to(new_user_session_path)
    expect(response.location).not_to start_with(sermon_library_url)
  end

  it 'keeps the sign-in page on the resource application' do
    get new_user_session_path

    expect(response).to have_http_status(:ok)
    expect(response.location).to be_nil
  end

  it 'keeps GraphQL requests on the resource application' do
    post graphql_path, params: { query: '{ __typename }' }, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq('data' => { '__typename' => 'Query' })
    expect(response.location).to be_nil
  end

  it 'keeps Active Storage blob delivery on the resource application' do
    sermon = create(:sermon)
    sermon.audio.attach(
      io: StringIO.new('sample audio'),
      filename: 'sample.mp3',
      content_type: 'audio/mpeg'
    )

    get rails_blob_path(sermon.audio, only_path: true)

    expect(response).to have_http_status(:found)
    expect(response.location).not_to start_with(sermon_library_url)
  end

  it 'keeps Active Storage direct uploads on the resource application' do
    post rails_direct_uploads_path, params: direct_upload_params, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include('direct_upload')
    expect(response.location).to be_nil
  end

  it 'serves compiled application assets without an external redirect' do
    get '/packs-test/js/application.js'

    expect(response).to have_http_status(:ok)
    expect(response.location).to be_nil
  end

  it 'preserves the legacy podcast feed alias' do
    create(:sermon, name: 'Podcast Message')

    get resources_sermon_path

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('application/rss+xml')
    expect(response.body).to include('<rss version="2.0"')
    expect(response.location).to be_nil
  end
end
