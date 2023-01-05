export function commentToggleHandler(event: Event): void {
  const button = event.target as HTMLButtonElement;
  const id = button.dataset.aId;

  document.querySelector(`#ab-comments-section-${id}`).classList.toggle('d-none');
}