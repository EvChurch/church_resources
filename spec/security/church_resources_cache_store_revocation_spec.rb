# frozen_string_literal: true

require 'spec_helper'
require 'active_support'
require 'active_support/core_ext'
require 'active_support/cache'
require 'action_dispatch'
require 'action_dispatch/middleware/session/cache_store'
require 'rack/mock'
require_relative '../../lib/security/cache_store_revocation'
ChurchResourcesCacheStoreRevocation.install!

# Exercise the installed middleware without a database, Redis or real identities.
RSpec.describe ChurchResourcesCacheStoreRevocation, :aggregate_failures do
  # RedisCacheStore uses this same request-local strategy. A second thread's
  # deletion must be visible even while the first thread has a cached read.
  let(:cache) do
    cache_class = Class.new(ActiveSupport::Cache::MemoryStore) do
      prepend ActiveSupport::Cache::Strategy::LocalCache
    end
    stub_const('SyntheticSessionLocalCache', cache_class).new
  end
  let(:options) { { cache: cache, key: '_church_resources_session', expire_after: 3600, same_site: :lax } }
  let(:app) do
    endpoint = lambda do |env|
      request = ActionDispatch::Request.new(env)
      session = request.session
      case request.path
      when '/login'
        session[:identity] = 'synthetic-admin'
      when '/logout'
        request.reset_session
      when '/rotate'
        request.reset_session
        session[:identity] = 'synthetic-rotated'
      when '/overlap-read', '/overlap-write', '/revoke'
        session[:identity]
        if request.path == '/revoke'
          sid = session.id
          Thread.new { store.delete_session(nil, sid, {}) }.value
        else
          Thread.new { fetch('/logout', env['HTTP_COOKIE']) }.value
        end
        session[:identity] = 'stale-admin' if request.path == '/overlap-write'
      end
      identity = session[:identity]
      [identity ? 200 : 401, { 'content-type' => 'text/plain' }, [identity || 'denied']]
    end
    middleware = ActionDispatch::Session::CacheStore.new(endpoint, **options)
    ActionDispatch::Cookies.new(middleware)
  end
  let(:store) { ActionDispatch::Session::CacheStore.new(->(_) { [200, {}, []] }, **options) }

  def fetch(path, cookie = nil)
    cache.with_local_cache do
      Rack::MockRequest.new(app).get("https://example.test#{path}", 'HTTP_COOKIE' => cookie.to_s)
    end
  end

  def session_cookie(response)
    Array(response['set-cookie']).find { |value| value.start_with?(options[:key]) }.split(';', 2).first
  end

  %w[/overlap-read /overlap-write /revoke].each do |path|
    it "keeps old credentials denied after #{path} completes" do
      cookie = session_cookie(fetch('/login'))
      response = fetch(path, cookie)
      expect(fetch('/protected', cookie).status).to eq(401)
      expect(response['set-cookie']).to be_nil
    end
  end

  it 'creates and reuses ordinary sessions with an emitted Lax cookie' do
    response = fetch('/login')
    expect(response['set-cookie']).to match(/samesite=lax/i)
    expect(fetch('/protected', session_cookie(response)).body).to eq('synthetic-admin')
  end

  it 'preserves rotation and rejects the previous credentials' do
    old_cookie = session_cookie(fetch('/login'))
    new_cookie = session_cookie(fetch('/rotate', old_cookie))
    expect(new_cookie).not_to eq(old_cookie)
    expect(fetch('/protected', old_cookie).status).to eq(401)
    expect(fetch('/protected', new_cookie).body).to eq('synthetic-rotated')
  end

  it 'keeps sequential logout effective' do
    cookie = session_cookie(fetch('/login'))
    fetch('/logout', cookie)
    expect(fetch('/protected', cookie).status).to eq(401)
  end

  it 'migrates a surviving legacy public key to the private key' do
    sid = store.send(:generate_sid)
    cache.write("_session_id:#{sid.public_id}", { 'identity' => 'synthetic-legacy' })
    request = ActionDispatch::Request.new(Rack::MockRequest.env_for('/'))
    loaded_sid, session = store.find_session(request, sid)
    store.write_session(request, loaded_sid, session, {})
    expect(cache.read("_session_id:#{sid.private_id}")).to eq(session)
  end

  it 'fails visibly on an unsupported ActionPack version' do
    allow(Gem.loaded_specs.fetch('actionpack')).to receive(:version).and_return(Gem::Version.new('7.2.5'))
    expect { described_class.install! }.to raise_error(%r{Review/remove CacheStore})
  end

  it 'fails visibly when the reviewed upstream source changes' do
    allow(Digest::SHA256).to receive(:file).and_return(double(hexdigest: 'unreviewed'))
    expect { described_class.install! }.to raise_error(%r{Review/remove CacheStore})
  end

  context 'with a backend without request-local caching' do
    let(:cache) { ActiveSupport::Cache::MemoryStore.new }

    it 'does not restore a revoked session' do
      sid = store.send(:generate_sid)
      request = ActionDispatch::Request.new(Rack::MockRequest.env_for('/'))
      store.write_session(request, sid, { 'identity' => 'synthetic' }, {})
      loaded_sid, session = store.find_session(request, sid)
      store.delete_session(request, sid, {})
      expect(store.write_session(request, loaded_sid, session, {})).to be(false)
    end
  end
end
