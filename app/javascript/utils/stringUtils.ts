const charMap: { [key: string]: string } = {
  ą: "a",
  ć: "c",
  ę: "e",
  ł: "l",
  ń: "n",
  ó: "o",
  ś: "s",
  ź: "z",
  ż: "z",
};

export function simpleNormalize(text: string): string {
  return text
    .trim()
    .toLowerCase()
    .split("")
    .map((char) => charMap[char] || char)
    .join("");
}
