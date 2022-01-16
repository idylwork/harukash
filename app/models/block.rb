class Block < ApplicationRecord
  self.inheritance_column = :_type_disabled
  mount_uploader :file, ImageUploader
  belongs_to :project

  after_destroy :file_remove

  default_scope { order(:display_id) }

  # テキストブロック
  def text
    I18n.locale == :ja ? text_jp : text_en
  end
end
