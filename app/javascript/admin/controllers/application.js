import { Application } from "@hotwired/stimulus";
import "@hotwired/turbo-rails";

Turbo.session.drive = false;

const application = Application.start();

application.debug = false;
window.Stimulus = application;
export { application };
