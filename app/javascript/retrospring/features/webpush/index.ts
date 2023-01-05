import registerEvents from 'retrospring/utilities/registerEvents';
import { enableHandler } from './enable';
import { dismissHandler } from "./dismiss";
import { unsubscribeHandler } from "retrospring/features/webpush/unsubscribe";

export default (): void => {
  registerEvents([
    {type: 'click', target: '[data-action="push-enable"]', handler: enableHandler, global: true},
    {type: 'click', target: '[data-action="push-dismiss"]', handler: dismissHandler, global: true},
    {type: 'click', target: '[data-action="push-disable"]', handler: unsubscribeHandler, global: true},
    {
      type: 'click',
      target: '[data-action="push-remove-all"]',
      handler: unsubscribeHandler,
      global: true
    },
  ]);
}
