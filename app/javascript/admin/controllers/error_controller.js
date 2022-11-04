import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["close"];

  connect() {
    setTimeout(() => {
      this.element.classList.add("show");
    }, 100); // short delay to allow for the transition

    this.closeTarget.addEventListener("click", () => {
      this.element.remove();
    });

    setTimeout(() => {
      this.element.remove();
    }, 10000); // 10 seconds
  }
}
