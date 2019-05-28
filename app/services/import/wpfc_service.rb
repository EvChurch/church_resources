# frozen_string_literal: true

class Import::WpfcService
  attr_reader :base_url

  def self.import(base_url)
    new(base_url).import
  end

  def initialize(base_url)
    @base_url = base_url
  end

  def import
    import_authors
    import_series
    import_sermons
  end

  def import_series
    items('wpfc_sermon_series').each do |remote_series|
      series = Series.find_or_initialize_by(remote_id: remote_series['id'])
      series.name = CGI.unescapeHTML(remote_series['name'])
      series.slug = remote_series['slug']
      series.save!
    end
  end

  def import_authors
    items('wpfc_preacher').each do |remote_author|
      author = Author.find_or_initialize_by(remote_id: remote_author['id'])
      author.name = CGI.unescapeHTML(remote_author['name'])
      author.slug = remote_author['slug']
      author.save!
    end
  end

  def import_sermons
    items('wpfc_sermon').each do |remote_sermon|
      sermon = Resource::Sermon.find_or_initialize_by(remote_id: remote_sermon['id'])
      sermon.name = CGI.unescapeHTML(remote_sermon['title']['rendered'])
      sermon.slug = remote_sermon['slug']
      sermon.connection_scriptures = connection_scriptures(remote_sermon['bible_passage'])
      sermon.authors = Author.where(remote_id: remote_sermon['wpfc_preacher'])
      sermon.series = Series.where(remote_id: remote_sermon['wpfc_sermon_series'])
      sermon.audio_url = remote_sermon['sermon_audio']
      sermon.published_at = Time.zone.at(remote_sermon['sermon_date'])
      sermon.save!
    end
  end

  def connection_scriptures(bible_passage)
    matches = bible_passage.match(/(?<name>[\dA-Za-z ]*) (?<range>[\d:-]*)/)
    return [] if matches.blank?

    Scripture.where(name: matches[:name]).map do |scripture|
      Resource::Connection::Scripture.new(scripture: scripture, range: matches[:range])
    end
  end

  def items(resource)
    Enumerator.new do |y|
      page = 1
      loop do
        data = HTTParty.get("#{base_url}#{resource}?page=#{page}&per_page=100")
        break if data.empty? || data.code == 400

        data.each { |element| y.yield element }
        page += 1
      end
    end
  end
end
