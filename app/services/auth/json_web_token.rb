module Auth
  class JsonWebToken
    SECRET_KEY = Rails.application.secrets.secret_key_base.to_s
    TOKEN_VALID_PERIOD = 4.hours

    def self.encode(payload, exp = Time.zone.now + TOKEN_VALID_PERIOD)
      payload[:exp] = exp.to_i
      JWT.encode(payload, SECRET_KEY)
    end

    def self.decode(token)
      decoded = JWT.decode(token, SECRET_KEY)[0]
      HashWithIndifferentAccess.new decoded
    end
  end
end
