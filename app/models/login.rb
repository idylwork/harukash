class Login < ApplicationRecord
  before_save :encrypt_password
  belongs_to :admin, optional: true

  SECURE = Rails.application.credentials.secure
  CIPHER = Rails.application.credentials.cipher
  WAIT_SHORT = 20.seconds.ago
  COUNT_SHORT = 15
  WAIT_LONG = 6.hours.ago
  COUNT_LONG = 20

  @@request = Thread.current[:request]

  # 同一IPからのログイン失敗を抽出
  scope :failure, lambda {
    where(ip: @@request&.remote_ip, admin_id: nil)
  }

  # ログインチェック・同一IPからの連続ログイン試行制限
  def self.error_message(name, password)
    if name.empty?
      render_enter "ログイン名を入力してください"
    elsif password.empty?
      "パスワードを入力してください"
    elsif restrict_long
      "連続ログイン制限がかかっています"
    elsif restrict_short
      "しばらく間をあけて再度お試しください"
    end
  end

  # 短時間に連続ログイン
  def self.restrict_short
    failure.where(created_at: WAIT_SHORT..Float::INFINITY).count >= COUNT_SHORT
  end

  def self.restrict_long
    failure.where(created_at: WAIT_LONG..Float::INFINITY).count >= COUNT_LONG
  end

  # パスワード暗号化
  def encrypt_password
    if @@request
      self.ip = @@request.remote_ip
      self.language = @@request.env["HTTP_ACCEPT_LANGUAGE"]
      self.user_agent = @@request.env["HTTP_USER_AGENT"]
    end
    self.password = encrypt(password)
  end

  # パスワード複合化
  def decrypt_password
    self.password = decrypt(password)
  end

  # パスワードを複合化してログを出力
  def self.log
    select(:id, :name, :password, :ip, :language, :user_agent, :created_at).order(id: :desc).map do |login|
      login.decrypt_password
      login
    end
  end

  private

  # 暗号化
  def encrypt(password)
    crypt = ActiveSupport::MessageEncryptor.new(SECURE, CIPHER)
    crypt.encrypt_and_sign(password)
  end

  # 復号化
  def decrypt(password)
    crypt = ActiveSupport::MessageEncryptor.new(SECURE, CIPHER)
    crypt.decrypt_and_verify(password)
  end
end
