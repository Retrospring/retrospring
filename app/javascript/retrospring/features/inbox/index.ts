import registerEvents from 'utilities/registerEvents';
import registerInboxEntryEvents from './entry';
import { authorSearchHandler } from './author';
import { deleteAllAuthorQuestionsHandler, deleteAllQuestionsHandler } from './delete';
import { generateQuestionHandler } from './generate';

export default (): void => {
  registerEvents([
    { type: 'click', target: '#ib-generate-question', handler: generateQuestionHandler, global: true },
    { type: 'click', target: '#ib-delete-all', handler: deleteAllQuestionsHandler, global: true },
    { type: 'click', target: '#ib-delete-all-author', handler: deleteAllAuthorQuestionsHandler, global: true },
    { type: 'submit', target: '#author-form', handler: authorSearchHandler, global: true }
  ]);

  registerInboxEntryEvents();
}
