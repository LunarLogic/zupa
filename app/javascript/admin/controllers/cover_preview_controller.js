import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "image", "placeholder"];
  static values = { maxSize: Number };

  preview() {
    const file = this.inputTarget.files?.[0];
    if (!file) return;

    if (!file.type.startsWith("image/")) {
      this.inputTarget.value = "";
      return;
    }

    if (this.hasMaxSizeValue && file.size > this.maxSizeValue) {
      const mb = (this.maxSizeValue / (1024 * 1024)).toFixed(1);
      alert(`Plik za duży. Maksymalny rozmiar: ${mb} MB.`);
      this.inputTarget.value = "";
      return;
    }

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
