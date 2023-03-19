import { Controller } from "@hotwired/stimulus";
import { install, uninstall } from "@github/hotkey";

export default class extends Controller<HTMLElement> {
  connect(): void {
    install(this.element);
  }

  disconnect(): void {
    uninstall(this.element);
  }
}
