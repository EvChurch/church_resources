# frozen_string_literal: true

# CI-only acceptance. The disposable container uses local storage, never S3.
require 'uri'
require 'socket'

database = URI(ENV.fetch('DATABASE_URL'))
redis = URI(ENV.fetch('REDIS_URL'))
raise 'Disposable database required' unless database.host == '127.0.0.1' &&
                                          database.path == '/church_resources_container_ci'
raise 'Disposable Redis required' unless redis.host == '127.0.0.1' && redis.path == '/15'
raise 'Production configuration required' unless ENV.fetch('RAILS_ENV') == 'production'

module SecurityFixtureSocketGuard
  def new(host, ...)
    raise 'External fixture connection prohibited' unless %w[127.0.0.1 ::1 localhost].include?(host)

    super
  end
end
TCPSocket.singleton_class.prepend(SecurityFixtureSocketGuard)

require_relative '../config/environment'
require 'rack/mock'
require 'warden/test/helpers'

class SecuritySessionFixture
  include Warden::Test::Helpers

  def assert(condition, message)
    raise message unless condition
  end

  def request(cookie = nil)
    env = Rack::MockRequest.env_for('https://resources.example.test/admin/sermons',
                                   'HTTP_COOKIE' => cookie.to_s)
    status, headers, body = Rails.application.call(env)
    text = +''
    body.each { |part| text << part }
    body.close if body.respond_to?(:close)
    [status, headers.transform_keys(&:downcase), text]
  end

  def denied?(response)
    status, headers, body = response
    [301, 302, 303, 401, 403].include?(status) &&
      (status >= 400 || URI(headers.fetch('location')).path == '/users/sign_in') &&
      !body.include?('Synthetic private sermon')
  end

  def create_user(email)
    User.create!(email:, password: 'synthetic-image-password', confirmed_at: Time.current)
  end

  def verify_session
    admin = create_user('image-admin@example.invalid')
    admin.add_role(:admin)
    other = create_user('image-reader@example.invalid')
    Sermon.create!(name: 'Synthetic private sermon')
    assert(denied?(request), 'Anonymous request accessed admin records')
    login_as(admin, scope: :user)
    status, headers, body = request
    assert(status == 200 && body.include?('Synthetic private sermon'), "Admin read failed: #{status}")
    cookies = Array(headers.fetch('set-cookie')).map { |value| value.split(';', 2).first }.join('; ')
    assert(!cookies.empty?, 'No production session cookie issued')
    assert(request(cookies).first == 200, 'Issued session cookie did not authenticate')
    session_header = Array(headers.fetch('set-cookie')).find do |value|
      value.start_with?('_church_resources_session=')
    end
    assert(session_header&.match?(/; samesite=lax/i), 'Production cookie lacks explicit SameSite=Lax')
    assert(denied?(request("#{cookies}tampered")), 'Tampered session authenticated')
    login_as(other, scope: :user)
    assert(denied?(request), 'Non-admin identity accessed admin records')
    verify_concurrent_revocation(cookies)
    # Issue another session so deleted-identity denial is independently tested.
    login_as(admin, scope: :user)
    _, fresh_headers, = request
    cookies = Array(fresh_headers.fetch('set-cookie')).map { |value| value.split(';', 2).first }.join('; ')
    admin.destroy!
    assert(denied?(request(cookies)), 'Deleted admin identity retained access')
    puts 'PASS: production session issue/reuse, protected sermon read and anonymous/tampered/non-admin/deleted denials'
  ensure
    Warden.test_reset!
  end

  def verify_concurrent_revocation(cookies)
    session_value = cookies.split('; ').find { |cookie| cookie.start_with?('_church_resources_session=') }
    sid = Rack::Session::SessionId.new(session_value.split('=', 2).last)
    deleted = false
    # Complete another request's backend deletion after authentication loaded
    # this session, before CacheStore commits the protected request's response.
    subscriber = ActiveSupport::Notifications.subscribe('process_action.action_controller') do
      Thread.new do
        Rails.cache.delete("_session_id:#{sid.private_id}")
        Rails.cache.delete("_session_id:#{sid.public_id}")
      end.value
      deleted = true
    end
    begin
      response = request(cookies)
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end
    assert(deleted && response.first == 200, 'Overlapping authenticated request was not exercised')
    session_cookies = Array(response[1]['set-cookie']).grep(/\A_church_resources_session=/)
    assert(session_cookies.empty?, 'Revoked request resent its session cookie')
    assert(denied?(request(cookies)), 'Overlapping request restored revoked credentials')
    puts 'PASS: actual Redis overlapping revocation stays denied; production cookie emits SameSite=Lax'
  end

  def run
    assert(Rails.application.config.active_storage.service == :local, 'CI storage isolation missing')
    ActionMailer::Base.perform_deliveries = false
    ActiveJob::Base.queue_adapter = :test
    ActiveRecord::Base.transaction do
      verify_session
      assert(ActiveJob::Base.queue_adapter.enqueued_jobs.empty?, 'Fixture enqueued work')
      raise ActiveRecord::Rollback
    end
    assert(!Sermon.exists?(name: 'Synthetic private sermon'), 'Disposable records were not rolled back')
    puts 'PASS: disposable records rolled back; no S3, provider requests, mail or jobs'
  end
end

SecuritySessionFixture.new.run
