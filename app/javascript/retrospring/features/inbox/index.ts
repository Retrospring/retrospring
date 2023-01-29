import registerEvents from 'utilities/registerEvents';
import registerInboxEntryEvents from './entry';
import { authorSearchHandler } from './author';
import { deleteAllAuthorQuestionsHandler, deleteAllQuestionsHandler } from './delete';

export default (): void => {
  registerEvents([
    { type: 'click', target: '#ib-delete-all', handler: deleteAllQuestionsHandler, global: true },
    { type: 'click', target: '#ib-delete-all-author', handler: deleteAllAuthorQuestionsHandler, global: true }
  ]);

  registerInboxEntryEvents();
}
