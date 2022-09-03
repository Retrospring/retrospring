import { post } from '@rails/request.js';
import swal from 'sweetalert';

import { showErrorNotification, showNotification } from "utilities/notifications";
import I18n from "retrospring/i18n";

export function blockAnonEventHandler(event: Event): void {
  event.preventDefault();
  
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

    post('/ajax/block_anon', {
      body: data,
      contentType: 'application/json'
    })
      .then(async response => {
        const data = await response.json;

        if (!data.success) return false;

        showNotification(data.message);
      })
      .catch(err => {
        console.log(err);
        showErrorNotification(I18n.translate('frontend.error.message'));
      });
  });
}