# frozen_string_literal: true

xml.instruct! :xml, version: '1.0'

xml.rss version: '2.0',
        'xmlns:itunes' => 'http://www.itunes.com/dtds/podcast-1.0.dtd',
        'xmlns:media' => 'http://search.yahoo.com/mrss/',
        'xmlns:atom' => 'http://www.w3.org/2005/Atom' do
  xml.channel do
    xml.tag!('atom:link', 'href' => resources_url(format: 'rss'), 'rel' => 'self', 'type' => 'application/rss+xml')
    xml.title "Auckland Ev Church - #{(params[:resource_type] || 'resource').pluralize.titleize}"
    xml.link resources_url(resource_type: params[:resource_type])
    xml.description "We are a bunch of people, convinced we're not perfect, captivated by the historical Jesus, "\
                    'excited about the future he offers, and eager to authentically share this hope with Auckland.'
    xml.language 'en'
    xml.lastBuildDate resources.first.published_at.to_s(:rfc822)
    xml.copyright "Copyright &copy; #{Date.today.year} Auckland Ev"
    xml.itunes :author, 'Auckland Ev'
    xml.itunes :keywords, 'auckland, evangelical, church, christian, sermon, ev, jesus, god, hope, holy spirit'
    xml.itunes :explicit, 'clean'
    xml.itunes :image, href: image_url('auckland_ev_podcast.jpg', skip_pipeline: true)
    xml.itunes :owner do
      xml.itunes :name, 'Auckland Ev'
      xml.itunes :email, 'info@aucklandev.co.nz'
    end
    xml.itunes :block, 'no'
    xml.itunes :category, text: 'Religion & Spirituality' do
      xml.itunes :category, text: 'Christianity'
    end
    resources.each do |resource|
      xml.item do
        xml.title resource.name
        xml.description resource.description
        xml.pubDate resource.published_at.to_s(:rfc822)
        xml.enclosure url: resource.audio_url, type: 'audio/mp3' if resource.audio_url
        xml.enclosure url: polymorphic_url(resource.audio), type: resource.audio.content_type if resource.audio.present?
        xml.link resource_url(resource)
        xml.guid({ isPermaLink: 'false' }, resource_url(resource))
        xml.itunes :author, resource.author_names
        xml.itunes :subtitle, truncate(resource.description, length: 150)
        xml.itunes :summary, resource.description
        xml.itunes :explicit, 'no'
        xml.itunes :image, href: polymorphic_url(resource.banner) if resource.banner.present?
      end
    end
  end
end
