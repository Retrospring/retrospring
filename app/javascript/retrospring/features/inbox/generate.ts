import { post } from '@rails/request.js';

import I18n from 'retrospring/i18n';
import { updateDeleteButton } from './delete';
import { showErrorNotification } from 'utilities/notifications';

export function generateQuestionHandler(): void {
  post('/ajax/generate_question')
    .then(async response => {
      const data = await response.json;

      if (!data.success) return false;

      document.querySelector('#entries').insertAdjacentHTML('afterbegin', data.render);
      updateDeleteButton();
    })
    .catch(err => {
      console.log(err);
      showErrorNotification(I18n.translate('frontend.error.message'));      
    });
}