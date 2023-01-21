import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect(): void {
    const capabilities = [];

    if ('share' in navigator) {
      capabilities.push('cap-web-share');
    }

    if ('serviceWorker' in navigator) {
      capabilities.push('cap-service-worker');
    }

    if ('Notification' in window) {
      capabilities.push('cap-notification');
    }

    this.element.classList.add(...capabilities);
  }
}
