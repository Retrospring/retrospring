require('../styles/application.scss');
import initialize from './initializers';

export default function start(): void {
  try {
    initialize();
  } catch (e) {
    // initialization errors
  }
}
