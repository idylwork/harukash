class ProjectsController < SidedoorController
  layout "sidedoor"
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    @projects = Project.includes(:category, published_project: [:page]).order("published_projects.id IS NULL DESC", "pages.order DESC", date: :desc)
    @index = Page.project_source_index
  end

  def show
    @page_no = 0
    @project = Project.find_by_id(params[:id])
    @blocks = @project.blocks
    @roles = @project.roles
    @meta_title = "[Preview] " + @project.title
    flash.now[:notice] = "Preview Mode"
    render template: "published_projects/show", layout: "portfolio"
  end

  def new
    @preference = Preference.last
    @project = Project.new(
      category_id: 1,
      color_txt: '#000000',
      color_bg: "transparent",
      color_edge: @preference.default_color_edge,
      date: Date.today,
      is_visible: true
    )
    @blocks = []
    @roles = []
    set_props
    render "edit"
  end

  def edit
    @project = Project.find(params[:id])
    @blocks = @project.blocks.order(:display_id)
    @roles = @project.roles.order(:display_id)
    @is_issued = PublishedProject.exists?(params[:id])
    @meta_title = @project.title
    set_props

    @file_size = @project.file.size
    @blocks.each do |block|
      @file_size += block.file.size
    end
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      if params[:button] == "issue"
        if publish_project
          redirect_to projects_path, notice: "#{@project.title}を公開しました"
        else
          set_cache
          flash.now[:notice] = "公開に失敗しました"
          render :edit
        end
      else
        redirect_to edit_project_path(id: @project.id), notice: "新規に保存しました"
      end
    else
      set_cache
      flash.now[:notice] = "エラーが発生しました"
      render :edit
    end
  end

  def update
    @project.touch # Blockのみの更新でもUpdateする
    if @project.update(project_params)
      if params[:button] == "issue"
        if publish_project
          redirect_to projects_path, notice: "#{@project.title}を公開しました"
        else
          set_cache
          flash.now[:notice] = "公開に失敗しました"
          render :edit
        end
      else
        redirect_to edit_project_path, notice: "保存しました"
      end
    else
      set_cache
      flash.now[:notice] = "エラーが発生しました"
      render :edit
    end
  end

  def recall
    PublishedProject.find(params[:id]).destroy
    redirect_to edit_project_path, notice: "非公開にしました"
  end

  def destroy
    @project.destroy
    redirect_to projects_url, notice: "プロジェクトは削除されました。"
  end

  def batch
    @json = Page.project.reorder(order: :DESC).includes(:published_project, :category).map.with_index do |page, order|
      {
        id: page.published_project_id,
        title: page.published_project.title,
        category: page.published_project.category.name,
        overview: page.published_project.overview_jp,
        order: order # 逆順にして渡す
      }
    end.to_json
  end

  def batch_update
    old_orders = Page.project.pluck(:published_project_id, :order).to_h
    last_order = old_orders.count - 1

    projects_params[:projects_attributes].each do |key, project|
      order = last_order - key.to_i # 逆順にして保存
      if order != old_orders[project[:id]]
        page = Page.find_by(published_project_id: project[:id])
        page.update(order: order)
      end
    end

    redirect_to batch_projects_path, notice: "保存しました"
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def set_props
    if @roles.none?
      preference = Preference.last
      @roles = [@project.roles.new(name: preference.role_default_name, person: preference.role_default_person)]
    end
    @categories = Category.select(:id, :name).order(:display_id).all
    @category_names = Category.pluck(:id, :name).to_h
  end

  # POSTされたparamsをVue用のデータに再整形
  def set_cache
    @cache = { block_new_id: 0, trash: [] }

    # 新規でないidの型が数値
    if params[:project][:roles_attributes]
      @roles = params[:project][:roles_attributes].values.map do |i|
        i[:id] = i [:id].to_i if i[:id].to_i.to_s == i[:id]
        next i
      end
      @roles = @roles.compact
    else
      @roles = []
    end

    # 新規でないidの型が数値で、削除済みはtrashへ分離し、Vue側で復活不可に
    # ファイルアップローダが空の場合{url: null}に
    @cache[:block_new_id] = 0
    if params[:project][:blocks_attributes]
      @blocks = params[:project][:blocks_attributes].values.map do |i|
        if i[:_destroy]
          if i["id"].to_i.to_s == i[:id]
            i[:id] = i[:id].to_i
            i[:type] = nil
            @cache[:trash] << i
          end
          next nil
        else
          i[:id] = (i[:id].to_i.to_s == i[:id]) ? i[:id].to_i : "new_#{@cache[:block_new_id] += 1}"
          i[:file] ||= { url: nil } if i[:type] == "picture"
          next i
        end
      end
      @blocks = @blocks.compact
    else
      @blocks = []
    end

    @cache = @cache.to_json
    set_props
  end

  # プロジェクトを公開テーブルに複製する
  def publish_project
    pub_project = PublishedProject.find_or_initialize_by(id: @project.id)
    pub_project.attributes = @project.attributes
    pub_project.file = @project.file

    pub_project.published_roles = @project.roles.map do |role|
      pub_role = pub_project.published_roles.find_or_initialize_by(id: role.id)
      attr = role.attributes
      attr.delete("project_id")
      pub_role.attributes = attr
      pub_role
    end

    pub_project.published_blocks = @project.blocks.map do |block|
      pub_block = pub_project.published_blocks.find_or_initialize_by(id: block.id)
      attr = block.attributes
      attr.delete("project_id")
      attr[:file] = block.file
      pub_block.attributes = attr
      pub_block
    end

    pub_project.save
  end

  def project_params
    params.require(:project).permit(
      :title, :category_id,
      :date, :color_txt, :color_bg, :color_edge, :file, :file_cache, :is_visible,
      roles_attributes: [
        :display_id, :name, :person, :_destroy, :id
      ],
      blocks_attributes: [
        :display_id, :type, :text_en, :text_jp, :color_txt, :color_bg, :file, :file_cache, :is_visible, :option, :_destroy, :id
      ]
    )
  end

  def projects_params
    params.require(:project).permit(
      projects_attributes: [:id, :order]
    )
  end
end
