import registerEvents from 'utilities/registerEvents';
import { questionAnswerHandler, questionAnswerInputHandler } from './answer';
import { questionDestroyHandler } from './destroy';
import { questionReportHandler } from './report';

export default (): void => {
  registerEvents([
    { type: 'click', target: '[data-action=ab-question-report]', handler: questionReportHandler, global: true },
    { type: 'click', target: '[data-action=ab-question-destroy]', handler: questionDestroyHandler, global: true },
    { type: 'click', target: '#q-answer-btn', handler: questionAnswerHandler, global: true },
    { type: 'keydown', target: '#q-answer-text', handler: questionAnswerInputHandler, global: true }
  ]);
}