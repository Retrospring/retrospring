import { Controller } from '@hotwired/stimulus';
import { Tooltip } from 'bootstrap';

export default class extends Controller {
  connect(): void {
    new Tooltip(this.element);
  }
}
