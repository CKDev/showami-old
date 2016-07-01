# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  if Rails.env.production? || Rails.env.staging?
    storage :fog
  else
    storage :file
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    ActionController::Base.helpers.asset_path("avatar/" + [version_name, "avatar.png"].compact.join("_"))
  end

  # Create different versions of your uploaded files:
  version :small do
    process :auto_orient
    process resize_to_fit: [200, 100_000] # Only scale width, height can remain to keep ratio.
  end

  version :mini do
    process :auto_orient
    process resize_to_fit: [100, 100_000] # Only scale width, height can remain to keep ratio.
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "avatar.jpg" if original_filename
  end

  # Respect the rotation of the image (otherwise image can be flipped 90 degrees)
  def auto_orient
    manipulate!(&:auto_orient)
  end

end
