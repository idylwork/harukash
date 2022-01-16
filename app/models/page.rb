# ページ採番
# orderはカテゴリ・プロジェクトで別々に振られるため、関連で不整合が出ることはない
# ページ取得時はorderとlimit・offsetでその時点での全件中のページ番号を取る
# フロントページ用に source: :front の空レコードが必要
#
# PublishedProject
# プロジェクト新規公開はコールバックで最後尾に登録されるため更新不要
# 内容更新時はページ数に変化がないため更新不要
# 取り下げ・削除時はdependentで削除されるため、特別な処理は不要
# 公開プロジェクト並べ替え時は更新のあったorder以降をすべて振り直す
#
# Category
# カテゴリ新規登録時は差し込んで登録できるため全件リセット
# 全件完了後に採番する必要があるため、コントローラで操作する (has_changedも使用できない)

class Page < ApplicationRecord
  belongs_to :category, optional: true
  belongs_to :published_project, optional: true

  after_commit :contents_issue

  enum source: { front: 0, category: 1, project: 2 }

  # enum順、order順にページ採番する
  default_scope { order(:source, :order) }

  # ページ番号からPageを取得
  scope :number, lambda { |no|
    limit(1).offset(no - 1).first
  }

  # ページ番号から前後1ページを含むPageのリストを取得
  scope :around, lambda { |no|
    list = if no > 1
             limit(3).offset(no - 2)
           else
             limit(2)
           end
    case list.count
    when 3
      list
    when 2
      if no < 2
        [nil] + list
      else
        list + [nil]
      end
    else
      list.none
    end
  }

  # paramsから正しいページ番号を取得
  def self.no(no)
    no = no.to_i
    no = 1 if no < 1
    no
  end

  # Categoryのページ情報を全件更新する
  def self.categories_renumber
    # 削除されたカテゴリページを削除
    old_ids = Page.category.pluck(:category_id)
    new_ids = Category.pluck(:id)
    where(category_id: old_ids - new_ids).destroy_all

    # 存在するカテゴリのページを更新・作成
    Category.order(:display_id).each do |category|
      page = find_or_initialize_by(id: category.id)
      page.update_attributes(source: :category, order: category.display_id)
    end
  end

  # デバッグ用 ページ情報を全件リセットする
  def self.renumber!
    delete_all
    create(source: :front, order: 0)
    Category.order(:display_id).each do |category|
      create(source: :category, category_id: category.id, order: category.display_id)
    end
    PublishedProject.order(:date).each_with_index do |project, order|
      create(source: :project, published_project_id: project.id, order: order)
    end
  end

  # Project登録時の処理
  def self.update_project(project)
    page = where(published_project_id: project.id)
    page = new if page == []
    page.update(published_project_id: project.id)
  end

  # 表示用にコンテンツ種別・IDのページ索引を生成
  def self.source_index
    index = { front: {}, category: {}, project: {} }
    all.each_with_index do |page, no|
      case page.source
      when "front"
        index[page.source.to_sym][page.order] = no + 1
      when "category"
        index[page.source.to_sym][page.category_id] = no + 1
      when "project"
        index[page.source.to_sym][page.published_project_id] = no + 1
      end
    end
    index
  end

  # 表示用に公開プロジェクトIDのページ索引を生成
  def self.project_source_index
    no = Page.where.not(source: :project).count
    index = {}
    project.each do |page|
      index[page.published_project_id] = no += 1
    end
    index
  end

  # Pageからコンテンツの種類に応じたレコードを取得
  def content
    case source
    when "category"
      category
    when "project"
      published_project
    else
      self
    end
  end
end
