import registerEvents from 'retrospring/utilities/registerEvents';
import { enableHandler } from './enable';
import { dismissHandler } from "./dismiss";

export default (): void => {
  const swCapable = 'serviceWorker' in navigator;
  if (swCapable) {
    document.body.classList.add('cap-service-worker');
  }

  const notificationCapable = 'Notification' in window;
  if (notificationCapable) {
    document.body.classList.add('cap-notification');
  }

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
