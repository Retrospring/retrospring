import { Controller } from '@hotwired/stimulus';
import noop from 'utilities/noop';

export default class extends Controller {
  static values = {
    url: String,
    text: String,
    title: String
  };

  declare readonly urlValue: string;
  declare readonly textValue: string;
  declare readonly titleValue: string;

  share() {
    let shareConfiguration = {};

    if (this.urlValue.length >= 1) {
      shareConfiguration = {
        ...shareConfiguration,
        ...{ url: this.urlValue }
      };
    }

    if (this.textValue.length >= 1) {
      shareConfiguration = {
        ...shareConfiguration,
        ...{ text: this.textValue }
      };
    }

    if (this.titleValue.length >= 1) {
      shareConfiguration = {
        ...shareConfiguration,
        ...{ title: this.titleValue }
      };
    }

    navigator.share(shareConfiguration)
      .then(() => {
        this.element.dispatchEvent(new CustomEvent('retrospring:shared'));
      })
      .catch(noop);
  }
}
