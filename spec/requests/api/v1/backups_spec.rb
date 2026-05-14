require "rails_helper"

RSpec.describe "POST /api/v1/backup", type: :request do
  let(:valid_token) { "test-backup-token-#{SecureRandom.hex(4)}" }
  let(:files) { {"people.csv" => "id\n1\n", "locations.csv" => "id\n1\n"} }

  before do
    allow_any_instance_of(Backups::DumpAllTables).to receive(:call).and_return(files)
    allow_any_instance_of(Backups::UploadToGoogleDrive)
      .to receive(:call).with(files: files).and_return("backup_2026-05-14_120000_UTC")
  end

  context "when BACKUP_API_TOKEN is not set" do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("BACKUP_API_TOKEN").and_return(nil)
    end

    it "returns 503 even with a header" do
      post "/api/v1/backup", headers: {"X-Backup-Token" => "anything"}
      expect(response).to have_http_status(:service_unavailable)
    end
  end

  context "when BACKUP_API_TOKEN is set" do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("BACKUP_API_TOKEN").and_return(valid_token)
    end

    it "rejects requests missing the token header" do
      post "/api/v1/backup"
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects requests with the wrong token" do
      post "/api/v1/backup", headers: {"X-Backup-Token" => "nope"}
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects requests authenticated with a JWT instead of the backup token" do
      jwt = Auth::JsonWebToken.encode({user_id: 1}, Time.zone.now + 1.hour)
      post "/api/v1/backup", headers: {"Authorization" => "Bearer #{jwt}"}
      expect(response).to have_http_status(:unauthorized)
    end

    it "accepts requests with the correct token and returns 202 with summary" do
      post "/api/v1/backup", headers: {"X-Backup-Token" => valid_token}

      expect(response).to have_http_status(:accepted)
      body = JSON.parse(response.body)
      expect(body).to include(
        "status" => "ok",
        "uploaded" => 2,
        "folder" => "backup_2026-05-14_120000_UTC"
      )
    end
  end
end
