import registerEvents from 'retrospring/utilities/registerEvents';
import { enableHandler } from './enable';
import { dismissHandler } from "./dismiss";
import { unsubscribeHandler } from "retrospring/features/webpush/unsubscribe";

export default (): void => {
  const swCapable = document.body.classList.contains('cap-service-worker');
  const notificationCapable = document.body.classList.contains('cap-notification');

  if (swCapable && notificationCapable) {
    const enableBtn = document.querySelector('button[data-action="push-enable"]');

    if (!enableBtn) return;

    enableBtn.classList.remove('d-none');

    navigator.serviceWorker.getRegistration().then(registration =>
      registration?.pushManager.getSubscription().then(subscription => {
        if (subscription) {
          document.querySelector('button[data-action="push-enable"]').classList.add('d-none');
          document.querySelector('[data-action="push-disable"]').classList.remove('d-none');
          if (localStorage.getItem('dismiss-push-settings-prompt') == null) {
            document.querySelector('.push-settings')?.classList.remove('d-none');
          }
        }
      }));
  }

  registerEvents([
    {type: 'click', target: '[data-action="push-enable"]', handler: enableHandler, global: true},
    {type: 'click', target: '[data-action="push-dismiss"]', handler: dismissHandler, global: true},
    {type: 'click', target: '[data-action="push-disable"]', handler: unsubscribeHandler, global: true},
    {
      type: 'click',
      target: '[data-action="push-remove-all"]',
      handler: unsubscribeHandler,
      global: true
    },
  ]);
}