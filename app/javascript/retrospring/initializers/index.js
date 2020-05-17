/**
 * Using some JavaScript trickery with require.context
 * and default exports, we're basically rebuilding the
 * Rails concept of "initializers" in JavaScript.
 * 
 * Every file in this folder exports a default function
 * which this index script is loading and executing, so
 * we don't have to specify several single import
 * statements and can dynamically extend this with as
 * many initializers as we see fit.
 */
export default function initialize() {
  const files = require.context('.', false, /\.js$/);
  
  files.keys().forEach((key) => {
    if (key === './index.js') return;
    files(key).default();
  });
}
