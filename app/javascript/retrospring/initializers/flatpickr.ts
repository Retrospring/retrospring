import flatpickr from 'flatpickr';

export default function (): void {
  document.addEventListener('turbolinks:load', () => flatpickr('.datetimepicker-input', {
    enableTime: true,
    dateFormat: 'Y-m-d H:i',
  }));
}
