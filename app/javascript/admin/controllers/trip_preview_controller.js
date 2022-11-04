import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["iframe", "loadButton", "reloadButton", "placeholder"];
  static values = {
    tripId: Number,
    loadLabel: String,
    loadingLabel: String,
    reloadLabel: String,
    reloadingLabel: String,
    errorLabel: String,
    placeholderLabel: String,
  };

  load() {
    this.loadButtonTarget.disabled = true;
    this.loadButtonTarget.textContent = this.loadingLabelValue;

    fetch(`/admin/trips/${this.tripIdValue}/preview_token`, {
      credentials: "same-origin",
    })
      .then((response) => {
        if (!response.ok) throw new Error("Failed to fetch preview token");
        return response.json();
      })
      .then((data) => {
        localStorage.setItem("authToken", data.token);

        this.iframeTarget.src = `/trips/${data.trip_id}`;
        this.iframeTarget.style.display = "block";
        this.placeholderTarget.style.display = "none";
        this.loadButtonTarget.style.display = "none";
        this.reloadButtonTarget.style.display = "inline-block";
      })
      .catch((error) => {
        console.error("Preview load error:", error);
        this.loadButtonTarget.disabled = false;
        this.loadButtonTarget.textContent = this.loadLabelValue;
        this.placeholderTarget.textContent = this.errorLabelValue;
      });
  }

  reload() {
    this.reloadButtonTarget.disabled = true;
    this.reloadButtonTarget.textContent = this.reloadingLabelValue;

    fetch(`/admin/trips/${this.tripIdValue}/preview_token`, {
      credentials: "same-origin",
    })
      .then((response) => {
        if (!response.ok) throw new Error("Failed to fetch preview token");
        return response.json();
      })
      .then((data) => {
        localStorage.setItem("authToken", data.token);
        this.iframeTarget.src = `/trips/${data.trip_id}`;
        this.reloadButtonTarget.disabled = false;
        this.reloadButtonTarget.textContent = this.reloadLabelValue;
      })
      .catch((error) => {
        console.error("Preview reload error:", error);
        this.reloadButtonTarget.disabled = false;
        this.reloadButtonTarget.textContent = this.reloadLabelValue;
      });
  }
}
