module Auth
  class EntryCode
    def self.valid?(code, current_time = Time.zone.now)
      codes = AuthCode.where(value: code)
      codes.any? { |code|
        code.expires_at.utc > current_time
      }
    end
  end
end
