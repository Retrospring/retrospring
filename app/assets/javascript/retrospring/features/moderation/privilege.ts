import { post } from '@rails/request.js';

import I18n from 'retrospring/i18n';
import { showNotification, showErrorNotification } from 'utilities/notifications';

export function privilegeCheckHandler(event: Event): void {
  const checkbox = event.target as HTMLInputElement;
  checkbox.disabled = true;

  const privilegeType = checkbox.dataset.type;

  post('/ajax/mod/privilege', {
    body: {
      user: checkbox.dataset.user,
      type: privilegeType,
      status: String(checkbox.checked)
    },
    contentType: 'application/json'
  })
    .then(async response => {
      const data = await response.json;

      if (data.success) {
        checkbox.checked = data.checked;
      }

      showNotification(data.message, data.success);
    })
    .catch(err => {
      console.log(err);
      showErrorNotification(I18n.translate('frontend.error.message'));
      checkbox.checked = false;
    })
    .finally(() => {
      checkbox.disabled = false;
    });
}