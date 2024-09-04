import { Application } from "@hotwired/stimulus";
import CapabilitiesController from "retrospring/controllers/capabilities_controller";

/**
 * This module sets up Stimulus and our controllers
 *
 * TODO: Temporary solution until I implement stimulus-rails and move
 *       controllers to app/javascript/controllers where an automated
 *       index can be generated
 */
export default function (): void {
  window['Stimulus'] = Application.start();
  window['Stimulus'].register('capabilities', CapabilitiesController);
}
