import registerEvents from "retrospring/utilities/registerEvents";
import {createShareEvent} from "./share";

export default (): void => {
  if (!('share' in navigator)) {
    return;
  }

  document.body.classList.add('cap-web-share');
  const entries: NodeList = document.querySelectorAll('.answerbox:not(.js-initialized)');

  entries.forEach((element: HTMLElement) => {
    console.log(element)
    registerEvents([
      { type: 'click', target: element.querySelector('[data-action=ab-share]'), handler: createShareEvent(element) }
    ]);

    element.classList.add('js-initialized');
  });
}