import Rails from '@rails/ujs';
import swal from 'sweetalert';

import I18n from '../i18n';
import registerEvents from '../utilities/registerEvents';

export function generateQuestionHandler(): void {
  Rails.ajax({
    url: '/ajax/generate_question',
    type: 'POST',
    dataType: 'json',
    success: (data) => {
      if (!data.success) return false;

      document.querySelector('#entries').insertAdjacentHTML('afterbegin', data.render);
    },
    error: (data, status, xhr) => {
      console.log(data, status, xhr);
    }
  });
}

export function deleteAllQuestionsHandler(event: Event): void {
  const button = event.currentTarget as Element;
  const count = button.getAttribute('data-ib-count');

  swal({
    title: I18n.t('frontend.inbox.confirm_all.title', { count: count }),
    text: I18n.t('frontend.inbox.confirm_all.text'),
    icon: 'warning',
    dangerMode: true,
    buttons: [
      I18n.t('views.actions.cancel'),
      I18n.t('views.actions.delete')
    ]
  })
  .then((returnValue) => {
    if (returnValue === null) return false;
    
    Rails.ajax({
      url: '/ajax/delete_all_inbox',
      type: 'POST',
      dataType: 'json',
      success: (data) => {
        if (!data.success) return false;
  
        document.querySelector('#entries').innerHTML = 'Nothing to see here!';
      },
      error: (data, status, xhr) => {
        console.log(data, status, xhr);
      }
    });
  });
}

export default (): void => registerEvents([
  { type: 'click', target: document.querySelector('#ib-generate-question'), handler: generateQuestionHandler },
  { type: 'click', target: document.querySelector('#ib-delete-all'), handler: deleteAllQuestionsHandler }
]);
