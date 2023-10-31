import registerEvents from "retrospring/utilities/registerEvents";
import { commentDestroyHandler } from "./destroy";
import { commentComposeEnd, commentComposeStart, commentCreateClickHandler, commentCreateKeyboardHandler } from "./new";
import { commentReportHandler } from "./report";
import { commentToggleHandler } from "./toggle";
import { commentHotkeyHandler } from "retrospring/features/answerbox/comment/hotkey";

export default (): void => {
  registerEvents([
    { type: 'click', target: '[name=ab-comments]', handler: commentToggleHandler, global: true },
    { type: 'click', target: '[name=ab-open-and-comment]', handler: commentHotkeyHandler, global: true },
    { type: 'click', target: '[data-action=ab-comment-report]', handler: commentReportHandler, global: true },
    { type: 'click', target: '[data-action=ab-comment-destroy]', handler: commentDestroyHandler, global: true },
    { type: 'compositionstart', target: '[name=ab-comment-new]', handler: commentComposeStart, global: true },
    { type: 'compositionend', target: '[name=ab-comment-new]', handler: commentComposeEnd, global: true },
    { type: 'keydown', target: '[name=ab-comment-new]', handler: commentCreateKeyboardHandler, global: true },
    { type: 'click', target: '[name=ab-comment-new-submit]', handler: commentCreateClickHandler, global: true }
  ]);
}
