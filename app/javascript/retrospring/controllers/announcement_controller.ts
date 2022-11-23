import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = {
    id: Number
  };

  declare readonly idValue: number;

  connect(): void {
    if (!window.localStorage.getItem(`announcement${this.idValue}`)) {
      this.element.classList.remove('d-none');
    }
  }

  close(): void {
    window.localStorage.setItem(`announcement${this.idValue}`, 'true');
  }
}
