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
      series.name = remote_series['name']
      series.save!
    end
  end

  def import_authors
    items('wpfc_preacher').each do |remote_author|
      series = Author.find_or_initialize_by(remote_id: remote_author['id'])
      series.name = remote_author['name']
      series.save!
    end
  end

  def import_sermons
    items('wpfc_sermon').each do |remote_sermon|
      sermon = Resource::Sermon.find_or_initialize_by(remote_id: remote_sermon['id'])
      sermon.name = remote_sermon['title']['rendered']
      sermon.authors = Author.where(remote_id: remote_sermon['wpfc_preacher'])
      sermon.series = Series.where(remote_id: remote_sermon['wpfc_sermon_series'])
      sermon.audio_url = remote_sermon['sermon_audio']
      sermon.published_at = Time.zone.at(remote_sermon['sermon_date'])
      sermon.save!
    end
  end

  def items(resource)
    Enumerator.new do |y|
      page = 1
      loop do
        data = HTTParty.get("#{base_url}#{resource}?page=#{page}&per_page=100")
        break unless data.empty? || data.code == 400

        data.each { |element| y.yield element }
        page += 1
      end
    end
  end
end
