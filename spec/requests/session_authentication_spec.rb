# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Session authentication', :aggregate_failures do
  it 'preserves administrator password sign-in, protected access and logout' do
    user = create(:user, :admin)
    user.confirm
    post user_session_path, params: { user: { email: user.email, password: user.password } }
    expect(response).to have_http_status(:redirect)
    get admin_root_path
    expect(response).to have_http_status(:ok)
    delete destroy_user_session_path
    get admin_root_path
    expect(response).to redirect_to(new_user_session_path)
  end

  it 'denies invalid password authentication' do
    user = create(:user, :admin)
    user.confirm
    post user_session_path, params: { user: { email: user.email, password: 'wrong-password' } }, as: :json
    expect(response).to have_http_status(:unauthorized)
    get admin_root_path
    expect(response).to redirect_to(new_user_session_path)
  end
end
