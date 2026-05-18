import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "image", "placeholder"];

  preview() {
    const file = this.inputTarget.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (e) => {
      this.imageTarget.src = e.target.result;
      this.imageTarget.style.display = "block";
      if (this.hasPlaceholderTarget) {
        this.placeholderTarget.style.display = "none";
      }
    };
    reader.readAsDataURL(file);
  }
}
