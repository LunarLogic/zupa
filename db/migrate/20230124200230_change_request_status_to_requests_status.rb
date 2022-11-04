class ChangeRequestStatusToRequestsStatus < ActiveRecord::Migration[7.0]
  def change
    rename_column :people, :request_status, :requests_status
  end
end
