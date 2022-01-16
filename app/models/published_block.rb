class PublishedBlock < ApplicationRecord
  self.inheritance_column = :_type_disabled
  mount_uploader :file, ImageUploader
  belongs_to :published_project
  has_many :headlines, dependent: :destroy

  after_destroy :file_remove
  after_commit :contents_issue

  default_scope { order(:display_id) }

  # テキストブロック
  def text
    I18n.locale == :ja ? text_jp : text_en
  end
end
