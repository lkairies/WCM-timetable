# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w( bootstrap-table-filter.css )
Rails.application.config.assets.precompile += %w( bootstrap-table.min.css )

Rails.application.config.assets.precompile += %w( bootstrap-table-filter.js )
Rails.application.config.assets.precompile += %w( bs-table.js )
Rails.application.config.assets.precompile += %w( bootstrap-table.min.js )
Rails.application.config.assets.precompile += %w( bootstrap-table-filter.min.js )

