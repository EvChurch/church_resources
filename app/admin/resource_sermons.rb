# frozen_string_literal: true

ActiveAdmin.register Resource::Sermon do
  menu parent: 'Resources', label: 'Sermons'
  config.sort_order = 'published_at_desc'

  permit_params :name, :snippet, :content, :video, :audio, :youtube_url, :audio_url, :published_at, :featured_at,
                topic_ids: [], author_ids: [], scripture_ids: [], series_ids: []

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
      f.input :published_at, as: :datepicker
      f.input :featured_at, as: :datepicker
      f.input :snippet
      f.input :content
      f.input :youtube_url
      f.input :audio_url
      f.input :video, as: :file
      f.input :audio, as: :file
      f.input :topics, collection: Category::Topic.all, multiple: true
      f.input :authors, collection: Author.all, multiple: true
      f.input :scriptures, collection: Scripture.all, multiple: true
      f.input :series, collection: Series.all, multiple: true
    end
    f.actions
  end
end
