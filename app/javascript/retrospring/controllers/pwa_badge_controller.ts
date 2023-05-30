import { Controller } from '@hotwired/stimulus';

export default class extends Controller<HTMLElement> {
  isPwa: boolean;
  badgeCapable: boolean;

  initialize(): void {
    this.isPwa = window.matchMedia('(display-mode: standalone)').matches;
    this.badgeCapable = "setAppBadge" in navigator;
  }

  connect(): void {
    if (this.isPwa && this.badgeCapable) {
      const count = Number.parseInt(this.element.innerText) || 0;
      navigator.setAppBadge(count);
    }
  }
}
