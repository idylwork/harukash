class SidedoorController < ApplicationController
  before_action :set_request
  before_action :set_current_admin
  before_action :require_sign_in!
  helper_method :signed_in?

  protect_from_forgery with: :exception

  def set_request
    Thread.current[:request] = request
  end

  # ログインセッション登録
  def sign_in(admin)
    remember_token = Admin.new_remember_token
    cookies.permanent[:admin_remember_token] = remember_token
    admin.update!(remember_token: Admin.encrypt(remember_token))
    @current_admin = admin
  end

  # ログイントークン破棄
  def sign_out
    cookies.delete(:admin_remember_token)
  end

  # ロード時ログインセッションを格納
  def set_current_admin
    remember_token = Admin.encrypt(cookies[:admin_remember_token])
    @current_admin ||= Admin.find_by(remember_token: remember_token)
  end

  # ログイン状態を取得
  def signed_in?
    @current_admin.present?
  end

  # システム管理者権限
  def root?
    @current_admin.try(:level) == "root"
  end

  # サイトオーナー権限
  def owner?
    @current_admin.try(:level) == "owner" || @current_admin.level == "root"
  end

  # ヘルプの表示切り替え
  def help_api
    show_help = params[:show] == "show"
    @current_admin.update_column(:show_help, show_help)
    render json: { show_help: show_help }
  end

  private

  # 管理ユーザー編集
  def session_action
    action_name == "enter" || action_name == "unlock" || action_name == "leave"
  end

  # ログインしていなければリダイレクト
  def require_sign_in!
    if signed_in?
      case controller_name
      when "admins"
        redirect_to preference_path unless session_action || owner?
      when "contacts"
        redirect_to projects_path unless owner?
      when "preferences"
        redirect_to projects_path unless owner?
      end
    elsif controller_name != "admins"
      redirect_to enter_sidedoor_path
    end
  end
end
