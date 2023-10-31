import registerEvents from 'utilities/registerEvents';
import registerAnswerboxCommentEvents from './comment';
import { answerboxDestroyHandler } from './destroy';
import { answerboxReportHandler } from './report';

export default (): void => {
  registerEvents([
    { type: 'click', target: '[data-action=ab-report]', handler: answerboxReportHandler, global: true },
    { type: 'click', target: '[data-action=ab-destroy]', handler: answerboxDestroyHandler, global: true },
  ]);

  registerAnswerboxCommentEvents();
}
