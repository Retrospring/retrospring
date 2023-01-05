import { Application } from '@hotwired/stimulus';

import AnnouncementController from "retrospring/controllers/announcement_controller";
import AutofocusController from "retrospring/controllers/autofocus_controller";
import CharacterCountController from "retrospring/controllers/character_count_controller";

export default function (): void {
  window.Stimulus = Application.start();
  window.Stimulus.register('announcement', AnnouncementController);
  window.Stimulus.register('autofocus', AutofocusController);
  window.Stimulus.register('character-count', CharacterCountController);
}
