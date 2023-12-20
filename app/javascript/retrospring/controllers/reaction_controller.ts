import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['button'];

  declare readonly buttonTarget: HTMLButtonElement;

  enable(): void {
    this.buttonTarget.disabled = false;
  }

  disable(): void {
    this.buttonTarget.disabled = true;
  }
}
