import Rails from '@rails/ujs';

import { showErrorNotification, showNotification } from "utilities/notifications";
import I18n from "retrospring/i18n";

export function blockAnonEventHandler(event: Event): void {
    const element: HTMLAnchorElement = event.target as HTMLAnchorElement;

    const data = {
        question: element.getAttribute('data-q-id'),
    };

    Rails.ajax({
        url: '/ajax/block_anon',
        type: 'POST',
        data: new URLSearchParams(data).toString(),
        success: (data) => {
            if (!data.success) return false;
            const inboxEntry: Node = element.closest('.inbox-entry');

            showNotification(data.message);

            (inboxEntry as HTMLElement).remove();
        },
        error: (data, status, xhr) => {
            console.log(data, status, xhr);
            showErrorNotification(I18n.translate('frontend.error.message'));
        }
    });
}