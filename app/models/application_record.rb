class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # ImageUploaderで登録されたアップロードファイルを削除する
  def file_remove
    FileUtils.rm_rf File.dirname(file.path) if file.present?
  end

  # コンテンツの更新を伝搬する (アクションキャッシュの削除)
  def contents_issue
    Preference.last.touch
  end
end
