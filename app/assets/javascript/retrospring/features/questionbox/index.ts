import registerEvents from 'utilities/registerEvents';
import { questionboxAllHandler, questionboxAllInputHandler, questionboxAllModalAutofocus } from './all';
import { questionboxPromoteHandler, questionboxUserHandler, questionboxUserInputHandler } from './user';

export default (): void => {
  registerEvents([
    { type: 'click', target: document.querySelectorAll('[name=qb-ask]'), handler: questionboxUserHandler },
    { type: 'click', target: document.querySelector('#new-question'), handler: questionboxPromoteHandler },
    { type: 'click', target: document.querySelectorAll('[name=qb-all-ask]'), handler: questionboxAllHandler },
    { type: 'keydown', target: document.querySelectorAll('[name=qb-question]'), handler: questionboxUserInputHandler },
    { type: 'keydown', target: document.querySelectorAll('[name=qb-all-question]'), handler: questionboxAllInputHandler },
    { type: 'shown.bs.modal', target: document.querySelector('#modal-ask-followers'), handler: questionboxAllModalAutofocus }
  ]);
}
