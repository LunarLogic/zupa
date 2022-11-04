module Admin
  class TripsController < Trestle::ResourceController
    def preview_token
      trip = Trip.find(params[:id])

      token = Auth::JsonWebToken.encode(
        {admin_preview: true, trip_id: trip.id},
        Time.zone.now + 15.minutes
      )

      render json: {token: token, trip_id: trip.id}
    end
  end
end
