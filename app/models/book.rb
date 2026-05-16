class Book < ApplicationRecord
  KNOWN_GENRES = %w[
    literatura_piekna
    kryminal
    fantasy
    biografia
    dla_dzieci
    popularnonaukowa
    poezja
    inne
  ].freeze

  GENRE_COLORS = {
    "literatura_piekna" => "#006653",
    "kryminal" => "#c4362c",
    "fantasy" => "#5b3f8a",
    "biografia" => "#c0b190",
    "dla_dzieci" => "#fdd051",
    "popularnonaukowa" => "#2e5894",
    "poezja" => "#a0507c",
    "inne" => "#585858"
  }.freeze

  DEFAULT_GENRE_COLOR = "#b9b9b9"

  enum status: {available: 0, packed: 1, borrowed: 2, archived: 3}

  has_one_attached :cover_photo

  validates :title, presence: true
  validates :author, presence: true
  validates :qr_code, uniqueness: true, allow_nil: true

  scope :by_query, ->(q) { q.present? ? where("title ILIKE ? OR author ILIKE ?", "%#{q}%", "%#{q}%") : all }
  scope :by_genre, ->(g) { g.present? ? where("? = ANY(genres)", g) : all }

  # Trestle's `select multiple` posts an empty "" when nothing is selected.
  # Drop blanks before persisting so the array never contains junk that
  # would blow up I18n lookups or downstream filters.
  def genres=(values)
    super(Array(values).map(&:to_s).reject(&:blank?))
  end

  def self.genre_color(name)
    GENRE_COLORS.fetch(name, DEFAULT_GENRE_COLOR)
  end

  def self.genre_label(slug)
    return slug.to_s.humanize if slug.blank?
    I18n.t("book_genres.#{slug}", default: slug.to_s.humanize)
  end
end
