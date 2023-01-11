import { Controller } from '@hotwired/stimulus';
import { Popover } from 'bootstrap';

export default class extends Controller {
  connect(): void {
    const formatOptionsElement = document.getElementById('formatting-options');

    this.element.addEventListener('click', e => e.preventDefault());

    new Popover(this.element, {
      html: true,
      content: formatOptionsElement.innerHTML,
      placement: 'bottom',
      trigger: 'focus',
      customClass: 'rs-popover'
    })
  }
}
