class AuthCode < ApplicationRecord
  belongs_to :trip, optional: true

  DEFAULT_EXPIRY_TIME = 1.day
  after_initialize :set_default_expires_at
  validates :value, length: {minimum: 4}
  validates :expires_at, presence: true

  def set_default_expires_at
    self.expires_at ||= Time.zone.now + DEFAULT_EXPIRY_TIME
  end
end
