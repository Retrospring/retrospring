import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['input', 'warning'];

  declare readonly inputTarget: HTMLInputElement;
  declare readonly warningTarget: HTMLElement;

  static values = {
    warn: Number
  };

  declare readonly warnValue: number;

  connect(): void {
    this.inputTarget.addEventListener('input', this.update.bind(this));
  }

  update(): void {
    if (this.inputTarget.value.length > this.warnValue) {
      if (this.warningTarget.classList.contains('d-none')) {
        this.warningTarget.classList.remove('d-none');
      }
    } else {
      if (!this.warningTarget.classList.contains('d-none')) {
        this.warningTarget.classList.add('d-none');
      }
    }
  }
}
