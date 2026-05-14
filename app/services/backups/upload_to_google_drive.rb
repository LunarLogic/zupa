module Backups
  class UploadToGoogleDrive
    FOLDER_MIME_TYPE = "application/vnd.google-apps.folder".freeze
    CSV_CONTENT_TYPE = "text/csv".freeze

    def initialize(session_factory: ::Google::DriveSession.new)
      @session_factory = session_factory
    end

    # files: Hash<String filename => String csv content>
    # Returns the name of the created subfolder.
    def call(files:)
      raise ArgumentError, "GOOGLE_DRIVE_BACKUP_FOLDER_ID is not set" if backup_folder_id.to_s.empty?

      session = @session_factory.call
      parent = session.file_by_id(backup_folder_id)
      subfolder_name = "backup_#{Time.now.utc.strftime("%Y-%m-%d_%H%M%S")}_UTC"
      subfolder = parent.create_subcollection(subfolder_name)

      files.each do |filename, content|
        subfolder.upload_from_string(content, filename, content_type: CSV_CONTENT_TYPE)
      end

      subfolder_name
    end

    private

    def backup_folder_id
      ENV["GOOGLE_DRIVE_BACKUP_FOLDER_ID"]
    end
  end
end
