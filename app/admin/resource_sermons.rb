# frozen_string_literal: true

ActiveAdmin.register Resource::Sermon do
  menu parent: 'Resources', label: 'Sermons'

  permit_params :name, :snippet, :content, :video, :audio, :youtube_url,
                topic_ids: [], author_ids: [], scripture_ids: [], series_ids: []

  form do |f|
    f.semantic_errors
    inputs do
      f.input :name
      f.input :snippet
      f.input :content
      f.input :video, as: :file
      f.input :audio, as: :file
      f.input :youtube_url
      f.input :topics, collection: Category::Topic.all, multiple: true
      f.input :authors, collection: Author.all, multiple: true
      f.input :scriptures, collection: Scripture.all, multiple: true
      f.input :series, collection: Series.all, multiple: true
    end
    f.actions
  end
end
