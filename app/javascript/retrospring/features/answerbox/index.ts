import registerEvents from 'utilities/registerEvents';
import registerAnswerboxCommentEvents from './comment';
import { answerboxDestroyHandler } from './destroy';
import { answerboxReportHandler } from './report';
import { answerboxSmileHandler } from './smile';
import { answerboxSubscribeHandler } from './subscribe';

export default (): void => {
  registerEvents([
    { type: 'click', target: '[data-action=ab-submarine]', handler: answerboxSubscribeHandler, global: true },
    { type: 'click', target: '[data-action=ab-report]', handler: answerboxReportHandler, global: true },
    { type: 'click', target: '[data-action=ab-destroy]', handler: answerboxDestroyHandler, global: true },
    { type: 'click', target: '[name=ab-smile]', handler: answerboxSmileHandler, global: true }
  ]);

  registerAnswerboxCommentEvents();
}
