import { post } from '@rails/request.js';

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

  post(targetUrl, {
    body: {
      answer: id
    },
    contentType: 'application/json'
  })
    .then(async response => {
      const data = await response.json;

      if (data.success) {
        button.dataset.torpedo = ["yes", "no"][torpedo];
        button.children[0].nextSibling.textContent = ' ' + (torpedo ? I18n.translate('voc.unsubscribe') : I18n.translate('voc.subscribe'));
        showNotification(I18n.translate(`frontend.subscription.${torpedo ? 'subscribe' : 'unsubscribe'}`));
      } else {
        showErrorNotification(I18n.translate(`frontend.subscription.fail.${torpedo ? 'subscribe' : 'unsubscribe'}`));
      }
    })
    .catch(err => {
      console.log(err);
      showErrorNotification(I18n.translate('frontend.error.message'));
    });
}