import registerEvents from '../../../utilities/registerEvents';

import { deleteEntryHandler } from './delete';

export default (): void => {
  const entries: NodeList = document.querySelectorAll('.inbox-entry:not(.js-initialized)');

  entries.forEach((element: HTMLElement) => {
    registerEvents([
      { type: 'click', target: element.querySelector('[name="ib-destroy"]'), handler: deleteEntryHandler }
    ]);

    element.classList.add('js-initialized');
  });
}
