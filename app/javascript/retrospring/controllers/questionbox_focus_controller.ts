import { Controller } from '@hotwired/stimulus';
import { Modal } from 'bootstrap';

export default class extends Controller {
  click(): void {
    const modal = Modal.getInstance(this.element.closest('.modal'));
    const questionbox = document.querySelector((this.element as HTMLAnchorElement).href);

    modal.hide();
    questionbox.scrollIntoView();
  }
}
