class Preference < ApplicationRecord
  def profile
    I18n.locale == :ja ? profile_jp : profile_en
  end

  def owner_name
    I18n.locale == :ja ? ENV["SITE_OWNER_JA"] : ENV["SITE_OWNER"]
  end
end
