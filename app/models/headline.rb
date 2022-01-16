class Headline < ApplicationRecord
  belongs_to :published_project, optional: true
  belongs_to :published_block, optional: true

  attr_accessor :file
  mount_uploader :file, ImageUploader

  validates :source, presence: true
  validates :published_project, presence: true, if: :project?
  validates :published_block, presence: true, if: :block?
  validates :file, presence: true, if: :file?

  default_scope { order(:display_id) }

  after_destroy :file_remove, :renumber

  # 新規display_idの採番
  def self.new_display_id
    maximum(:display_id).to_i + 1
  end

  # display_idの全件振り直し
  def renumber
    return unless self.class.new_display_id > self.class.count
    Headline.all.each_with_index do |headline, id|
      headline.update(display_id: id)
    end
  end

  # 表示用のJSON
  def self.album
    all.map do |headline|
      file = headline.file_source
      next if file.url.blank?

      {
        url: file.url,
        x: headline.position_x,
        y: headline.position_y
      }
    end.compact
  end

  # ファイルを引用元から格納したハッシュ
  def self.hash_list
    all.map do |headline|
      attributes = headline.attributes
      attributes["file"] = headline.source_file
      attributes
    end
  end

  def project?
    source == "project"
  end

  def block?
    source == "block"
  end

  def file?
    source == "file"
  end

  def file_source
    case source
    when "project"
      published_project.try(:file)
    when "block"
      published_block.try(:file)
    else
      file
    end
  end

  # コンテンツの種類に応じたファイルを取得
  def source_file
    case source
    when "project"
      published_project.try(:file)
    when "block"
      published_block.try(:file)
    when "file"
      file
    end
  end
end
