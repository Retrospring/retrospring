import Rails from '@rails/ujs';

import I18n from 'retrospring/i18n';
import { showNotification, showErrorNotification } from 'utilities/notifications';

export function answerboxSubscribeHandler(event: Event): void {
  const button = event.target as HTMLButtonElement;
  const id = button.dataset.aId;
  let torpedo = 0;
  let targetUrl;
  event.preventDefault();

  if (button.dataset.torpedo === 'yes') {
    torpedo = 1;
  }

  if (torpedo) {
    targetUrl = '/ajax/subscribe';
  } else {
    targetUrl = '/ajax/unsubscribe';
  }

  Rails.ajax({
    url: targetUrl,
    type: 'POST',
    data: new URLSearchParams({
      answer: id
    }).toString(),
    success: (data) => {
      if (data.success) {
        button.dataset.torpedo = ["yes", "no"][torpedo];
        button.children[0].nextSibling.textContent = ' ' + (torpedo ? I18n.translate('views.actions.unsubscribe') : I18n.translate('views.actions.subscribe'));
        showNotification(I18n.translate(`frontend.subscription.${torpedo ? 'subscribe' : 'unsubscribe'}`));
      } else {
        showErrorNotification(I18n.translate(`frontend.subscription.fail.${torpedo ? 'subscribe' : 'unsubscribe'}`));
      }
    },
    error: (data, status, xhr) => {
      console.log(data, status, xhr);
      showErrorNotification(I18n.translate('frontend.error.message'));
    }
  });
}