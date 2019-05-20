# frozen_string_literal: true

ActiveAdmin.register Resource::Sermon do
  menu parent: 'Resources', label: 'Sermons'

  form do |f|
    f.semantic_errors
    inputs do
      f.input :name
      f.input :snippet
      f.input :content
      f.input :topic_ids, collection: Category::Topic.all, multiple: true
    end
    f.actions
  end
end
