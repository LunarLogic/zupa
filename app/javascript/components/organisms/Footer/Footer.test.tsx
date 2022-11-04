import { render, screen } from "../../../setupTests";
import Footer from "./Footer";

describe("<Footer />", () => {
  it("should render name of the app", async () => {
    render(<Footer />);
    expect(screen.queryByText("<span>Zupa na Plantach</span>"));
  });
  it("should render name of the software house", () => {
    render(<Footer />);
    expect(screen.queryByText("<span>Zupa na Plantach</span>"));
  });
});
