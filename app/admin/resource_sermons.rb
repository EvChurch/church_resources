# frozen_string_literal: true

ActiveAdmin.register Resource::Sermon do
  menu parent: 'Resources', label: 'Sermons'
  config.sort_order = 'published_at_desc'

  permit_params :name, :snippet, :content, :video, :audio, :youtube_url, :audio_url, :published_at, :featured_at,
                :sermon_notes, :connect_group_notes,
                topic_ids: [], author_ids: [], scripture_ids: [], series_ids: [],
                connection_scriptures_attributes: %i[id resource_id scripture_id range _destroy]

  filter :name
  filter :snippet
  filter :content
  filter :published_at
  filter :featured_at
  filter :author
  filter :scripture
  filter :series
  filter :topic

  index do
    id_column
    column :name
    column :published_at
    column :featured_at
    actions
  end

  form do |f|
    f.semantic_errors
    inputs do
      f.input :name
      f.input :published_at, as: :date_time_picker
      f.input :featured_at, as: :date_time_picker
      f.input :snippet
      f.input :content, as: :text
      f.input :youtube_url
      f.input :audio_url
      f.input :video, as: :file
      f.input :audio, as: :file
      f.input :topics, collection: Category::Topic.all, multiple: true
      f.input :authors, collection: Author.all, multiple: true
      f.has_many :connection_scriptures,
                 heading: 'Bible Passage',
                 new_record: 'Add Passage Range' do |a|
        a.input :scripture, collection: Scripture.all, label: 'Book'
        a.input :range
      end
      f.input :series, collection: Series.all, multiple: true
      f.input :sermon_notes, as: :text
      f.input :connect_group_notes, as: :text
    end
    f.actions
  end
end
