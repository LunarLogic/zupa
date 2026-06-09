class AdminUser < ApplicationRecord
  include Trestle::Auth::ModelMethods
  include Trestle::Auth::ModelMethods::Rememberable

  # Lets a logged-in admin act as a Flipper actor, so feature flags (e.g.
  # :trip_builder) can be enabled for selected users via /admin/flipper.
  def flipper_id
    "AdminUser;#{id}"
  end

  def initials
    first_name.first + last_name.first
  end

  def full_name
    [first_name, last_name].join(" ")
  end
end
