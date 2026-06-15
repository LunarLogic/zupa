import { Person } from "../types/Trip";
import { buildTripCardSections } from "./prepareData";

const person = (overrides: Partial<Person> = {}): Person => ({
  firstName: "Anna",
  bookPreferences: null,
  sparklingWater: 0,
  stillWater: 0,
  ...overrides,
});

describe("buildTripCardSections", () => {
  it("returns empty result when no info, water, or books", () => {
    const result = buildTripCardSections([person()], "");
    expect(result.combinedHtml).toBe("");
    expect(result.previewHtml).toBe("");
    expect(result.needsToggle).toBe(false);
  });

  it("renders Uwagi section only", () => {
    const result = buildTripCardSections([person()], "Zadzwonić przed");
    expect(result.combinedHtml).toBe("<strong>Uwagi:</strong>\nZadzwonić przed");
    expect(result.needsToggle).toBe(false);
  });

  it("escapes HTML in additionalInfo", () => {
    const result = buildTripCardSections([person()], "<script>");
    expect(result.combinedHtml).toBe("<strong>Uwagi:</strong>\n&lt;script&gt;");
  });

  it("renders Woda section with per-person sparkling and still counts", () => {
    const result = buildTripCardSections(
      [
        person({ firstName: "Misław", sparklingWater: 1 }),
        person({ firstName: "Pomir", stillWater: 1 }),
        person({ firstName: "Radowit", sparklingWater: 1, stillWater: 1 }),
      ],
      ""
    );
    expect(result.combinedHtml).toBe(
      "<strong>Woda:</strong>\nMisław: 1 gazowana\nPomir: 1 niegazowana\nRadowit: 1 gazowana, 1 niegazowana"
    );
  });

  it("skips people with no water", () => {
    const result = buildTripCardSections(
      [person({ firstName: "Anna" }), person({ firstName: "Bartek", sparklingWater: 2 })],
      ""
    );
    expect(result.combinedHtml).toBe("<strong>Woda:</strong>\nBartek: 2 gazowana");
  });

  it("renders Książki section with first name and preferences", () => {
    const result = buildTripCardSections(
      [person({ firstName: "Pomir", bookPreferences: "Fantastyka" })],
      ""
    );
    expect(result.combinedHtml).toBe("<strong>Książki:</strong>\nPomir: Fantastyka");
  });

  it("appends group-location book preferences after per-person lines", () => {
    const result = buildTripCardSections(
      [person({ firstName: "Pomir", bookPreferences: "Fantastyka" })],
      "",
      "Reportaże dla całej grupy"
    );
    expect(result.combinedHtml).toBe(
      "<strong>Książki:</strong>\nPomir: Fantastyka\nReportaże dla całej grupy"
    );
  });

  it("renders group-location book preferences when there are no people", () => {
    const result = buildTripCardSections([], "", "Poezja i kryminały");
    expect(result.combinedHtml).toBe("<strong>Książki:</strong>\nPoezja i kryminały");
  });

  it("escapes HTML in group-location book preferences", () => {
    const result = buildTripCardSections([], "", "a & b");
    expect(result.combinedHtml).toBe("<strong>Książki:</strong>\na &amp; b");
  });

  it("escapes HTML in firstName and bookPreferences", () => {
    const result = buildTripCardSections(
      [person({ firstName: "<b>x</b>", bookPreferences: "a & b" })],
      ""
    );
    expect(result.combinedHtml).toBe(
      "<strong>Książki:</strong>\n&lt;b&gt;x&lt;/b&gt;: a &amp; b"
    );
  });

  it("joins three sections with single newline (no blank line)", () => {
    const result = buildTripCardSections(
      [person({ firstName: "A", sparklingWater: 1, bookPreferences: "x" })],
      "info"
    );
    expect(result.combinedHtml).toBe(
      "<strong>Uwagi:</strong>\ninfo\n<strong>Woda:</strong>\nA: 1 gazowana\n<strong>Książki:</strong>\nA: x"
    );
  });

  it("preview keeps Uwagi header when additionalInfo present", () => {
    const result = buildTripCardSections([person({ sparklingWater: 1 })], "short note");
    expect(result.previewHtml).toBe("<strong>Uwagi:</strong>\nshort note");
    expect(result.needsToggle).toBe(true);
  });

  it("truncates raw text before escaping (no entity slice)", () => {
    const long = "a".repeat(80) + "&abcdefgh";
    const result = buildTripCardSections([person()], long);
    expect(result.previewHtml).toBe(
      `<strong>Uwagi:</strong>\n${"a".repeat(80)}&amp;abcd...`
    );
  });

  it("preview falls back to Woda when no additionalInfo", () => {
    const result = buildTripCardSections([person({ firstName: "A", sparklingWater: 1 })], "");
    expect(result.previewHtml).toBe("<strong>Woda:</strong>\nA: 1 gazowana");
    expect(result.needsToggle).toBe(false);
  });

  it("preview falls back to Książki when no additionalInfo or water", () => {
    const result = buildTripCardSections(
      [person({ firstName: "A", bookPreferences: "x" })],
      ""
    );
    expect(result.previewHtml).toBe("<strong>Książki:</strong>\nA: x");
  });

  it("needsToggle false when full content equals preview", () => {
    const result = buildTripCardSections([person()], "short");
    expect(result.combinedHtml).toBe(result.previewHtml);
    expect(result.needsToggle).toBe(false);
  });
});
