import registerEvents from 'retrospring/utilities/registerEvents';
import { enableHandler } from './enable';
import { dismissHandler } from "./dismiss";

export default (): void => {
  const swCapable = document.body.classList.contains('cap-service-worker');
  const notificationCapable = document.body.classList.contains('cap-notification');

  if (swCapable && notificationCapable) {
    navigator.serviceWorker.getRegistration().then(registration => {
      if (!registration && localStorage.getItem('dismiss-push-settings-prompt') == null) {
        document.querySelector('.push-settings').classList.remove('d-none');
      }
    })

    registerEvents([
      {type: 'click', target: '[data-action="push-enable"]', handler: enableHandler, global: true},
      {type: 'click', target: '[data-action="push-dismiss"]', handler: dismissHandler, global: true},
    ]);
  }
}
