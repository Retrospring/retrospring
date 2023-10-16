import { Application } from "@hotwired/stimulus";
import AnnouncementController from "retrospring/controllers/announcement_controller";
import AutofocusController from "retrospring/controllers/autofocus_controller";
import CharacterCountController from "retrospring/controllers/character_count_controller";
import CharacterCountWarningController from "retrospring/controllers/character_count_warning_controller";
import FormatPopupController from "retrospring/controllers/format_popup_controller";
import CollapseController from "retrospring/controllers/collapse_controller";
import ThemeController from "retrospring/controllers/theme_controller";
import CapabilitiesController from "retrospring/controllers/capabilities_controller";
import CropperController from "retrospring/controllers/cropper_controller";
import HotkeyController from "retrospring/controllers/hotkey_controller";
import InboxSharingController from "retrospring/controllers/inbox_sharing_controller";
import ToastController from "retrospring/controllers/toast_controller";
import PwaBadgeController from "retrospring/controllers/pwa_badge_controller";
import NavigationController from "retrospring/controllers/navigation_controller";
import ShareController from "retrospring/controllers/share_controller";

/**
 * This module sets up Stimulus and our controllers
 *
 * TODO: Temporary solution until I implement stimulus-rails and move
 *       controllers to app/javascript/controllers where an automated
 *       index can be generated
 */
export default function (): void {
  window['Stimulus'] = Application.start();
  window['Stimulus'].register('announcement', AnnouncementController);
  window['Stimulus'].register('autofocus', AutofocusController);
  window['Stimulus'].register('capabilities', CapabilitiesController);
  window['Stimulus'].register('character-count', CharacterCountController);
  window['Stimulus'].register('character-count-warning', CharacterCountWarningController);
  window['Stimulus'].register('collapse', CollapseController);
  window['Stimulus'].register('cropper', CropperController);
  window['Stimulus'].register('format-popup', FormatPopupController);
  window['Stimulus'].register('hotkey', HotkeyController);
  window['Stimulus'].register('inbox-sharing', InboxSharingController);
  window['Stimulus'].register('pwa-badge', PwaBadgeController);
  window['Stimulus'].register('navigation', NavigationController);
  window['Stimulus'].register('theme', ThemeController);
  window['Stimulus'].register('toast', ToastController);
  window['Stimulus'].register('share', ShareController);
}
