import { render, screen, fireEvent } from "../../../setupTests";
import ExpandableContent from "./ExpandableContent";

describe("<ExpandableContent /> string mode", () => {
  it("renders short content without toggle", () => {
    render(<ExpandableContent content="short" />);
    expect(screen.getByText("short")).toBeInTheDocument();
    expect(screen.queryByText(/Rozwiń/)).not.toBeInTheDocument();
  });

  it("truncates long content and toggles on click", () => {
    const long = "x".repeat(200);
    render(<ExpandableContent content={long} />);
    expect(screen.getByText(/Rozwiń/)).toBeInTheDocument();
    fireEvent.click(screen.getByText(/Rozwiń/));
    expect(screen.getByText(/Zwiń/)).toBeInTheDocument();
  });
});

describe("<ExpandableContent /> html mode", () => {
  it("renders raw HTML content", () => {
    const { container } = render(<ExpandableContent content="<strong>Hi</strong>" isHtml />);
    expect(container.querySelector("strong")?.textContent).toBe("Hi");
  });

  it("shows previewHtml when collapsed and full content when expanded", () => {
    const { container } = render(
      <ExpandableContent
        content="<strong>Uwagi:</strong>\nfull body"
        previewHtml="<strong>Uwagi:</strong>\npreview"
        isHtml
      />
    );
    expect(container.textContent).toContain("preview");
    expect(container.textContent).not.toContain("full body");
    fireEvent.click(screen.getByText(/Rozwiń/));
    expect(container.textContent).toContain("full body");
  });

  it("hides toggle when no previewHtml provided", () => {
    render(<ExpandableContent content="<p>x</p>" isHtml />);
    expect(screen.queryByText(/Rozwiń/)).not.toBeInTheDocument();
    expect(screen.queryByText(/Zwiń/)).not.toBeInTheDocument();
  });
});
