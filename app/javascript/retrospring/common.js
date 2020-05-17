import initialize from './initializers';

export default function start() {
  try {
    initialize();
  } catch (e) {
    // initialization errors
  }
}
