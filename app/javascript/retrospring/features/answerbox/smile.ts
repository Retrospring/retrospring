import Rails from '@rails/ujs';

import I18n from '../../../legacy/i18n';
import { showNotification, showErrorNotification } from 'utilities/notifications';

export function answerboxSmileHandler(event: Event): void {
  const button = event.target as HTMLButtonElement;
  const id = button.dataset.aId;
  const action = button.dataset.action;
  let count = Number(document.querySelector(`#ab-smile-count-${id}`).innerHTML);
  let success = false;
  let targetUrl;

  if (action === 'smile') {
    count++;
    targetUrl = '/ajax/create_smile';
  }
  else if (action === 'unsmile') {
    count--;
    targetUrl = '/ajax/destroy_smile';
  }

  button.disabled = true;

  Rails.ajax({
    url: targetUrl,
    type: 'POST',
    data: new URLSearchParams({
      id: id
    }).toString(),
    success: (data) => {
      success = data.success;
      if (success) {
        document.querySelector(`#ab-smile-count-${id}`).innerHTML = String(count);
      }

      showNotification(data.message, data.success);
    },
    error: (data, status, xhr) => {
      console.log(data, status, xhr);
      showErrorNotification(I18n.translate('frontend.error.message'));
    },
    complete: () => {
      button.disabled = false;

      if (success) {
        switch(action) {
          case 'smile':
            button.dataset.action = 'unsmile';
            button.innerHTML = `<i class="fa fa-fw fa-frown-o"></i> <span id="ab-smile-count-${id}">${count}</span>`;
            break;
          case 'unsmile':
            button.dataset.action = 'smile';
            button.innerHTML = `<i class="fa fa-fw fa-smile-o"></i> <span id="ab-smile-count-${id}">${count}</span>`;
            break;
        }
      }
    }
  });
}