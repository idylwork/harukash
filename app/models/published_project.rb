class PublishedProject < ApplicationRecord
  belongs_to :category
  has_many :published_blocks, dependent: :destroy
  accepts_nested_attributes_for :published_blocks, allow_destroy: true
  has_many :published_roles, dependent: :destroy
  accepts_nested_attributes_for :published_roles, allow_destroy: true
  attr_accessor :file
  mount_uploader :file, ImageUploader
  has_many :headlines, dependent: :destroy
  has_one :page, dependent: :destroy

  validates :title, presence: true
  validates :date, presence: true

  after_create :page_create
  after_destroy :file_remove
  after_commit :contents_issue

  # ページ番号順
  scope :index_list, lambda { |display_count|
    includes(:page).order("pages.order DESC").limit(display_count)
  }

  def self.last_issue
    maximum(:updated_at) || Time.news(2018, 6)
  end

  # 本文概要
  def overview
    I18n.locale == :ja ? overview_jp : overview_en
  end

  private

  # 新規公開時にページを追加
  def page_create
    page = Page.find_or_initialize_by(published_project_id: id)
    page.update_attributes(source: :project, order: Page.project.maximum(:order).to_i + 1)
  end
end
