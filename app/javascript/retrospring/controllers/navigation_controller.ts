import { Controller } from "@hotwired/stimulus";
import { install, uninstall } from "@github/hotkey";

export default class extends Controller {
  static classes = ["current"];
  static targets = ["current", "traversable"];

  declare readonly hasCurrentTarget: boolean;
  declare readonly currentTarget: HTMLElement;
  declare readonly traversableTargets: HTMLElement[];

  traversableTargetConnected(target: HTMLElement): void {
    if (!("navigationIndex" in target.dataset)) {
      target.dataset.navigationIndex = this.traversableTargets.indexOf(target).toString();
    }

    if (!this.hasCurrentTarget) {
      const first = this.traversableTargets[0];
      first.dataset.navigationTarget += " current";
    }
  }

  currentTargetConnected(target: HTMLElement): void {
    target.classList.add("js-hotkey-current-selection");

    target.querySelectorAll<HTMLElement>("[data-selection-hotkey]")
      .forEach(el => install(el, el.dataset.selectionHotkey));
  }

  currentTargetDisconnected(target: HTMLElement): void {
    target.classList.remove("js-hotkey-current-selection");

    target.querySelectorAll<HTMLElement>("[data-selection-hotkey]")
      .forEach(el => uninstall(el));
  }

  up(): void {
    const prevIndex = this.traversableTargets.indexOf(this.currentTarget) - 1;
    if (prevIndex == -1) return;

    this.navigate(this.traversableTargets[prevIndex]);
  }

  down(): void {
    const nextIndex = this.traversableTargets.indexOf(this.currentTarget) + 1;
    if (nextIndex == this.traversableTargets.length) return;

    this.navigate(this.traversableTargets[nextIndex]);
  }

  navigate(target: HTMLElement): void {
    if (!document.body.classList.contains("js-hotkey-navigating")) {
      document.body.classList.add("js-hotkey-navigating");
    }

    if (target.dataset.navigationTarget == "traversable") {
      this.currentTarget.dataset.navigationTarget = "traversable";
      target.dataset.navigationTarget = "traversable current";
      target.scrollIntoView({ block: "center", inline: "center" });
    }
  }
}
