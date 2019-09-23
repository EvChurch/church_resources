# frozen_string_literal: true

FactoryBot.define do
  factory :step do
    name { 'MyString' }
    snippet { 'MyString' }
    content { 'MyText' }
  end
end
