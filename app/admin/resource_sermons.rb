# frozen_string_literal: true

ActiveAdmin.register Resource::Sermon do
  menu parent: 'Resources', label: 'Sermons'
  config.sort_order = 'published_at_desc'

  controller do
    def scoped_collection
      collection = super
      order_param = params[:order]
      if order_param.blank? || order_param.start_with?('published_at_')
        direction = order_param&.match(/published_at_(asc|desc)/)&.[](1) || 'desc'
        collection.reorder(Arel.sql("published_at #{direction.upcase} NULLS LAST"))
      else
        collection
      end
    end
  end

  permit_params :name, :snippet, :content, :video, :audio, :youtube_url, :audio_url, :published_at, :featured_at,
                :sermon_notes, :connect_group_notes,
                topic_ids: [], author_ids: [], scripture_ids: [], series_ids: [],
                connection_scriptures_attributes: %i[id resource_id scripture_id range _destroy]

  filter :name
  filter :snippet
  filter :content
  filter :published_at
  filter :featured_at
  filter :series, collection: proc { Series.order(:name).all }

  batch_action :publish do |ids|
    Resource::Sermon.batch_publish(ids)
    redirect_to collection_path, notice: "#{ids.size} sermon(s) published"
  end

  batch_action :unpublish do |ids|
    Resource::Sermon.batch_unpublish(ids)
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

  form partial: 'admin/resource_sermons/form'
end
