module Auth
  class Authorize
    def call(request)
      header = request.headers["Authorization"]
      header = header.split(" ").last if header
      begin
        decoded_token = Auth::JsonWebToken.decode(header)

        if decoded_token[:admin_preview]
          return false unless decoded_token[:trip_id]
          return AdminPreview.new(trip_id: decoded_token[:trip_id])
        end

        if code_valid?(decoded_token[:auth_code])
          decoded_token[:user_name]
        end
      rescue JWT::DecodeError
        false
      end
    end

    def code_valid?(auth_code)
      Auth::EntryCode.valid?(auth_code, Time.zone.now)
    end
  end
end
