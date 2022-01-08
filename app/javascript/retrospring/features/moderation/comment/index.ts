import registerEvents from 'utilities/registerEvents';
import { commentCharacterHandler } from './count';
import { destroyCommentHandler } from './destroy';
import { commentCreateHandler } from './new';
import { entryCommentToggle } from './toggle';

export default (): void => {
  registerEvents([
    { type: 'click', target: '[name=mod-comments]', handler: entryCommentToggle, global: true },
    { type: 'input', target: '[name=mod-comment-new]', handler: commentCharacterHandler, global: true },
    { type: 'click', target: '[data-action=mod-comment-destroy]', handler: destroyCommentHandler, global: true },
    { type: 'keyup', target: '[name=mod-comment-new]', handler: commentCreateHandler, global: true }
  ]);
}