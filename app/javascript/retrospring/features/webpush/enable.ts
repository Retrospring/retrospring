import { get, post } from '@rails/request.js';
import I18n from "retrospring/i18n";
import { showNotification } from "utilities/notifications";
import { Buffer } from "buffer";

export async function enableHandler (event: Event): Promise<void> {
  event.preventDefault();
  const sender = event.target as HTMLButtonElement;

  try {
    const registration = await getServiceWorker();
    const subscription = await subscribe(registration);
    const permission = await Notification.requestPermission();

    if (permission != "granted") {
      return;
    }

    const response = await post('/ajax/webpush', {
      body: {
        subscription
      },
      contentType: 'application/json'
    });

    const data = await response.json;

    if (data.success) {
      new Notification(I18n.translate("frontend.push_notifications.subscribe.success.title"), {
        body: I18n.translate("frontend.push_notifications.subscribe.success.body")
      });

      document.querySelectorAll<HTMLButtonElement>('button[data-action="push-disable"], button[data-action="push-remove-all"]')
        .forEach(button => button.classList.remove('d-none'));

      sender.classList.add('d-none');
      document.querySelector<HTMLDivElement>('.push-settings')?.classList.add('d-none');
      localStorage.setItem('dismiss-push-settings-prompt', 'true');

      const subscriptionCountElement = document.getElementById('subscription-count');
      if (subscriptionCountElement != null) {
        subscriptionCountElement.textContent = data.message;
      }
    } else {
      new Notification(I18n.translate("frontend.push_notifications.fail.title"), {
        body: I18n.translate("frontend.push_notifications.fail.body")
      });
    }
  } catch (error) {
    console.error("Failed to set up push notifications", error);
    showNotification(I18n.translate("frontend.push_notifications.setup_fail"), false);
  }
}

async function getServiceWorker(): Promise<ServiceWorkerRegistration> {
  return navigator.serviceWorker.getRegistration("/");
}

async function getServerKey(): Promise<Buffer> {
  const response = await get("/ajax/webpush/key");
  const data = await response.json;
  return Buffer.from(data.key, 'base64');
}

async function subscribe(registration: ServiceWorkerRegistration): Promise<PushSubscription> {
  const key = await getServerKey();
  return await registration.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: key
  });
}
