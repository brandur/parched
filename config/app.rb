class App < Configurable # :nodoc:
  # Settings in config/app/* take precedence over those specified here.
  
  # Name to display in the title and elsewhere
  config.name = Rails.application.class.parent.name

  # Location of the Git repository that contains content
  config.repo = 'content'

  # Layout to use (allows the wiki to be themed)
  config.layout = 'miniml'

  # Whether MathJax is sourced in to the wiki (fairly heavy JS/CSS/fonts that 
  # may slow down initial page load)
  config.enable_math = false
end
