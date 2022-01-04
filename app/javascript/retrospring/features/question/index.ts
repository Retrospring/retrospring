import registerEvents from 'utilities/registerEvents';
import { questionAnswerHandler, questionAnswerInputHandler } from './answer';

export default (): void => {
  registerEvents([
    { type: 'click', target: '#q-answer-btn', handler: questionAnswerHandler, global: true },
    { type: 'keydown', target: '#q-answer-text', handler: questionAnswerInputHandler, global: true }
  ]);
}