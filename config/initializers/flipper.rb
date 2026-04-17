Flipper.register(:trip)
Flipper.register(:trips_beta)

if Rails.env.test?
  begin
    Flipper.enable(:trip)
    Flipper.enable(:trips_beta)
  rescue ActiveRecord::StatementInvalid
    # DB may not be ready yet (e.g. during db:schema:load)
  end
end

module Flipper
  def self.enabled?(*)
    return false if ENV["DOCKER_BUILDING"]

    super
  end
end
