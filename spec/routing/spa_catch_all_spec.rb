require "rails_helper"

# Regression: the SPA catch-all `get "*path", to: "components#index"` must not
# swallow engine-mounted routes like /rails/active_storage/blobs/* — otherwise
# cover photo URLs and other Active Storage redirects 406 because they get
# routed to ComponentsController which has no template for image/* formats.
RSpec.describe "SPA catch-all routing", type: :routing do
  it "does not shadow /rails/active_storage/blobs/redirect/* (Active Storage blob redirect)" do
    expect(get: "/rails/active_storage/blobs/redirect/abc/foo.png")
      .to route_to(
        controller: "active_storage/blobs/redirect",
        action: "show",
        signed_id: "abc",
        filename: "foo",
        format: "png"
      )
  end

  it "still routes other unknown frontend paths to the SPA" do
    expect(get: "/some/frontend/path").to route_to(
      controller: "components",
      action: "index",
      path: "some/frontend/path"
    )
  end
end
