class PublishedProjectsController < ApplicationController
  layout "portfolio"
  before_action :associate, only: [:show, :locale]
  caches_action :show, if: -> { @cache }, cache_path: ->(c) { create_cache_path(c, @preference) }

  def show
    # カテゴリごとのページ索引
    @index = Page.source_index
    # ページ番号
    @page_no = Page.no(params[:page])

    # 前後ページを含むコンテンツ情報
    pages = Page.around(@page_no)
    return redirect_to root_path if pages.blank?

    case pages[1].source
    when "front"
      @album = Headline.album
      @last_issue = PublishedProject.last_issue.strftime("%B %Y")
      @categories = Category.includes(:published_projects).order(:display_id)
      @menu_deley = 0.3
      @meta_image = @album.first.try(:[], :url)
      render :index
    when "category"
      @category = pages[1].content
      @projects = @category.published_projects.order(date: "DESC")
      @around = { "prev": pages.first, "next": pages.last }.compact
      @meta_title = @category.name
      @meta_image = Headline.first&.file&.url
      render :category
    when "project"
      @project = pages[1].content
      @blocks = @project.published_blocks
      @roles = @project.published_roles
      @around = { "prev": pages.first, "next": pages.last }.compact
      @meta_title = @project.title
      @meta_image = @project.file&.url
      render :show
    end
  end

  # 言語設定を入れ替える
  def locale
    I18n.locale = (params[:locale] == "ja") ? :ja : :en
    cookies[:locale] = I18n.locale

    # flashメッセージをキャッシュしない
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"

    redirect_to root_path, notice: t("messages.locale")
  end

  def contact
    @contact = Contact.new(contact_params)

    begin
      raise if params[:is_valudated]

      # 送信待ち時間
      interval = Time.current - Time.at(params[:accessed_at].to_i)
      minInterval = @contact.body =~ /https?:\/\// ? 60 : 10
      maxInterval = 24 * 60 * 60
      raise ApplicationError::InvalidContactError if interval < minInterval || maxInterval < interval

      # データベース登録
      @contact.save

      # 通知メール送信
      begin
        emails = Admin.where(sendmail: true).pluck(:email)
        ContactMailer.forward(@contact, emails).deliver if emails.present?
      rescue
        raise ApplicationError::NotificationError
      end
      notice = t("messages.contacts.success")
    rescue ApplicationError::InvalidContactError => e
      notice = t("messages.contacts.database_error")
    rescue ActiveRecord::ActiveRecordError => e
      logger.error e
      notice = t("messages.contacts.database_error")
    rescue ApplicationError::NotificationError => e
      logger.error e
      notice = t("messages.contacts.sending_error")
    rescue => e
      logger.error e
      notice = t("messages.contacts.database_error")
    end

    redirect_to root_path, notice: notice
  end

  private

  # キャッシュ判定前
  def associate
    I18n.locale = user_language_ja ? :ja : :en
    @preference = Preference.last
    render_error 500 if @preference.under_construction
    @sticky = Sticky.fetch if params[:page].to_i <= 1
  end

  # ActionCache: Create path
  def create_cache_path(controller, model = nil)
    path = ActionController::Caching::Actions::ActionCachePath.new(controller).path
    path += ":#{I18n.locale}"
    path += ":#{model.updated_at&.strftime('%Y%m%d-%H%M%S')}" if model.present?
    path += ":sticky" if @sticky
    path
  end

  # 日本語を表示可能なアクセスかどうか
  def user_language_ja
    if cookies[:locale]
      cookies[:locale] == "ja"
    else
      language = request.env["HTTP_ACCEPT_LANGUAGE"]
      language && language.casecmp("ja-jp") == 0
    end
  end

  # Storong params: PublishedProject
  def published_project_params
    params.fetch(:published_project, {})
  end

  # Strong params: Contect
  def contact_params
    params.require(:contact).permit(:name, :email, :body)
  end
end
