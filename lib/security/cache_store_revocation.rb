# frozen_string_literal: true

require 'digest'
require 'action_dispatch/middleware/session/cache_store'

# Rails publisher backport: 5bb5ec66ed8faaf590ffe1222d7a5eb6e9d050f5.
# Remove on upgrade to a reviewed upstream release fixing GHSA-2586-8ghr-69fj.
module ChurchResourcesCacheStoreRevocation
  LOADED_SESSION_ID = 'action_dispatch.session.cache_store.loaded_session_id'
  UPSTREAM_SHA256 = '9489ce2095b343e7ee406ea18ceb6a5ce007a9652e6cf3c7f376b1c4e88f563c'

  def self.install!
    spec = Gem.loaded_specs.fetch('actionpack')
    source = File.join(spec.full_gem_path, 'lib/action_dispatch/middleware/session/cache_store.rb')
    unless spec.version.to_s == '7.2.4' && Digest::SHA256.file(source).hexdigest == UPSTREAM_SHA256
      raise 'Review/remove CacheStore revocation backport before changing ActionPack (GHSA-2586-8ghr-69fj)'
    end

    return if ActionDispatch::Session::CacheStore.ancestors.include?(self)

    ActionDispatch::Session::CacheStore.prepend(self)
  end

  def find_session(request, sid)
    loaded_sid, session = super
    # A miss generates a fresh ID; only an existing session can be revoked.
    request.set_header(LOADED_SESSION_ID, sid.private_id) if sid && loaded_sid == sid
    [loaded_sid, session]
  end

  def write_session(request, sid, session, options)
    return false if session && destroyed_since_loaded?(request, sid)

    super
  end

  private

  def destroyed_since_loaded?(request, sid)
    request.get_header(LOADED_SESSION_ID) == sid.private_id &&
      !exist_in_backend?(cache_key(sid.private_id)) &&
      !exist_in_backend?(cache_key(sid.public_id))
  end

  # A new local-cache scope sees another request's deletion, including Redis.
  # Like upstream, this existence check and the write are not atomic.
  def exist_in_backend?(key)
    if @cache.respond_to?(:with_local_cache)
      @cache.with_local_cache { @cache.exist?(key) }
    else
      @cache.exist?(key)
    end
  end
end
