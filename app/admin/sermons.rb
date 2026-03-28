# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
ActiveAdmin.register Sermon do
  menu label: 'Sermons'
  config.sort_order = 'published_at_desc'

  order_by :published_at do |order_clause|
    [order_clause.to_sql, 'NULLS LAST'].join(' ')
  end

  permit_params :name, :video, :audio, :audio_url, :published_at, :featured_at,
                topic_ids: [], author_ids: [], scripture_ids: [], series_ids: [],
                sermon_scriptures_attributes: %i[id sermon_id scripture_id range _destroy]

  filter :name
  filter :published_at
  filter :featured_at
  filter :series, collection: proc { Series.order(:name).all }

  batch_action :publish do |ids|
    Sermon.batch_publish(ids)
    redirect_to collection_path, notice: "#{ids.size} sermon(s) published"
  end

  batch_action :unpublish do |ids|
    Sermon.batch_unpublish(ids)
    redirect_to collection_path, notice: "#{ids.size} sermon(s) unpublished"
  end

  index do
    selectable_column
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
      f.input :audio_url
      f.input :video, as: :file
      f.input :audio, as: :file
      f.input :topics, collection: Category::Topic.all, multiple: true
      f.input :authors, collection: Author.all, multiple: true
      f.has_many :sermon_scriptures, heading: 'Bible Passage', new_record: 'Add Passage Range' do |a|
        a.input :scripture, collection: Scripture.all, label: 'Book'
        a.input :range
      end
      f.input :series, collection: Series.all, multiple: true
    end
    f.actions
  end
end
# rubocop:enable Metrics/BlockLength
