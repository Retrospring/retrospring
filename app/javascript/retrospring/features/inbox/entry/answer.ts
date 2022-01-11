import Rails from '@rails/ujs';

import { updateDeleteButton } from '../delete';
import { showNotification, showErrorNotification } from 'utilities/notifications';

export function answerEntryHandler(event: Event): void {
  const element: HTMLButtonElement = event.target as HTMLButtonElement;
  const inboxEntry: HTMLElement = element.closest<HTMLElement>('.inbox-entry');

  element.disabled = true;

  const shareTo = [];
  inboxEntry.querySelectorAll('input[type=checkbox][name=ib-share]:checked')
    .forEach((element: HTMLInputElement) => {
      shareTo.push(element.getAttribute('data-service'));
    });

  const data = {
    id: element.getAttribute('data-ib-id'),
    answer: inboxEntry.querySelector<HTMLInputElement>('textarea[name=ib-answer]')?.value,
    share: JSON.stringify(shareTo),
    inbox: 'true'
  };

  Rails.ajax({
    url: '/ajax/answer',
    type: 'POST',
    data: new URLSearchParams(data).toString(),
    success: (data) => {
      if (!data.success) {
        showErrorNotification(data.message);
        element.disabled = false;
        return false;
      }
      updateDeleteButton(false);
      showNotification(data.message);
      (inboxEntry as HTMLElement).remove();
    },
    error: (data, status, xhr) => {
      console.log(data, status, xhr);
      element.disabled = false;
    }
  });
}

export function answerEntryInputHandler(event: KeyboardEvent): void {
  const input = event.target as HTMLInputElement;
  const inboxId = input.dataset.id;

  if (event.keyCode == 13 && (event.ctrlKey || event.metaKey)) {
    document.querySelector<HTMLButtonElement>(`button[name="ib-answer"][data-ib-id="${inboxId}"]`).click();
  }
}