import Rails from '@rails/ujs';
import { showErrorNotification, showNotification } from 'utilities/notifications';
import I18n from 'retrospring/i18n';

export function questionboxUserHandler(event: Event): void {
  const button = event.target as HTMLButtonElement;
  const promote = button.dataset.promote === "true";
  const anonymousInput = document.querySelector<HTMLInputElement>('input[name=qb-anonymous]');
  let anonymousQuestion = true;

  if (anonymousInput) {
    anonymousQuestion = anonymousInput.checked;
  }

  document.querySelector<HTMLInputElement>('textarea[name=qb-question]').readOnly = true;
  button.disabled = true;

  Rails.ajax({
    url: '/ajax/ask',
    type: 'POST',
    data: new URLSearchParams({
      rcpt: document.querySelector<HTMLInputElement>('input[name=qb-to]').value,
      question: document.querySelector<HTMLInputElement>('textarea[name=qb-question]').value,
      anonymousQuestion: String(anonymousQuestion)
    }).toString(),
    success: (data) => {
      if (data.success) {
        document.querySelector<HTMLInputElement>('textarea[name=qb-question]').value = '';

        if (promote) {
          const questionbox = document.querySelector('#question-box');
          questionbox.classList.toggle('d-none');

          const promote = document.querySelector('#question-box-promote');
          promote.classList.toggle('d-none');
        }
      }
      
      showNotification(data.message, data.success);
    },
    error: (data, status, xhr) => {
      console.log(data, status, xhr);
      showErrorNotification(I18n.translate('frontend.error.message'));
    },
    complete: () => {
      document.querySelector<HTMLInputElement>('textarea[name=qb-question]').readOnly = false;
      button.disabled = false;
    }
  });
}

export function questionboxPromoteHandler(): void {
  const questionbox = document.querySelector('#question-box');
  questionbox.classList.toggle('d-none');

  const promote = document.querySelector('#question-box-promote');
  promote.classList.toggle('d-none');
}

export function questionboxUserInputHandler(event: KeyboardEvent): void {
  if (event.keyCode == 13 && (event.ctrlKey || event.metaKey)) {
    document.querySelector<HTMLButtonElement>(`button[name=qb-ask]`).click();
  }
}