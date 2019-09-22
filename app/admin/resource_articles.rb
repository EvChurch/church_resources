# frozen_string_literal: true

ActiveAdmin.register Resource::Article do
  menu parent: 'Resources', label: 'Articles'
  config.sort_order = 'published_at_desc'

  permit_params :name, :snippet, :content, :banner, :published_at, :featured_at,
                topic_ids: [], author_ids: [], scripture_ids: [], series_ids: []

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
      f.input :published_at, as: :datepicker
      f.input :featured_at, as: :datepicker
      f.input :snippet
      f.input :content, as: :trix
      f.input :banner, as: :file
      f.input :topics, collection: Category::Topic.all, multiple: true, input_html: { class: 'chosen-select' }
      f.input :authors, collection: Author.all, multiple: true, input_html: { class: 'chosen-select' }
      f.input :scriptures, collection: Scripture.all, multiple: true
      f.input :series, collection: Series.all, multiple: true, input_html: { class: 'chosen-select' }
    end
    f.actions
  end
end
