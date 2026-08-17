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

  it 'uses ActiveAdmin defaults for the sign-in page' do
    route = Rails.application.routes.recognize_path(new_user_session_path, method: :get)

    expect(new_user_session_path).to eq('/admin/login')
    expect(route).to include(controller: 'users/sessions', action: 'new')

    get new_user_session_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('class="active_admin logged_out new"')
    expect(response.body).to include('id="session_new"')
  end

  it 'renders the ActiveAdmin sign-in page after invalid credentials' do
    post user_session_path, params: { user: { email: 'missing@example.com', password: 'incorrect' } }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('class="active_admin logged_out new"')
    expect(response.body).to include('id="session_new"')
  end

  it 'signs an administrator in and out through the ActiveAdmin routes' do
    user = create(:user, :admin)
    user.confirm

    post user_session_path, params: { user: { email: user.email, password: user.password } }

    expect(response).to redirect_to(admin_root_path)

    delete destroy_user_session_path

    expect(response).to redirect_to(new_user_session_path)
  end

  it 'preserves the existing non-session Devise routes' do
    expect(new_user_password_path).to eq('/users/password/new')
    expect(new_user_registration_path).to eq('/users/sign_up')
    expect(new_user_confirmation_path).to eq('/users/confirmation/new')
    expect(new_user_unlock_path).to eq('/users/unlock/new')
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

  it 'leaves compiled application assets to the static file server' do
    expect do
      Rails.application.routes.recognize_path('/packs/application.js', method: :get)
    end.to raise_error(ActionController::RoutingError)
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
