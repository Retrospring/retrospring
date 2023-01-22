import { post } from '@rails/request.js';

import I18n from 'retrospring/i18n';
import { showNotification, showErrorNotification } from 'utilities/notifications';

let compositionJustEnded = false;

export function commentCreateHandler(event: KeyboardEvent): boolean {
  if (compositionJustEnded && event.which == 13) {
    compositionJustEnded = false;
    return;
  }

  const input = event.target as HTMLInputElement;
  const id = input.dataset.aId;
  const counter = document.querySelector(`#ab-comment-charcount-${id}`);
  const group = document.querySelector(`[name=ab-comment-new-group][data-a-id="${id}"]`);

  if (event.which === 13) {
    event.preventDefault();

    if (input.value.length > 512) {
      group.classList.add('has-error');
      return true;
    }

    input.disabled = true;

    post('/ajax/create_comment', {
      body: {
        answer: id,
        comment: input.value
      },
      contentType: 'application/json'
    })
      .then(async response => {
        const data = await response.json;

        if (data.success) {
          document.querySelector(`#ab-comments-${id}`).innerHTML = data.render;
          const commentCount = document.getElementById(`#ab-comment-count-${id}`);
          if (commentCount) {
            commentCount.innerHTML = data.count;
          }
          input.value = '';
          counter.innerHTML = String(512);

          const sub = document.querySelector<HTMLElement>(`[data-action=ab-submarine][data-a-id="${id}"]`);
          sub.dataset.torpedo = "no"
          sub.children[0].nextSibling.textContent = ' ' + I18n.translate('voc.unsubscribe');
        }

        showNotification(data.message, data.success);
      })
      .catch(err => {
        console.log(err);
        showErrorNotification(I18n.translate('frontend.error.message'));
      })
      .finally(() => {
        input.disabled = false;
      });
  }
}

export function commentComposeStart(): boolean {
  compositionJustEnded = false;
  return true;
}

export function commentComposeEnd(): boolean {
  compositionJustEnded = true;
  return true;
}
