class PreferencesController < SidedoorController
  layout "sidedoor"
  before_action :set_preference, only: [:edit, :update]

  # GET /preferences/1/edit
  def edit
    @images_size = dir_size Rails.root.join("public", "images")
  end

  # PATCH/PUT /preferences/1
  def update
    errors = ActiveModel::Errors.new(Category)

    Preference.transaction do
      changed = false

      @preference.assign_attributes(preference_params)
      @preference.headline_interval *= 100 # 金額を10円単位で丸める
      @preference.save
      category_params[:categories_attributes].each do |_key, attributes|
        id = attributes.delete(:id)

        if Category.exists?(id)
          category = Category.find(id)
          if attributes[:_destroy]
            category.destroy
            changed = true
          else
            category.update(attributes)
            changed ||= category.has_changed
          end
        else
          category = Category.create(attributes)
          category.save
          changed = true
        end
        errors.merge!(category.errors) if category.errors.any?
      end
      fail if errors.any?
      Page.renumber! if changed
    end
    redirect_to preference_path, notice: "保存しました"
  rescue
    @preference.errors.merge!(errors)
    flash.now[:notice] = "保存に失敗しました"
    @categories = category_params[:categories_attributes].values
    render :index
  end

  private

  def set_preference
    @preference = Preference.last
    @categories = Category.select(:id, :name).order(:display_id).all
  end

  # ディレクトリのファイルサイズを取得
  def dir_size(path)
    expath = File.expand_path(path)
    sum = 0
    Dir.glob("#{expath}/**/*") do |fn|
      sum += File.stat(fn).size
    end
    sum
  end

  # Strong Parameters: Preference
  def preference_params
    params.require(:preference).permit(
      :profile_en, :profile_jp, :role_default_name,
      :role_default_person, :projects_display_count, :preview_locale_jp,
      :under_construction, :default_color_edge, :headline_interval
    )
  end

  # Strong Parameters: Category
  def category_params
    params.require(:category).permit(
      categories_attributes: [:display_id, :name, :id, :_destroy]
    )
  end
end
