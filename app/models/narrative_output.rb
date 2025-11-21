# frozen_string_literal: true

# Stores narrative text output in terminal sessions
class NarrativeOutput < ApplicationRecord
  # Relationships
  belongs_to :terminal_session

  # Callbacks
  before_save :render_markdown

  # Validations
  validates :content, presence: true
  validates :content_type, inclusion: { in: %w[narrative system error roll dialogue user player dm] }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(content_type: type) }

  # Content types
  CONTENT_TYPES = {
    narrative: 'Story narration',
    system: 'System message',
    error: 'Error message',
    roll: 'Dice roll',
    dialogue: 'NPC dialogue',
    user: 'Player input',
    player: 'Player message',
    dm: 'Dungeon Master response'
  }.freeze

  # Render content with clickable elements
  def rendered_content
    return rendered_html if rendered_html.present?

    result = content
    clickable_elements.each do |element|
      pattern = /\[#{Regexp.escape(element['text'])}\]/
      replacement = build_clickable_span(element)
      result = result.gsub(pattern, replacement)
    end

    result
  end

  private

  def build_clickable_span(element)
    %{<span class="clickable" data-type="#{element['type']}" data-target-id="#{element['id']}" data-action-type="#{element['action']}">#{element['text']}</span>}
  end

  def render_markdown
    return if content.blank? || rendered_html.present?

    # Configure markdown renderer with HTML output
    renderer = Redcarpet::Render::HTML.new(
      filter_html: false,
      no_styles: true,
      safe_links_only: true,
      hard_wrap: true  # Convert newlines to <br> tags
    )

    # Configure markdown parser with features
    markdown = Redcarpet::Markdown.new(renderer,
      autolink: true,
      space_after_headers: true,
      fenced_code_blocks: true,
      no_intra_emphasis: true,
      strikethrough: true,
      superscript: true
    )

    # Render markdown to HTML
    html = markdown.render(content)

    # Sanitize HTML to prevent XSS attacks
    self.rendered_html = ActionController::Base.helpers.sanitize(html,
      tags: %w[p br strong em u s del strike b i hr blockquote pre code ul ol li a img h1 h2 h3 h4 h5 h6],
      attributes: %w[href src alt title]
    )
  end
end
