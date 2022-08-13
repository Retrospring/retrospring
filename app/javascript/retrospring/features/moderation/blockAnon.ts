import Rails from '@rails/ujs';
import swal from 'sweetalert';

import { showErrorNotification, showNotification } from "utilities/notifications";
import I18n from "retrospring/i18n";

export function blockAnonEventHandler(event: Event): void {
    swal({
        title: I18n.translate('frontend.mod_mute.confirm.title'),
        text: I18n.translate('frontend.mod_mute.confirm.text'),
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: "#DD6B55",
        confirmButtonText: I18n.translate('voc.y'),
        cancelButtonText: I18n.translate('voc.n'),
        closeOnConfirm: true,
    }, (dialogResult) => {
        if (!dialogResult) {
            return;
        }

        const sender: HTMLAnchorElement = event.target as HTMLAnchorElement;

        const data = {
            question: sender.getAttribute('data-q-id'),
            global: 'true'
        };

        Rails.ajax({
            url: '/ajax/block_anon',
            type: 'POST',
            data: new URLSearchParams(data).toString(),
            success: (data) => {
                if (!data.success) return false;

                showNotification(data.message);
            },
            error: (data, status, xhr) => {
                console.log(data, status, xhr);
                showErrorNotification(I18n.translate('frontend.error.message'));
            }
        });
    });
}