module Api
  module V1
    class BackupsController < ApplicationController
      skip_before_action :authorize!
      include BackupTokenAuthenticatable

      def create
        files = Backups::DumpAllTables.new.call
        folder = Backups::UploadToGoogleDrive.new.call(files: files)

        render json: {status: "ok", uploaded: files.size, folder: folder}, status: :accepted
      end
    end
  end
end
