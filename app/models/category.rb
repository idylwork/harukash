class Category < ApplicationRecord
  has_many :projects
  has_many :published_projects
  has_one :page, dependent: :destroy

  validates :name, presence: true

  attr_reader :has_changed

  before_save :check_changed
  before_destroy :least_one
  after_commit :contents_issue

  private

  def check_changed
    @has_changed = changed?
  end

  def least_one
    if Category.select(:id).count <= 1
      errors.add :base, "カテゴリは最低1つ必要です"
      throw :abort
    end

    first_id = Category.pluck(:id).first
    projects.update(category_id: first_id)
    published_projects.update(category_id: first_id)
  end
end
