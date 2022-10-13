import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['input', 'counter', 'action'];

  declare readonly inputTarget: HTMLInputElement;
  declare readonly counterTarget: HTMLElement;
  declare readonly actionTarget: HTMLInputElement;

  static values = {
    max: Number
  };

  declare readonly maxValue: number;

  connect(): void {
    this.inputTarget.addEventListener('input', this.update.bind(this));
  }

  update(): void {
    this.counterTarget.innerHTML = String(`${this.maxValue - this.inputTarget.value.length}`);

    if (this.inputTarget.value.length > this.maxValue) {
      if (!this.inputTarget.classList.contains('is-invalid') && !this.actionTarget.disabled) {
        this.inputTarget.classList.add('is-invalid');
        this.actionTarget.disabled = true;
      }
    }
    else {
      if (this.inputTarget.classList.contains('is-invalid') && this.actionTarget.disabled) {
        this.inputTarget.classList.remove('is-invalid');
        this.actionTarget.disabled = false;
      }
    }
  }
}
