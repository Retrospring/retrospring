import 'bootstrap';
import $ from 'jquery';

/**
 * This module sets up Bootstraps JavaScript
 * 
 * Inside of the exported function below, initialize Bootstrap
 * modules that require explicit initilization, like tooltips
 */
export default function() {
  $(document).ready(() => $('[data-toggle="tooltip"]').tooltip());
}
