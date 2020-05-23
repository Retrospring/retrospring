import Rails from '@rails/ujs';

import { updateDeleteButton } from '../delete';
import animate from '../../../utilities/animate';

export function answerEntryHandler(): void {
  const element: HTMLButtonElement = event.currentTarget as HTMLButtonElement;
  const inboxEntry: HTMLElement = element.closest<HTMLElement>('.inbox-entry');

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
  }

  Rails.ajax({
    url: '/ajax/answer',
    type: 'POST',
    data: new URLSearchParams(data).toString(),
    success: (data) => {
      if (!data.success) return false;
      updateDeleteButton(false);

      animate(inboxEntry, 'fadeOutUp')
        .then(() => {
          (inboxEntry as HTMLElement).remove();
        });
    },
    error: (data, status, xhr) => {
      console.log(data, status, xhr);
    }
  });
}
