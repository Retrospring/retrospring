export function commentCharacterHandler(event: Event): void {
  const input = event.target as HTMLInputElement;
  const id = input.dataset.id;
  const counter = document.querySelector(`#mod-comment-charcount-${id}`);
  const group = document.querySelector(`[name=mod-comment-new-group][data-id="${id}"]`);

  if (group.classList.contains('has-error')) {
    group.classList.remove('has-error');
  }

  counter.innerHTML = String(160 - input.value.length);
  if (Number(counter.innerHTML) < 0) {
    counter.classList.remove('text-muted');
    counter.classList.add('text-danger');
  } else {
    counter.classList.remove('text-danger');
    counter.classList.add('text-muted');
  }
}