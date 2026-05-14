module BackupTokenAuthenticatable
  extend ActiveSupport::Concern

  HEADER = "X-Backup-Token".freeze

  included do
    before_action :authorize_backup_token!
  end

  private

  def authorize_backup_token!
    expected = ENV["BACKUP_API_TOKEN"].to_s

    if expected.empty?
      render json: {error: "backup endpoint disabled"}, status: :service_unavailable
      return
    end

    provided = request.headers[HEADER].to_s

    unless provided.bytesize == expected.bytesize &&
        ActiveSupport::SecurityUtils.secure_compare(provided, expected)
      render json: {error: "unauthorized"}, status: :unauthorized
    end
  end
end
