class HeadlinesController < SidedoorController
  layout "sidedoor"
  before_action :set_headline, only: [:show, :edit, :update, :destroy]

  PER = 10

  # GET /headlines
  def index
    @headlines = Headline.all

    # バリデーション違反のレコードを削除
    deleted = []
    @headlines.each do |headline|
      deleted << headline.destroy if headline.invalid?
    end
    if deleted.count > 0
      @headlines = Headline.all
      flash.now[:notice] = "#{deleted.count}件のヘッドラインが整理されました"
    end

    @album = Headline.album
    @json = { headlines: Headline.hash_list, files: @files }.to_json
    @interval = Preference.last.headline_interval
  end

  # GET /headlines/1
  def show
  end

  def sort
    params[:headlines].each do |display_id, id|
      Headline.find(id).update(display_id: display_id)
    end
    redirect_to headlines_path, notice: "並び順を保存しました"
  rescue
    redirect_to headlines_path, notice: "保存に失敗しました"
  end

  # GET /headlines/new
  def new
    @headline = Headline.new(display_id: Headline.new_display_id)
    @json = editor_json_with_headline @headline
    @meta_title = "New Headline"
    render :edit
  end

  # GET /headlines/1/edit
  def edit
    @headline = Headline.find(params[:id])
    @headline = Headline.new if @headline.invalid?
    @json = editor_json_with_headline @headline
    @meta_title = "Headline #{@headline.display_id + 1}"
  end

  def api
    @json = editor_json params[:id]
    render json: @json
  end

  def create
    @headline = Headline.new(headline_params)
    @headline.display_id = Headline.new_display_id

    if @headline.save(@headline)
      redirect_to headlines_path @headline.id, notice: "新規追加しました"
    else
      @json = editor_json_with_headline @headline
      flash.now[:notice] = "保存に失敗しました"
      render :edit
    end
  end

  def update
    if @headline.update(headline_params)
      redirect_to headlines_path, notice: "保存しました"
    else
      @json = editor_json_with_headline @headline
      flash.now[:notice] = "保存に失敗しました"
      render :edit
    end
  end

  # DELETE /headlines/1
  def destroy
    no = Headline.pluck(:id).index(@headline.id).to_i + 1
    @headline.destroy
    redirect_to headlines_url, notice: "#{no}番目のヘッドラインを削除しました"
  end

  private

  def set_headline
    @headline = Headline.find(params[:id])
  end

  def headline_params
    params.require(:headline).permit(:display_id, :source, :published_project_id, :published_block_id, :file, :position_x, :position_y)
  end

  def headline_display_params
    params.require(:headlines)
  end

  def editor_json_with_headline(headline)
    append_json = { headline: headline, file: headline.source_file }
    editor_json 1, append_json
  end

  # PublishedProjectとPublishedBlockの画像をJSONで取得
  def editor_json(page, json = {})
    page = page.to_i
    projects = PublishedProject.select(:id, :file, :date).where.not(file: nil)
    blocks = PublishedBlock.select(:id, :file, :date).where(type: "picture").where.not(file: nil).joins(:published_project)
    images = projects + blocks
    exit if images.nil?
    images.sort! { |a, b| b.date <=> a.date }
    json[:last_page] = (images.count.to_f / PER).ceil
    page = 0 if page < 0
    page = json[:last_page] if page > json[:last_page]
    images = images.slice(PER * (page - 1)..PER * page - 1).to_a

    json[:types] = images.map do |image|
      image.is_a?(PublishedProject) ? "project" : "block"
    end

    json[:images] = images
    json.to_json
  end
end
