class Book < ApplicationRecord
  KNOWN_GENRES = %w[
    literatura_piękna
    kryminał
    fantasy
    biografia
    dla_dzieci
    popularnonaukowa
    poezja
    inne
  ].freeze

  GENRE_COLORS = {
    "literatura_piękna" => "#006653",
    "kryminał" => "#c4362c",
    "fantasy" => "#5b3f8a",
    "biografia" => "#c0b190",
    "dla_dzieci" => "#fdd051",
    "popularnonaukowa" => "#2e5894",
    "poezja" => "#a0507c",
    "inne" => "#585858"
  }.freeze

  DEFAULT_GENRE_COLOR = "#b9b9b9"

  enum status: {available: 0, in_package: 1, archived: 2}

  has_one_attached :cover_photo

  validates :title, presence: true
  validates :author, presence: true
  validates :qr_code, uniqueness: true, allow_nil: true

  scope :by_query, ->(q) { q.present? ? where("title ILIKE ? OR author ILIKE ?", "%#{q}%", "%#{q}%") : all }
  scope :by_genre, ->(g) { g.present? ? where("? = ANY(genres)", g) : all }

  def self.genre_color(name)
    GENRE_COLORS.fetch(name, DEFAULT_GENRE_COLOR)
  end
end
