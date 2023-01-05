import { checkSubscription } from "retrospring/features/webpush/unsubscribe";

let subscriptionChecked = false;

export default (): void => {
  const swCapable = 'serviceWorker' in navigator;
  const notificationCapable = 'Notification' in window;

  // We want to adjust enable/disable buttons on every page load
  // because the enable button appears on both the settings and inbox pages.
  if (swCapable && notificationCapable) {
    const enableBtn = document.querySelector('button[data-action="push-enable"]');

    navigator.serviceWorker.getRegistration().then(async registration => {
      const subscription = await registration?.pushManager.getSubscription();
      if (subscription) {
        document.querySelector('.push-settings')?.classList.add('d-none');
        document.querySelector('button[data-action="push-enable"]')?.classList.add('d-none');
        document.querySelector('[data-action="push-disable"]')?.classList.remove('d-none');

        if (!subscriptionChecked) {
          checkSubscription(subscription);
          subscriptionChecked = true;
          return;
        }
      } else {
        enableBtn?.classList.remove('d-none');
      }

      if (localStorage.getItem('dismiss-push-settings-prompt') == null) {
        document.querySelector('.push-settings')?.classList.remove('d-none');
      }
    });
  }
}
