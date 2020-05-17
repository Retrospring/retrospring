import Rails from '@rails/ujs';
import Turbolinks from 'turbolinks';

import nProgressSetup from './features/nprogress';

export default function start() {
  try {
    Rails.start();
    Turbolinks.start();
    nProgressSetup();
  } catch (e) {
    // initialization errors
  }
}
