import start from '../retrospring/common';
import initializeInboxEvents from '../retrospring/features/inbox';

start();

document.addEventListener('turbolinks:load', () => {
  initializeInboxEvents();
});
