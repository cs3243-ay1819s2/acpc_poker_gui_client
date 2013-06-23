require 'acpc_poker_types'

# General controller/view helpers for this application.
module ApplicationHelper
  APP_NAME = 'ACPC Poker GUI Client' unless const_defined? :APP_NAME
  ADMINISTRATOR_EMAIL = 'morrill@ualberta.ca' unless const_defined? :ADMINISTRATOR_EMAIL

  NEW_MATCH_PARTIAL = 'match_start/index' unless const_defined? :NEW_MATCH_PARTIAL
  FOOTER = 'match_start/footer' unless const_defined? :FOOTER
  REPLACE_CONTENTS_JS = 'shared/replace_contents' unless const_defined? :REPLACE_CONTENTS_JS

  def match_lifespan() 1.month end

  def wait_for_match_to_start_partial() 'match_start/wait_for_match_to_start' end

  # Renders a shared +JavaScript+ template that replaces the old contents
  # of the current page with new contents.  In essence, it acts like a
  # page refresh.
  # @param [String] replacement_partial The partial with which the page should be replaced.
  # @param [String] alert_message An alert message to be displayed.
  def replace_page_contents(replacement_partial, alert_message=nil)
    @alert_message = alert_message
    @replacement_partial = replacement_partial
    respond_to do |format|
      format.js do
        render REPLACE_CONTENTS_JS, formats: [:js]
      end
    end
  end

  def reset_to_match_entry_view(error_message=nil)
    @match = Match.new
    replace_page_contents NEW_MATCH_PARTIAL, error_message
  end

  def link_with_glyph(link_text, link_target, glyph, options={})
    link_to link_target, options do
      inserted_html = "#{content_tag(:i, nil, class: 'icon-' << glyph)} #{link_text}".html_safe
      inserted_html << yield if block_given?
      inserted_html
    end
  end
end