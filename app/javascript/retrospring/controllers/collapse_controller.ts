import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['action', 'content'];

  declare readonly contentTarget: HTMLElement;
  declare readonly actionTarget: HTMLElement;

  connect(): void {
    this.actionTarget.addEventListener('click', this.update.bind(this));
  }

  update(): void {
    this.contentTarget.classList.toggle('collapsed');
  }
}
