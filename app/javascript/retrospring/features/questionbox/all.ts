import { post } from '@rails/request.js';
import { Modal } from 'bootstrap';
import { showErrorNotification, showNotification } from 'utilities/notifications';
import I18n from 'retrospring/i18n';

export function questionboxAllHandler(event: Event): void {
  const button = event.target as HTMLButtonElement;

  button.disabled = true;
  document.querySelector<HTMLInputElement>('textarea[name=qb-all-question]').readOnly = true;

  post('/ajax/ask', {
    body: {
      rcpt: 'followers',
      question: document.querySelector<HTMLInputElement>('textarea[name=qb-all-question]').value,
      anonymousQuestion: 'false',
      sendToOwnInbox: (document.getElementById('qb-send-to-own-inbox') as HTMLInputElement).checked,
    },
    contentType: 'application/json'
  })
    .then(async response => {
      const data = await response.json;

      if (data.success) {
        document.querySelector<HTMLInputElement>('textarea[name=qb-all-question]').value = '';
        const modal = Modal.getInstance(document.querySelector('#modal-ask-followers'));
        modal.hide();
      }

      showNotification(data.message, data.success);
    })
    .catch(err => {
      console.log(err);
      showErrorNotification(I18n.translate('frontend.error.message'));
    })
    .finally(() => {
      button.disabled = false;
      document.querySelector<HTMLInputElement>('textarea[name=qb-all-question]').readOnly = false;
    });
}

export function questionboxAllInputHandler(event: KeyboardEvent): void {
  if (event.keyCode == 13 && (event.ctrlKey || event.metaKey)) {
    document.querySelector<HTMLButtonElement>(`button[name=qb-all-ask]`).click();
  }
}

export function questionboxAllModalAutofocus(): void {
  document.querySelector<HTMLInputElement>('textarea[name=qb-all-question]').focus();
}
