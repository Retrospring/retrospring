import { post } from '@rails/request.js';

import { showErrorNotification, showNotification } from "utilities/notifications";
import I18n from "retrospring/i18n";

export function blockAnonEventHandler(event: Event): void {
    const element: HTMLAnchorElement = event.target as HTMLAnchorElement;

    const data = {
      question: element.getAttribute('data-q-id'),
    };

    post('/ajax/block_anon', {
      body: data,
      contentType: 'application/json'
    })
      .then(async response => {
        const data = await response.json;

        if (!data.success) return false;
        const inboxEntry: Node = element.closest('.inbox-entry');

        showNotification(data.message);

        (inboxEntry as HTMLElement).remove();
      })
      .catch(err => {
        console.log(err);
        showErrorNotification(I18n.translate('frontend.error.message'));        
      });
}