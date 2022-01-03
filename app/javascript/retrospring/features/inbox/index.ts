import registerEvents from 'utilities/registerEvents';
import registerInboxEntryEvents from './entry';
import { authorSearchHandler } from './author';
import { deleteAllAuthorQuestionsHandler, deleteAllQuestionsHandler } from './delete';
import { generateQuestionHandler } from './generate';

export default (): void => {
  registerEvents([
    { type: 'click', target: document.querySelector('#ib-generate-question'), handler: generateQuestionHandler },
    { type: 'click', target: document.querySelector('#ib-delete-all'), handler: deleteAllQuestionsHandler },
    { type: 'click', target: document.querySelector('#ib-delete-all-author'), handler: deleteAllAuthorQuestionsHandler },
    { type: 'submit', target: document.querySelector('#author-form'), handler: authorSearchHandler }
  ]);

  registerInboxEntryEvents();
}
