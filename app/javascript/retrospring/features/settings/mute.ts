import Rails from '@rails/ujs';

export function createSubmitEvent(
  submit: HTMLButtonElement,
  rulesList: HTMLDivElement,
  textEntry: HTMLButtonElement,
  template: HTMLTemplateElement
): (event: Event) => void {
  return (event) => {
    event.preventDefault();
    submit.disabled = true;

    Rails.ajax({
      url: '/ajax/mute',
      type: 'POST',
      dataType: 'json',
      data: new URLSearchParams({muted_phrase: textEntry.value}).toString(),
      success: (data) => {
        submit.disabled = false;
        if (!data.success) return;

        const newEntryFragment = template.content.cloneNode(true) as Element;
        newEntryFragment.querySelector<HTMLInputElement>('input').value = textEntry.value;
        newEntryFragment.querySelector<HTMLButtonElement>('button').dataset.id = String(data.id);

        rulesList.appendChild(newEntryFragment)

        textEntry.value = ''
      }
    });
  };
}