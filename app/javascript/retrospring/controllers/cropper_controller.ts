import { Controller } from '@hotwired/stimulus';
import Croppr from 'croppr';

export default class extends Controller {
  static targets = ['input', 'controls', 'cropper', 'x', 'y', 'w', 'h'];

  declare readonly inputTarget: HTMLInputElement;
  declare readonly controlsTarget: HTMLElement;
  declare readonly cropperTarget: HTMLImageElement;
  declare readonly xTarget: HTMLInputElement;
  declare readonly yTarget: HTMLInputElement;
  declare readonly wTarget: HTMLInputElement;
  declare readonly hTarget: HTMLInputElement;

  static values = {
    aspectRatio: String
  };

  declare readonly aspectRatioValue: string;

  readImage(file: File, callback: (string) => void): void {
    callback((window.URL || window.webkitURL).createObjectURL(file));
  }

  updateValues(data: Record<string, string>): void {
    this.xTarget.value = data.x;
    this.yTarget.value = data.y;
    this.wTarget.value = data.width;
    this.hTarget.value = data.height;
  }

  change(): void {
    this.controlsTarget.classList.toggle('d-none');

    if (this.inputTarget.files && this.inputTarget.files[0]) {
      this.readImage(this.inputTarget.files[0], (src) => {
        this.cropperTarget.src = src;

        new Croppr(this.cropperTarget, {
          aspectRatio: parseFloat(this.aspectRatioValue),
          startSize: [100, 100, '%'],
          onCropStart: this.updateValues.bind(this),
          onCropMove: this.updateValues.bind(this),
          onCropEnd: this.updateValues.bind(this)
        });
      });
    }
  }
}
