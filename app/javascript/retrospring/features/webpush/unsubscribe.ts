import { destroy } from '@rails/request.js';
import { showErrorNotification, showNotification } from "utilities/notifications";
import I18n from "retrospring/i18n";

export function unsubscribeHandler(all = false): void {
  getSubscription().then(subscription => {
    const body = all ? { endpoint: subscription.endpoint } : undefined;

    destroy('/ajax/webpush', {
      body,
      contentType: 'application/json',
    }).then(async response => {
      const data = await response.json;

      if (data.success) {
        subscription?.unsubscribe().then(() => {
          showNotification(I18n.translate("frontend.push_notifications.unsubscribe.success"));
        }).catch(error => {
          console.error("Tried to unsubscribe this browser but was unable to.\n" +
            "As we've been unsubscribed on the server-side, this should not be an issue.",
            error);
        })
      } else {
        showErrorNotification(I18n.translate("frontend.push_notifications.unsubscribe.fail"));
      }
    }).catch(error => {
      showErrorNotification(I18n.translate("frontend.push_notifications.unsubscribe.error"));
      console.error(error);
    });
  })
}

async function getSubscription(): Promise<PushSubscription> {
  const registration = await navigator.serviceWorker.getRegistration('/');
  return await registration.pushManager.getSubscription();
}
