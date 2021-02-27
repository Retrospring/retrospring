import 'bootstrap';
import $ from 'jquery';

/**
 * This module sets up Bootstrap's JavaScript
 *
 * Inside of the exported function below, initialize Bootstrap
 * modules that require explicit initilization, like tooltips
 */
export default function (): void {
  $(document).ready(() => {
    $('[data-toggle="tooltip"]').tooltip();
    $('.dropdown-toggle').dropdown();
  });
}
