import Rails from '@rails/ujs';
import { showErrorNotification, showNotification } from 'utilities/notifications';
import I18n from 'retrospring/i18n';

export function questionboxAllHandler(event: Event): void {
  const button = event.target as HTMLButtonElement;

  button.disabled = true;
  document.querySelector<HTMLInputElement>('textarea[name=qb-all-question]').readOnly = true;

  Rails.ajax({
    url: '/ajax/ask',
    type: 'POST',
    data: new URLSearchParams({
      rcpt: 'followers',
      question: document.querySelector<HTMLInputElement>('textarea[name=qb-all-question]').value,
      anonymousQuestion: 'false'
    }).toString(),
    success: (data) => {
      if (data.success) {
        document.querySelector<HTMLInputElement>('textarea[name=qb-all-question]').value = '';
        window['$']('#modal-ask-followers').modal('hide');
      }
      
      showNotification(data.message, data.success);
    },
    error: (data, status, xhr) => {
      console.log(data, status, xhr);
      showErrorNotification(I18n.translate('frontend.error.message'));
    },
    complete: () => {
      button.disabled = false;
      document.querySelector<HTMLInputElement>('textarea[name=qb-all-question]').readOnly = false;
    }
  });
}

export function questionboxAllInputHandler(event: KeyboardEvent): void {
  if (event.keyCode == 13 && (event.ctrlKey || event.metaKey)) {
    document.querySelector<HTMLButtonElement>(`button[name=qb-all-ask]`).click();
  }
}