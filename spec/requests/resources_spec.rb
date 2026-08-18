# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Resources RSS Feed', :aggregate_failures do
  it 'permanently redirects to the EV Church sermons feed' do
    get resources_path(format: :rss)

    expect(response).to redirect_to('https://www.ev.church/sermons/feed.xml')
    expect(response).to have_http_status(:moved_permanently)
  end
end
