import Rails from '@rails/ujs';
import Turbolinks from 'turbolinks';

import initialize from './initializers';

export default function start() {
  try {
    Rails.start();
    Turbolinks.start();
    initialize();
  } catch (e) {
    // initialization errors
  }
}
