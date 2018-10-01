# frozen_string_literal: true

class Post < ApplicationRecord
  validates :title, :content, presence: true
end
