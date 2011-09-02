class App < Configurable # :nodoc:
  # Settings in config/app/* take precedence over those specified here.
  
  # Name to display in the title and elsewhere
  config.name = Rails.application.class.parent.name

  # Location of the Git repository that contains content
  config.repo = 'content'
end
