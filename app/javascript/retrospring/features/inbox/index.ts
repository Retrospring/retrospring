import registerEvents from 'utilities/registerEvents';

import { generateQuestionHandler } from './generate';
import { deleteAllQuestionsHandler } from './delete';
import { authorSearchHandler } from './author';
import registerInboxEntryEvents from './entry';

export default (): void => {
  registerEvents([
    { type: 'click', target: document.querySelector('#ib-generate-question'), handler: generateQuestionHandler },
    { type: 'click', target: document.querySelector('#ib-delete-all'), handler: deleteAllQuestionsHandler },
    { type: 'submit', target: document.querySelector('#author-form'), handler: authorSearchHandler }
  ]);

  registerInboxEntryEvents();
}
