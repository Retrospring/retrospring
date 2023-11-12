import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

  static values = {
    copy: String
  }

  declare readonly copyValue: string;

  async copy(){
    await navigator.clipboard.writeText(this.copyValue)
  }
}
