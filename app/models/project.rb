class Project < ApplicationRecord
  belongs_to :category
  has_many :blocks, dependent: :destroy
  accepts_nested_attributes_for :blocks, allow_destroy: true
  has_many :roles, dependent: :destroy
  accepts_nested_attributes_for :roles, allow_destroy: true
  attr_accessor :file
  mount_uploader :file, ImageUploader
  has_one :published_project, foreign_key: "id"

  before_validation :parse_save
  validates :title, presence: true
  validates :date, presence: true

  before_destroy :destroy_with_published
  after_destroy :file_remove

  private

  def parse_save
    # 背景色なしならtransparentに
    self.color_bg ||= "transparent"
    self.color_edge ||= "transparent"

    # overviewを登録
    en = []
    jp = []
    blocks.find_all { |b| b.type == "text" }.sort_by(&:display_id).each do |block|
      en << block.text_en.presence
      jp << block.text_jp.presence
    end
    self.overview_en = en.compact.join(" ").truncate(200)
    self.overview_jp = jp.compact.join(" ").truncate(100).presence || overview_en
  end

  def destroy_with_published
    PublishedProject.find(id).destroy if PublishedProject.exists?(id)
  end
end
