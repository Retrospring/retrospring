import { post } from '@rails/request.js';

import { updateDeleteButton } from '../delete';
import { showNotification, showErrorNotification } from 'utilities/notifications';

export function answerEntryHandler(event: Event): void {
  const element: HTMLButtonElement = event.target as HTMLButtonElement;
  const inboxEntry: HTMLElement = element.closest<HTMLElement>('.inbox-entry');

  element.disabled = true;

  const data = {
    id: element.getAttribute('data-ib-id'),
    answer: inboxEntry.querySelector<HTMLInputElement>('textarea[name=ib-answer]')?.value,
    inbox: 'true'
  };

  post('/ajax/answer', {
    body: data,
    contentType: 'application/json'
  })
    .then(async response => {
      const data = await response.json;

      if (!data.success) {
        showErrorNotification(data.message);
        element.disabled = false;
        return false;
      }
      updateDeleteButton(false);
      showNotification(data.message);

      const shareButton = inboxEntry.querySelector<HTMLButtonElement>('[data-controller="share"]');
      const clipboardCopyButton = inboxEntry.querySelector<HTMLButtonElement>('[data-action="clipboard#copy"]')
      if (shareButton != null) {
        shareButton.dataset.shareUrlValue = data.sharing.url;
        shareButton.dataset.shareTextValue = data.sharing.text;
      }

      if (clipboardCopyButton != null){
        clipboardCopyButton.dataset.clipboardCopyValue = `${data.sharing.text} ${data.sharing.url}`;
      }

      const sharing = inboxEntry.querySelector<HTMLElement>('.inbox-entry__sharing');
      if (sharing != null) {
        sharing.dataset.inboxSharingConfigValue = JSON.stringify(data.sharing);
      }
      else {
        (inboxEntry as HTMLElement).remove();
      }
    })
    .catch(err => {
      console.log(err);
      element.disabled = false;
    });
}

export function answerEntryInputHandler(event: KeyboardEvent): void {
  const input = event.target as HTMLInputElement;
  const inboxId = input.dataset.id;

  if (event.keyCode == 13 && (event.ctrlKey || event.metaKey)) {
    document.querySelector<HTMLButtonElement>(`button[name="ib-answer"][data-ib-id="${inboxId}"]`).click();
  }
}
