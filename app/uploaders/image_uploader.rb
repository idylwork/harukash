class ImageUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "images/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  process resize_to_limit_if_oversize: 1200
  version :thumb do
    process resize_to_limit: [500, 800]
  end

  # リサイズの必要がある場合にはリサイズし、Exif情報を処理する
  def resize_to_limit_if_oversize(limit)
    should_resize = false
    manipulate! do |img|
      # リサイズ
      if img.height > limit || img.width > limit
        # Exif情報の適用と除去
        img.auto_orient
        img.strip

        should_resize = true
      end

      model.is_portrait = (img.height > img.width) if defined? model.is_portrait
      img = yield(img) if block_given?
      img
    end
    resize_to_limit limit, limit if should_resize
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    return unless original_filename.present?
    extension = file.extension.downcase
    extension = "jpg" if extension == "jpeg"
    "#{secure_token}.#{extension}"
  end

  protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) || model.instance_variable_set(var, SecureRandom.uuid)
  end
end
