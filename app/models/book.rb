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

  COVER_PHOTO_CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze
  COVER_PHOTO_MAX_SIZE = 5.megabytes

  enum status: {available: "available", packed: "packed", borrowed: "borrowed", archived: "archived"}

  has_one_attached :cover_photo

  validates :title, presence: true
  validates :author, presence: true
  validates :qr_code, uniqueness: true, allow_nil: true
  validate :acceptable_cover_photo

  scope :by_query, ->(q) {
    if q.blank?
      all
    else
      pattern = "%#{sanitize_sql_like(q)}%"
      where("title ILIKE ? OR author ILIKE ?", pattern, pattern)
    end
  }
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

  private

  def acceptable_cover_photo
    return unless cover_photo.attached?

    blob = cover_photo.blob

    unless COVER_PHOTO_CONTENT_TYPES.include?(blob.content_type)
      errors.add(:cover_photo, :invalid_content_type, allowed: COVER_PHOTO_CONTENT_TYPES.join(", "))
    end

    if blob.byte_size > COVER_PHOTO_MAX_SIZE
      errors.add(:cover_photo, :too_large, max: ActiveSupport::NumberHelper.number_to_human_size(COVER_PHOTO_MAX_SIZE))
    end
  end
end
