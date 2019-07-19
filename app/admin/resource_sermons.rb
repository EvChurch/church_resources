# frozen_string_literal: true

ActiveAdmin.register Resource::Sermon do
  menu parent: 'Resources', label: 'Sermons'
  config.sort_order = 'published_at_desc'

  permit_params :name, :snippet, :content, :video, :audio, :youtube_url, :audio_url, :published_at, :featured_at,
                topic_ids: [], author_ids: [], scripture_ids: [], series_ids: [],
                connection_scriptures_attributes: [:id, :resource_id, :scripture_id, :range, :_destroy]

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
      f.input :content, as: :trix
      f.input :youtube_url
      f.input :audio_url
      f.input :video, as: :file
      f.input :audio, as: :file
      f.input :topics, collection: Category::Topic.all, multiple: true
      f.input :authors, collection: Author.all, multiple: true
      f.has_many :connection_scriptures, 
        heading: "Bible Passage",
        new_record: "Add Passage Range" do |a|
        a.input :scripture, collection: Scripture.all, label: 'Book'
        a.input :range
      end
      f.input :series, collection: Series.all, multiple: true
    end
    f.actions
  end
end
