import { on } from 'retrospring/utilities/on';
import { createListHandler, createListInputHandler } from './create';
import { destroyListHandler } from './destroy';
import { listMembershipHandler } from './membership';

export default (): void => {
  on('click', 'input[type=checkbox][name=gm-list-check]', listMembershipHandler);
  on('click', 'button#create-list', createListHandler);
  on('click', 'a#delete-list', destroyListHandler);
  on('keyup', 'input#new-list-name', createListInputHandler);
}