import Rails from '@rails/ujs';

import { showNotification, showErrorNotification } from 'utilities/notifications';

export function questionAnswerHandler(event: Event): void {
  const button = event.target as HTMLButtonElement;
  const questionId = button.dataset.qId;

  button.disabled = true;
  document.querySelector<HTMLInputElement>('textarea#q-answer-text').readOnly = true;

  const shareTo = [];
  Array.from(document.querySelectorAll(`input[type=checkbox][name=share][data-q-id="${questionId}"]:checked`))
    .forEach((element: HTMLInputElement) => {
      shareTo.push(element.dataset.service);
    });

  const data = {
    id: questionId,
    answer: document.querySelector<HTMLInputElement>('textarea#q-answer-text').value,
    share: JSON.stringify(shareTo),
    inbox: String(false)
  };

  Rails.ajax({
    url: '/ajax/answer',
    type: 'POST',
    data: new URLSearchParams(data).toString(),
    success: (data) => {
      if (!data.success) {
        showErrorNotification(data.message);
        button.disabled = false;
        document.querySelector<HTMLInputElement>('textarea#q-answer-text').readOnly = false;
        return false;
      }

      showNotification(data.message);
      document.querySelector('div#answers').insertAdjacentHTML('afterbegin', data.render);
      document.querySelector('div#q-answer-box').remove();
    },
    error: (data, status, xhr) => {
      console.log(data, status, xhr);
      button.disabled = false;
      document.querySelector<HTMLInputElement>('textarea#q-answer-text').readOnly = false;
    }
  });
}

export function questionAnswerInputHandler(event: KeyboardEvent): void {
  if (event.keyCode == 13 && (event.ctrlKey || event.metaKey)) {
    document.querySelector<HTMLButtonElement>('button#q-answer-btn').click();
  }
}