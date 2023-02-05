import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['twitter', 'tumblr', 'custom'];

  declare readonly twitterTarget: HTMLAnchorElement;
  declare readonly tumblrTarget: HTMLAnchorElement;
  declare readonly customTarget: HTMLAnchorElement;
  declare readonly hasCustomTarget: boolean;

  static values = {
    config: Object,
    autoClose: Boolean
  };

  declare readonly configValue: Record<string, string>;
  declare readonly autoCloseValue: boolean;

  connect(): void {
    if (this.autoCloseValue) {
      this.twitterTarget.addEventListener('click', () => this.close());
      this.tumblrTarget.addEventListener('click', () => this.close());

      if (this.hasCustomTarget) {
        this.customTarget.addEventListener('click', () => this.close());
      }
    }
  }

  configValueChanged(value: Record<string, string>): void {
    if (Object.keys(value).length === 0) {
      return;
    }

    this.element.classList.remove('d-none');

    this.twitterTarget.href = this.configValue['twitter'];
    this.tumblrTarget.href = this.configValue['tumblr'];

    if (this.hasCustomTarget) {
      this.customTarget.href = `${this.customTarget.href}${this.configValue['custom']}`;
    }
  }

  close(): void {
    (this.element.closest(".inbox-entry")).remove();
  }
}
