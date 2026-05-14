module Google
  class DriveSession
    CONFIG_TEMPLATE_PATH = "google_drive_client_config.json.erb".freeze

    def call
      GoogleDrive::Session.from_service_account_key(StringIO.new(config_json))
    end

    private

    def config_json
      template = File.read(CONFIG_TEMPLATE_PATH)
      parsed = JSON.parse(ERB.new(template).result)
      parsed["private_key"] = parsed["private_key"].gsub('\n', "\n")
      JSON.generate(parsed)
    end
  end
end
