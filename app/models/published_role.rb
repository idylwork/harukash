class PublishedRole < ApplicationRecord
  validates :name, presence: true
  validates :person, presence: true

  after_commit :contents_issue

  default_scope { order(:display_id) }
end
