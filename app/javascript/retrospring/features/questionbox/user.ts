import { post } from '@rails/request.js';
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

  post('/ajax/ask', {
    body: {
      rcpt: document.querySelector<HTMLInputElement>('input[name=qb-to]').value,
      question: document.querySelector<HTMLInputElement>('textarea[name=qb-question]').value,
      anonymousQuestion: String(anonymousQuestion)
    },
    contentType: 'application/json'
  })
    .then(async response => {
      const data = await response.json;

      if (data.success) {
        document.querySelector<HTMLInputElement>('textarea[name=qb-question]').value = '';

        // FIXME: also solve this using a Stimulus controller
        const characterCount = document.querySelector<HTMLElement>('#question-box[data-character-count-max-value]').dataset.characterCountMaxValue;
        document.querySelector<HTMLElement>('#question-box [data-character-count-target="counter"]').innerHTML = characterCount;

        if (promote) {
          const questionbox = document.querySelector('#question-box');
          questionbox.classList.toggle('d-none');

          const promote = document.querySelector('#question-box-promote');
          promote.classList.toggle('d-none');
        }
      }

      showNotification(data.message, data.success);
    })
    .catch(err => {
      console.log(err);
      showErrorNotification(I18n.translate('frontend.error.message'));
    })
    .finally(() => {
      document.querySelector<HTMLInputElement>('textarea[name=qb-question]').readOnly = false;
      button.disabled = false;
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
