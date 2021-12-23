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

export function createDeleteEvent(
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