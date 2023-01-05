export function userSubmitHandler(event: Event): void {
  if (document.querySelector<HTMLInputElement>('#user_current_password').value.length === 0) {
    event.preventDefault();
    document.querySelector<HTMLButtonElement>('[data-target="#modal-passwd"]').click();
  }
}