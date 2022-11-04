class AdminUser < ApplicationRecord
  include Trestle::Auth::ModelMethods
  include Trestle::Auth::ModelMethods::Rememberable

  def initials
    first_name.first + last_name.first
  end

  def full_name
    [first_name, last_name].join(" ")
  end
end
