import { post } from '@rails/request.js'; 

import I18n from 'retrospring/i18n';
import { showNotification, showErrorNotification } from 'utilities/notifications';

export function commentSmileHandler(event: Event): void {
  const button = event.target as HTMLButtonElement;
  const id = button.dataset.cId;
  const action = button.dataset.action;
  let count = Number(document.querySelector(`#ab-comment-smile-count-${id}`).innerHTML);
  let success = false;
  let targetUrl;

  if (action === 'smile') {
    count++;
    targetUrl = '/ajax/create_comment_smile';
  }
  else if (action === 'unsmile') {
    count--;
    targetUrl = '/ajax/destroy_comment_smile';
  }

  button.disabled = true;

  post(targetUrl, {
    body: {
      id: id
    },
    contentType: 'application/json'
  })
    .then(async response => {
      const data = await response.json;

      success = data.success;
      if (success) {
        document.querySelector(`#ab-comment-smile-count-${id}`).innerHTML = String(count);
      }

      showNotification(data.message, data.success);
    })
    .catch(err => {
      console.log(err);
      showErrorNotification(I18n.translate('frontend.error.message'));
    })
    .finally(() => {
      button.disabled = false;

      if (success) {
        switch(action) {
          case 'smile':
            button.dataset.action = 'unsmile';
            break;
          case 'unsmile':
            button.dataset.action = 'smile';
            break;
        }
      }
    });
}