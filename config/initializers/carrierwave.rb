CarrierWave.configure do |config|
  config.root = Rails.public_path
  config.cache_dir = "#{Rails.root}/tmp/uploads"
end

# config.root = Rails.root
# config.cache_dir = "#{Rails.root}/tmp/uploads"
