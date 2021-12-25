import registerEvents from 'utilities/registerEvents';
import { reportEventHandler } from './report';

export default (): void => {
  const entries: NodeList = document.querySelectorAll('.inbox-entry:not(.js-initialized)');

  entries.forEach((element: HTMLElement) => {
    registerEvents([
      { type: 'click', target: element.querySelector('[name=ib-report]'), handler: reportEventHandler }
    ]);

    element.classList.add('js-initialized');
  });
}
