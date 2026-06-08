module Auth
  class EntryCode
    def self.valid?(code, current_time = Time.zone.now)
      codes = AuthCode.where(value: code)
      codes.any? { |code|
        (code.valid_from.nil? || code.valid_from.utc <= current_time) &&
          code.expires_at.utc > current_time
      }
    end
  end
end
