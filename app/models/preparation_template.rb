class PreparationTemplate < ApplicationRecord
  has_many :trips, dependent: :nullify

  validates :name, presence: true
  validates :content_html, presence: true

  scope :default_template, -> { where(default: true) }

  after_save :ensure_single_default, if: :default?

  private

  def ensure_single_default
    PreparationTemplate.where(default: true).where.not(id: id).update_all(default: false)
  end
end
