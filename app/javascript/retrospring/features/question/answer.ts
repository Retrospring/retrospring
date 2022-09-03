import { post } from '@rails/request.js';

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

  post('/ajax/answer', {
    body: data,
    contentType: 'application/json'
  })
    .then(async response => {
      const data = await response.json;

      if (!data.success) {
        showErrorNotification(data.message);
        button.disabled = false;
        document.querySelector<HTMLInputElement>('textarea#q-answer-text').readOnly = false;
        return false;
      }

      showNotification(data.message);
      document.querySelector('div#answers').insertAdjacentHTML('afterbegin', data.render);
      document.querySelector('div#q-answer-box').remove();
    })
    .catch(err => {
      console.log(err);
      button.disabled = false;
      document.querySelector<HTMLInputElement>('textarea#q-answer-text').readOnly = false;
    });
}

export function questionAnswerInputHandler(event: KeyboardEvent): void {
  if (event.keyCode == 13 && (event.ctrlKey || event.metaKey)) {
    document.querySelector<HTMLButtonElement>('button#q-answer-btn').click();
  }
}