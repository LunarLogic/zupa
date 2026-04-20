import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.onDocClick = this.onDocClick.bind(this);
    document.addEventListener("click", this.onDocClick);
  }

  disconnect() {
    document.removeEventListener("click", this.onDocClick);
  }

  onDocClick(event) {
    if (!this.element.open) return;
    if (this.element.contains(event.target)) return;
    this.element.open = false;
  }
}
