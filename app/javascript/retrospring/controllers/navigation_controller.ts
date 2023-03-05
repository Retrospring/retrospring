import { Controller } from "@hotwired/stimulus";
import { install, uninstall } from "@github/hotkey";

export default class extends Controller {
  static classes = ["current"];
  static targets = ["current", "traversable"];

  declare readonly hasCurrentTarget: boolean;
  declare readonly currentTarget: HTMLElement;
  declare readonly traversableTargets: HTMLElement[];

  traversableTargetConnected(target: HTMLElement) {
    if (!this.hasCurrentTarget) {
      const first = this.traversableTargets[0];
      first.dataset.navigationTarget = "current";
    }
  }

  currentTargetConnected(target: HTMLElement) {
    target.querySelectorAll<HTMLElement>("[data-selection-hotkey]")
      .forEach(el => install(el, el.dataset.selectionHotkey))
  }

  currentTargetDisconnected(target: HTMLElement) {
    target.querySelectorAll<HTMLElement>("[data-selection-hotkey]")
      .forEach(el => uninstall(el))
  }

  up(): void {
    this.navigate(this.currentTarget.previousElementSibling as HTMLElement);
  }

  down(): void {
    this.navigate(this.currentTarget.nextElementSibling as HTMLElement);
  }

  navigate(target: HTMLElement): void {
    if (!document.body.classList.contains("js-hotkey-navigating")) {
      document.body.classList.add("js-hotkey-navigating");
    }

    if (target.dataset.navigationTarget == "traversable") {
      this.currentTarget.dataset.navigationTarget = "traversable";
      target.dataset.navigationTarget = "current";
      target.scrollIntoView(false);
    }
  }
}
