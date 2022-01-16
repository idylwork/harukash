class Sticky < ApplicationRecord
  attr_accessor :file
  mount_uploader :file, ImageUploader

  after_destroy :file_remove
  after_commit :contents_issue

  def self.image
    first.file
  end

  # 表示条件を満たしていた場合のみレコードを取得
  def self.fetch
    sticky = first
    now = Time.current
    return unless sticky.is_visible
    return if sticky.start_at.present? && (now < sticky.start_at || sticky.end_at < now)
    return if (I18n.locale == :ja ? sticky.html_jp : sticky.html_en).blank?
    sticky
  end

  def html
    html = I18n.locale == :ja ? html_jp : html_en
    html.sub(/src=""/, %(src="#{file_url}"))
  end
end
