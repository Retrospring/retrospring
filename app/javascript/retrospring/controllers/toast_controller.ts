import { Controller } from '@hotwired/stimulus';
import { showNotification } from "utilities/notifications";

export default class extends Controller<HTMLElement> {
  static values = {
    message: String,
    success: Boolean
  };

  declare readonly messageValue: string;
  declare readonly successValue: boolean;

  connect(): void {
    showNotification(this.messageValue, this.successValue);
    this.element.remove();
  }
}
