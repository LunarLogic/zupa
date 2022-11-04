require "pagy/extras/metadata"
require "pagy/extras/overflow"
Pagy::DEFAULT[:limit] = 5 # items per page
if Rails.env.test?
  Pagy::DEFAULT[:limit] = 1 # items per page
end
Pagy::DEFAULT[:size] = 9  # nav bar links
Pagy::DEFAULT[:overflow] = :last_page
