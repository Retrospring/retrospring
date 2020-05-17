import registerEvents from '../../utilities/registerEvents';

import { generateQuestionHandler } from './generate';
import { deleteAllQuestionsHandler } from './delete';

export default (): void => registerEvents([
  { type: 'click', target: document.querySelector('#ib-generate-question'), handler: generateQuestionHandler },
  { type: 'click', target: document.querySelector('#ib-delete-all'), handler: deleteAllQuestionsHandler }
]);
