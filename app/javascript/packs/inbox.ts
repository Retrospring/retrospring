import initializeInboxEvents from 'retrospring/features/inbox';

document.addEventListener('turbolinks:load', () => initializeInboxEvents());
