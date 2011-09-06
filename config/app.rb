class App < Configurable # :nodoc:
  # Settings in config/app/* take precedence over those specified here.
  
  # Name to display in the title and elsewhere
  config.name = Rails.application.class.parent.name

  # Location of the Git repository that contains content
  config.repo = 'content'

  # Layout to use (allows the wiki to be themed)
  config.layout = 'miniml'

  # Syntax highlighting theme, if it's custom, the extra CSS to support it 
  # must be copied to app/assets/stylesheets (and assets recompiled in 
  # production)
  config.syntax_theme = 'balupton'

  # Whether MathJax is sourced in to the wiki (fairly heavy JS/CSS/fonts that 
  # may slow down initial page load)
  config.enable_math = false
end
