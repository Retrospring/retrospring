import Toastify from 'toastify-js';

export function showNotification(text: string): void {
  Toastify({
    text: text,
    backgroundColor: 'var(--success)'
  }).showToast();
}

export function showErrorNotification(text: string): void {
  Toastify({
    text: text,
    backgroundColor: 'var(--danger)'
  }).showToast();
}
