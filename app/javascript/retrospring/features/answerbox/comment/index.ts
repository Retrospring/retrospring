import registerEvents from "retrospring/utilities/registerEvents"
import { commentCharacterCountHandler } from "./count";
import { commentDestroyHandler } from "./destroy";
import { commentCreateHandler } from "./new";
import { commentReportHandler } from "./report";
import { commentSmileHandler } from "./smile";
import { commentToggleHandler } from "./toggle";

export default (): void => {
  registerEvents([
    { type: 'click', target: '[name=ab-comments]', handler: commentToggleHandler, global: true },
    { type: 'click', target: '[name=ab-smile-comment]', handler: commentSmileHandler, global: true },
    { type: 'click', target: '[data-action=ab-comment-report]', handler: commentReportHandler, global: true },
    { type: 'click', target: '[data-action=ab-comment-destroy]', handler: commentDestroyHandler, global: true },
    { type: 'keyup', target: '[name=ab-comment-new]', handler: commentCreateHandler, global: true },
    { type: 'input', target: '[name=ab-comment-new]', handler: commentCharacterCountHandler, global: true }
  ]);
}