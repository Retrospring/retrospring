import { destroy, post } from '@rails/request.js';

function createSubmitEvent(
  submit: HTMLButtonElement,
  rulesList: HTMLDivElement,
  textEntry: HTMLButtonElement,
  template: HTMLTemplateElement
): (event: Event) => void {
  return (event) => {
    event.preventDefault();
    submit.disabled = true;

    post('/ajax/mute', {
      body: {
        muted_phrase: textEntry.value
      },
      contentType: 'application/json'
    })
      .then(async response => {
        const data = await response.json;

        submit.disabled = false;
        if (!data.success) return;

        const newEntryFragment = template.content.cloneNode(true) as Element;
        newEntryFragment.querySelector<HTMLInputElement>('input').value = textEntry.value;

        const newDeleteButton = newEntryFragment.querySelector<HTMLButtonElement>('button');
        newDeleteButton.dataset.id = String(data.id);
        newDeleteButton.onclick = createDeleteEvent(
          newEntryFragment.querySelector('.form-group'),
          newDeleteButton
        );

        rulesList.appendChild(newEntryFragment);
        textEntry.value = '';
      });
  };
}

function createDeleteEvent(
  entry: HTMLDivElement,
  deleteButton: HTMLButtonElement
): () => void {
  return () => {
    deleteButton.disabled = true;

    destroy(`/ajax/mute/${deleteButton.dataset.id}`)
      .then(async response => {
        const data = await response.json;

        if (data.success) {
          entry.parentElement.removeChild(entry)
        } else {
          deleteButton.disabled = false;
        }
      });
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