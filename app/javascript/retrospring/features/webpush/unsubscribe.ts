import { destroy } from '@rails/request.js';
import { showErrorNotification, showNotification } from "utilities/notifications";
import I18n from "retrospring/i18n";

export function unsubscribeHandler(): void {
  navigator.serviceWorker.getRegistration()
    .then(registration => registration.pushManager.getSubscription())
    .then(subscription => unsubscribeClient(subscription))
    .then(subscription => unsubscribeServer(subscription))
    .then()
    .catch(error => {
      showErrorNotification(I18n.translate("frontend.push_notifications.unsubscribe.error"));
      console.error(error);
    });
}

async function unsubscribeClient(subscription?: PushSubscription): Promise<PushSubscription|null> {
  subscription?.unsubscribe().then(success => {
    if (!success) {
      throw new Error("Failed to unsubscribe.");
    }
  });

  return subscription;
}

async function unsubscribeServer(subscription?: PushSubscription): Promise<void> {
  const body = subscription != null ? { endpoint: subscription.endpoint } : undefined;

  return destroy('/ajax/webpush', {
    body,
    contentType: 'application/json',
  }).then(async response => {
    const data = await response.json;

    if (data.success) {
      showNotification(I18n.translate("frontend.push_notifications.unsubscribe.success"));

      document.getElementById('subscription-count').textContent = data.message;

      if (data.count == 0) {
        document.querySelectorAll<HTMLButtonElement>('button[data-action="push-disable"], button[data-action="push-remove-all"]')
          .forEach(button => button.classList.add('d-none'));
      }

      if (document.body.classList.contains('cap-service-worker') && document.body.classList.contains('cap-notification')) {
        document.querySelector<HTMLButtonElement>('button[data-action="push-enable"]')?.classList.remove('d-none');
      }
    } else {
      showErrorNotification(I18n.translate("frontend.push_notifications.unsubscribe.fail"));
    }
  })
}
