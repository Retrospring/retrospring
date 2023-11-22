import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['twitter', 'tumblr', 'telegram', 'other', 'custom', 'clipboard'];

  declare readonly twitterTarget: HTMLAnchorElement;
  declare readonly tumblrTarget: HTMLAnchorElement;
  declare readonly telegramTarget: HTMLAnchorElement;
  declare readonly customTarget: HTMLAnchorElement;
  declare readonly otherTarget: HTMLButtonElement;
  declare readonly clipboardTarget: HTMLButtonElement;
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
      this.telegramTarget.addEventListener('click', () => this.close());
      this.otherTarget.addEventListener('click', () => this.closeAfterShare());
      this.clipboardTarget.addEventListener('click', () => this.closeAfterCopyToClipboard());

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
    this.telegramTarget.href = this.configValue['telegram'];

    if (this.hasCustomTarget) {
      this.customTarget.href = `${this.customTarget.href}${this.configValue['custom']}`;
    }
  }

  close(): void {
    (this.element.closest(".inbox-entry")).remove();
  }

  closeAfterShare(): void {
    this.otherTarget.addEventListener('retrospring:shared', () => this.close());
  }

  closeAfterCopyToClipboard(): void {
    this.clipboardTarget.addEventListener('retrospring:copied', () => this.close());
  }
}
