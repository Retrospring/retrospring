import registerEvents from 'retrospring/utilities/registerEvents';
import { createListHandler, createListInputHandler } from './create';
import { destroyListHandler } from './destroy';
import { listMembershipHandler } from './membership';

export default (): void => {
  registerEvents([
    { type: 'click', target: 'input[type=checkbox][name=gm-list-check]', handler: listMembershipHandler, global: true },
    { type: 'click', target: 'button#create-list', handler: createListHandler, global: true },
    { type: 'click', target: 'a#delete-list', handler: destroyListHandler, global: true },
    { type: 'click', target: 'input#new-list-name', handler: createListInputHandler, global: true },
  ]);
}