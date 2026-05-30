module Flipper
  def self.enabled?(*)
    return false if ENV["DOCKER_BUILDING"]

    super
  end
end
