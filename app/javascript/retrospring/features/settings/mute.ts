import Rails from '@rails/ujs';

function createSubmitEvent(
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
        const newDeleteButton = newEntryFragment.querySelector<HTMLButtonElement>('button')
        newDeleteButton.dataset.id = String(data.id);
        newDeleteButton.onclick = createDeleteEvent(
          newEntryFragment.querySelector('.form-group'),
          newDeleteButton
        )

        rulesList.appendChild(newEntryFragment)

        textEntry.value = ''
      }
    });
  };
}

function createDeleteEvent(
  entry: HTMLDivElement,
  deleteButton: HTMLButtonElement
): () => void {
  return () => {
    deleteButton.disabled = true;

    Rails.ajax({
      url: '/ajax/mute/' + deleteButton.dataset.id,
      type: 'DELETE',
      dataType: 'json',
      success: (data) => {
        if (data.success) {
          entry.parentElement.removeChild(entry)
        } else {
          deleteButton.disabled = false;
        }
      }
    })
  }
}

export function muteDocumentHandler(): void {
  const submit: HTMLButtonElement = document.getElementById('new-rule-submit') as HTMLButtonElement;
  if (!submit || submit.classList.contains('js-initialized')) return;

  const rulesList = document.querySelector<HTMLDivElement>('.js-rules-list');
  rulesList.querySelectorAll<HTMLDivElement>('.form-group:not(.js-initalized)').forEach(entry => {
    const button = entry.querySelector('button')
    button.onclick = createDeleteEvent(entry, button)
  });
  const textEntry: HTMLButtonElement = document.getElementById('new-rule-text') as HTMLButtonElement;
  const template: HTMLTemplateElement = document.getElementById('rule-template') as HTMLTemplateElement;

  submit.form.onsubmit = createSubmitEvent(submit, rulesList, textEntry, template)

  submit.classList.add('js-initialized');
}