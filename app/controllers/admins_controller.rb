class AdminsController < SidedoorController
  layout "sidedoor"
  skip_before_action :require_sign_in!, only: [:enter, :unlock]
  before_action :root_only, only: [:index, :new, :create]
  before_action :set_admin, only: [:show, :edit, :update, :destroy]
  before_action :set_session, only: [:unlock]

  # ログイン画面 (リダイレクト判定なし)
  def enter
    return redirect_to projects_path if signed_in?
    render_enter
  end

  # ログイン (リダイレクト判定なし)
  def unlock
    error = Login.error_message session_params[:name], session_params[:password]
    render_enter if error

    if @admin.sign_in(session_params[:password])
      sign_in @admin # SidedoorController
      Login.create(admin_id: @admin.id, name: @admin.name, password: session_params[:password])
      redirect_to projects_path
    else
      Login.create(name: @admin.name, password: session_params[:password])
      render_enter "ログインに失敗しました"
    end
  end

  # ログアウト
  def leave
    sign_out # SidedoorController
    redirect_to enter_sidedoor_path
  end

  # 管理者一覧
  def index
    @admins = Admin.all
  end

  # 管理者追加
  def new
    @admin = Admin.new
  end

  # 管理者編集
  def edit
  end

  # POST /admins
  def create
    @admin = Admin.new(admin_params)
    if @admin.save
      redirect_to admins_path, notice: "#{@admin.name}を追加しました"
    else
      flash.now[:notice] = "保存に失敗しました"
      render :edit
    end
  end

  # PATCH/PUT /admins/1
  def update
    if @admin.update(admin_params)
      redirect_to admins_path, notice: "#{@admin.name}を更新しました"
    else
      flash.now[:notice] = "保存に失敗しました"
      render :edit
    end
  end

  # DELETE /admins/1
  def destroy
    if @admin.id == @current_admin.id
      notice = "#{@admin.name}はログイン中のユーザーです"
    else
      notice = "#{@admin.name}を削除しました"
      @admin.destroy
    end
    redirect_to admins_path, notice: notice
  end

  private

  def redirect_unpermitted
    redirect_to edit_admin_path(@current_admin)
  end

  def modifiable_id?
    root? || (params[:id] == @current_admin.id.to_s)
  end

  def root_only
    redirect_unpermitted unless root?
  end

  def set_admin
    redirect_unpermitted unless modifiable_id?
    @admin = Admin.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def admin_params
    if root?
      params.require(:admin).permit(:name, :level, :email, :sendmail, :password, :password_confirmation)
    else
      params.require(:admin).permit(:name, :email, :sendmail, :password, :password_confirmation)
    end
  end

  # ログイントークンの取得
  def set_session
    @admin = Admin.find_by(name: session_params[:name]) || Admin.new(name: session_params[:name])
  end

  # ログイン画面を表示
  def render_enter(notice = nil)
    @page_num = 0
    flash.now[:notice] = notice.presence
    render action: "enter", layout: "application"
  end

  # 許可するパラメータ
  def session_params
    params.require(:admin).permit(:name, :password)
  end
end
