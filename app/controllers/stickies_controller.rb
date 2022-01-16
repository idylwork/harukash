class StickiesController < SidedoorController
  layout "sidedoor"

  def edit
    require "nokogiri"

    sticky = Sticky.first
    preference = Preference.last

    @json = {
      nodes: {
        en: parse_from_html(sticky.html_en),
        jp: parse_from_html(sticky.html_jp)
      },
      color_txt: sticky.color_txt,
      color_bg_start: sticky.color_bg_start,
      color_bg_end: sticky.color_bg_end,
      image_url: sticky.file.url,
      locale: preference.preview_locale_jp ? "jp" : "en"
    }.to_json

    @json_date = {
      start: sticky.start_at,
      end: sticky.end_at
    }.to_json
    @is_visible = sticky.is_visible
  end

  def update
    require "nokogiri"

    @sticky = Sticky.first
    processes = sticky_params
    processes[:html_en] = reconstruct_html(processes[:html_en])
    processes[:html_jp] = reconstruct_html(processes[:html_jp])

    if @sticky.update(processes)
      redirect_to sticky_path, notice: "付箋を更新しました"
    else
      flash.now[:notice] = "保存に失敗しました"
      render :edit
    end
  end

  private

  # HTMLソースを配列にパース
  def parse_from_html(source)
    html = Nokogiri::HTML.parse(source)
    html.xpath("//body/*").map do |el|
      next if el.text.blank? && el.name != "img"
      node = {
        text: el.text.delete("\n"),
        tag: el.name,
        attr: nil,
        value: "https://",
        margin: 0
      }

      case el.name
      when "p"
        if el.child&.name == "a"
          node[:tag] = "a"
          node[:attr] = "href"
          node[:value] = el.child&.attribute("href")&.value
        end
      when "img"
        node[:attr] = "src"
        node[:value] = Sticky.image.url
      end

      el.classes.each do |class_name|
        node[:margin] = class_name.slice(-1).to_i if class_name.start_with? "sticky-margin-"
      end
      node
    end.compact
  end

  # HTMLソースを一度配列に分解して再構築
  def reconstruct_html(source)
    html = ""
    nodes = parse_from_html source
    nodes.each do |node|
      classes = {
        h2: "sticky-heading",
        p: "sticky-text",
        a: "sticky-link",
        img: "sticky-image",
        margin: [
          "sticky-margin-0",
          "sticky-margin-1",
          "sticky-margin-2",
          "sticky-margin-3"
        ]
      }

      next unless classes[node[:tag].to_sym].is_a?(String)
      class_list = [
        classes[node[:tag].to_sym],
        classes[:margin][node[:margin]]
      ]

      # innerTextとvalueのエスケープ
      node[:text] = view_context.sanitize(node[:text])
      node[:value] = view_context.sanitize(node[:value])

      el = case node[:tag]
           when "p", "h2"
             %(<#{node[:tag]} class="#{class_list.join(' ')}">)
           when "a"
             %(<p class="#{class_list.join(' ')}"><a href="#{node[:value]}" target="_blank">)
           when "img"
             %(<img src="">)
           end
      if node[:tag] != "img"
        el += node[:text]
        el += "</#{node[:tag]}>"
        el += "</p>" if node[:tag] == "a"
      end
      html += "#{el}\n"
    end
    html
  end

  # Strong Parameters: Sticky
  def sticky_params
    params.require(:sticky).permit(
      :html_en, :html_jp, :color_txt,
      :color_bg_start, :color_bg_end, :file, :file_cache,
      :start_at, :end_at, :is_visible
    )
  end
end
