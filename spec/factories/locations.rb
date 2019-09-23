# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    name { 'MyString' }
    snippet { 'MyString' }
    content { 'MyText' }
    address { 'MyString' }
  end
end
