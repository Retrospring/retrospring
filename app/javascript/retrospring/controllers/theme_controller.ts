import { Controller } from '@hotwired/stimulus';
import Coloris from '@melloware/coloris';

import {
  THEME_MAPPING,
  getColorForKey,
  getHexColorFromThemeValue,
  getIntegerFromHexColor
} from 'utilities/theme';

export default class extends Controller {
  static targets = ['color'];

  declare readonly colorTargets: HTMLInputElement[];

  previewStyle = null;
  previewTimeout = null;

  setupPreviewElement(): void {
    this.previewStyle = document.createElement('style');
    this.previewStyle.setAttribute('data-preview-style', '');
    document.body.appendChild(this.previewStyle);
  }

  convertColors(): void {
    this.colorTargets.forEach((color) => {
      color.value = `#${getHexColorFromThemeValue(color.value)}`;
    });
  }

  connect(): void {
    this.setupPreviewElement();
    this.convertColors();

    Coloris.init();
    Coloris({
      el: '.color',
      wrap: false,
      formatToggle: false,
      alpha: false
    });
  }

  updatePreview(): void {
    clearTimeout(this.previewTimeout);
    this.previewTimeout = setTimeout(this.previewTheme.bind(this), 1000);
  }

  previewTheme(): void {
    const payload = {};

    this.colorTargets.forEach((color) => {
      const name = color.name.substring(6, color.name.length - 1);
      payload[name] = parseInt(color.value.substr(1, 6), 16);
    });

    this.generateTheme(payload);
  }

  generateTheme(payload: Record<string, string>): void {
    let body = ":root {\n";

    Object.entries(payload).forEach(([key, value]) => {
      if (THEME_MAPPING[key]) {
        body += `--${THEME_MAPPING[key]}: ${getColorForKey(THEME_MAPPING[key], value)};\n`;
      }
    });

    body += "}";

    this.previewStyle.innerHTML = body;
  }

  submit(): void {
    this.colorTargets.forEach((color) => {
      color.value = String(getIntegerFromHexColor(color.value));
    });
  }
}
