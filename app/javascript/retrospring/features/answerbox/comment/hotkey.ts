export function commentHotkeyHandler(event: Event): void {
  const button = event.target as HTMLButtonElement;
  const id = button.dataset.aId;

  document.querySelector(`#ab-comments-section-${id}`).classList.remove('d-none');
  document.querySelector<HTMLElement>(`[name="ab-comment-new"][data-a-id="${id}"]`).focus();
}
