import Toastify from 'toastify-js';

export function showErrorNotification(text: string): void {
  showNotification(text, false);
}

export function showNotification(text: string, status = true): void {
  Toastify({
    text: text,
    style: {
      color: status ? 'rgb(var(--success-text))' :  'rgb(var(--danger-text))',
      background: status ? 'var(--success)' : 'var(--danger)' 
    }
  }).showToast();
}