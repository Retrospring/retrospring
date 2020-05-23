import registerEvents from '../../../utilities/registerEvents';

import { answerEntryHandler } from './answer';
import { deleteEntryHandler } from './delete';

export default (): void => {
  const entries: NodeList = document.querySelectorAll('.inbox-entry:not(.js-initialized)');

  entries.forEach((element: HTMLElement) => {
    registerEvents([
      { type: 'click', target: element.querySelector('button[name="ib-answer"]'), handler: answerEntryHandler },
      { type: 'click', target: element.querySelector('[name="ib-destroy"]'), handler: deleteEntryHandler }
    ]);

    element.classList.add('js-initialized');
  });
}
