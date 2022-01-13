import Rails from '@rails/ujs';

import I18n from 'retrospring/i18n';
import { showNotification, showErrorNotification } from 'utilities/notifications';

export function privilegeCheckHandler(event: Event): void {
  const checkbox = event.target as HTMLInputElement;
  checkbox.disabled = true;

  const privilegeType = checkbox.dataset.type;

  Rails.ajax({
    url: '/ajax/mod/privilege',
    type: 'POST',
    data: new URLSearchParams({
      user: checkbox.dataset.user,
      type: privilegeType,
      status: String(checkbox.checked)
    }).toString(),
    success: (data) => {
      if (data.success) {
        checkbox.checked = data.checked;
      }

      showNotification(data.message, data.success);
    },
    error: (data, status, xhr) => {
      console.log(data, status, xhr);
      showErrorNotification(I18n.translate('frontend.error.message'));
      checkbox.checked = false;
    },
    complete: () => {
      checkbox.disabled = false;
    }
  });

}