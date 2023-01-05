import registerEvents from 'retrospring/utilities/registerEvents';
import { themeButtonHandler } from './theme';

export default (): void => {
  registerEvents([
    { type: 'click', target: document.querySelectorAll('.js-theme-button'), handler: themeButtonHandler }
  ]);
}