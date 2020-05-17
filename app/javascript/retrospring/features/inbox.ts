import Rails from '@rails/ujs';

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
  })
}

export default (): void => registerEvents([
  { type: 'click', target: document.querySelector('#ib-generate-question'), handler: generateQuestionHandler }
]);
