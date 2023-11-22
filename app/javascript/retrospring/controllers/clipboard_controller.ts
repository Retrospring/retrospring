import { Controller } from "@hotwired/stimulus";
import I18n from 'retrospring/i18n';
import { showErrorNotification, showNotification } from "retrospring/utilities/notifications";

export default class extends Controller {

  static values = {
    copy: String
  };

  declare readonly copyValue: string;

  async copy(){
    try {
      await navigator.clipboard.writeText(this.copyValue);
      showNotification(I18n.translate("frontend.clipboard_copy.success"));
      this.element.dispatchEvent(new CustomEvent('retrospring:copied'));
    } catch (error) {
      console.log(error);
      showErrorNotification(I18n.translate("frontend.clipboard_copy.error"));
    }
  }
}
