import '@hotwired/turbo-rails';
import initialize from './initializers';

export default function start(): void {
  try {
    initialize();
  } catch (e) {
    // initialization errors
  }
}