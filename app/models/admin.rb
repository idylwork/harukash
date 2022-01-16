class Admin < ApplicationRecord
  REG_EMAIL_PATTERN = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  has_secure_password validations: true
  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 12 }, allow_nil: true

  validates :level, presence: true
  validates :name, presence: true, uniqueness: true
  validates :email, presence: true, format: { with: REG_EMAIL_PATTERN }

  # ログインセッション登録
  def self.new_remember_token
    SecureRandom.urlsafe_base64
  end

  # セッショントークンの暗号化
  def self.encrypt(token)
    Digest::SHA256.hexdigest(token.to_s)
  end

  # 認証
  def sign_in(password)
    (authenticate(password) if password_digest.present?) || nil
  end
end
