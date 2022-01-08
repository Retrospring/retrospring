import Rails from '@rails/ujs';

import I18n from '../../../legacy/i18n';
import { showNotification, showErrorNotification } from 'utilities/notifications';

export function privilegeCheckHandler(event: Event): void {
  const checkbox = event.target as HTMLInputElement;
  checkbox.disabled = true;

  const privilegeType = checkbox.dataset.type;

  Rails.ajax({
    url: '/ajax/mod/privilege',
    type: 'POST',
    data: new URLSearchParams({
      user: checkbox.dataset.user,
      type: privilegeType,
      status: String(checkbox.checked)
    }).toString(),
    success: (data) => {
      if (data.success) {
        checkbox.checked = data.checked;
      }

      showNotification(data.message, data.success);
    },
    error: (data, status, xhr) => {
      console.log(data, status, xhr);
      showErrorNotification(I18n.translate('frontend.error.message'));
      checkbox.checked = false;
    },
    complete: () => {
      checkbox.disabled = false;
    }
  });


  /*
  ($ document).on "click", "input[type=checkbox][name=check-your-privileges]", ->
  box = $(this)
  box.attr 'disabled', 'disabled'

  privType = box[0].dataset.type
  boxChecked = box[0].checked

  $.ajax
    url: '/ajax/mod/privilege'
    type: 'POST'
    data:
      user: box[0].dataset.user
      type: privType
      status: boxChecked
    success: (data, status, jqxhr) ->
      if data.success
        box[0].checked = if data.checked? then data.checked else !boxChecked
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      box[0].checked = false
      console.log jqxhr, status, error
      showNotification translate('frontend.error.message'), false
    complete: (jqxhr, status) ->
      box.removeAttr "disabled"
  */
}