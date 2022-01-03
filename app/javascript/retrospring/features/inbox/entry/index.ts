import registerEvents from 'utilities/registerEvents';
import { answerEntryHandler, answerEntryInputHandler } from './answer';
import { deleteEntryHandler } from './delete';
import optionsEntryHandler from './options';
import { reportEventHandler } from './report';

export default (): void => {
  registerEvents([
    { type: 'click', target: 'button[name="ib-answer"]', handler: answerEntryHandler, global: true },
    { type: 'click', target: '[name="ib-destroy"]', handler: deleteEntryHandler, global: true },
    { type: 'click', target: '[name=ib-report]', handler: reportEventHandler, global: true },
    { type: 'click', target: 'button[name=ib-options]', handler: optionsEntryHandler, global: true },
    { type: 'keydown', target: 'textarea[name=ib-answer]', handler: answerEntryInputHandler, global: true }
  ]);
}