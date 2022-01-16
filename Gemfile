source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Infrastructure
ruby "2.7.1"
gem "mysql2", ">= 0.4.4", "< 0.6.0"
gem "rails", "~> 5.2.1"
gem "unicorn", "~> 5.4.0"
gem "bootsnap", ">= 1.1.0", require: false
gem "tzinfo-data"

# Rails extensions
gem "dotenv-rails"
gem "rails-i18n"
gem "actionpack-action_caching"

# Application
gem "mini_magick", "~> 4.8"
gem "carrierwave"
# gem 'rmagick'
gem "kaminari"
gem "jbuilder", "~> 2.5"
gem "bcrypt", "~> 3.1.7"

# Frontend
gem "webpacker", ">= 4.0.x"
gem "material_icons"
# gem "sass-rails", "~> 5.0"
# gem "uglifier", ">= 2.7.2"

group :development, :test do
  # Capistrano
  gem "capistrano", "~> 3.10"
  gem "capistrano-rails", "~> 1.3"
  gem "capistrano-rbenv"
  gem "capistrano-bundler"
  gem "capistrano-yarn"
  gem "capistrano3-unicorn"
end

group :development do
  # Debug
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "better_errors"
  gem "binding_of_caller"
  gem "rubocop", require: false
  gem "rails_best_practices"
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5", "< 3.2"

  # Console extensions
  gem "pry-rails"
  gem "pry-byebug"
  gem "pry-doc"
  gem "hirb"
  gem "hirb-unicode"

  # Rails preloader
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :production do
  gem "google-analytics-rails"
end
