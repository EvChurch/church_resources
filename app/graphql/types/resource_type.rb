# frozen_string_literal: true

class Types::ResourceType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: false
  field :snippet, String, null: true
  field :content, String, null: true
  field :authors, [Types::AuthorType], null: false
  field :scriptures, [Types::ScriptureType], null: false
  field :series, [Types::SeriesType], null: false
  field :topics, [Types::TopicType], null: false
  field :banner_url, String, null: true
  field :foreground_url, String, null: true
  field :background_url, String, null: true
  field :audio_url, String, null: true
  field :video_url, String, null: true
  field :youtube_url, String, null: true
end
