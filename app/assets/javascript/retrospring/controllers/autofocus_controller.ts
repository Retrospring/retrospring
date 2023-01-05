import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect(): void {
    (this.element as HTMLInputElement).focus();
  }
}
