import Rails from '@rails/ujs';

import I18n from 'retrospring/i18n';
import { showNotification, showErrorNotification } from 'utilities/notifications';

export function banCheckboxHandler(event: Event): void {
  const checkbox = event.target as HTMLInputElement;

  if (checkbox.checked) {
    document.querySelector('#ban-controls').classList.remove('d-none');
  } else {
    document.querySelector('#ban-controls').classList.add('d-none');
  }
}

export function permanentBanCheckboxHandler(event: Event): void {
  const checkbox = event.target as HTMLInputElement;

  if (checkbox.checked) {
    document.querySelector('#ban-controls-time').classList.add('d-none');
  } else {
    document.querySelector('#ban-controls-time').classList.remove('d-none');
  }
}

export function banFormHandler(event: Event): void {
  const form = event.target as HTMLFormElement;
  const checkbox = document.querySelector<HTMLInputElement>('[name="ban"][type="checkbox"]');
  const permaCheckbox = document.querySelector<HTMLInputElement>('[name="permaban"][type="checkbox"]');
  event.preventDefault();

  const data = {
    ban: '0',
    user: form.elements['user'].value,
  };

  if (checkbox && checkbox.checked) {
    data['ban'] = '1';
    data['reason'] = form.elements['user'].value;

    if (!permaCheckbox.checked) {
      data['duration'] = form.elements['duration'].value.trim();
      data['duration_unit'] = form.elements['duration_unit'].value.trim();
    }
  }

  Rails.ajax({
    url: '/ajax/mod/ban',
    type: 'POST',
    data: new URLSearchParams(data).toString(),
    success: (data) => {
      showNotification(data.message, data.success);
    },
    error: (data, status, xhr) => {
      console.log(data, status, xhr);
      showErrorNotification(I18n.translate('frontend.error.message'));
    }
  });
}