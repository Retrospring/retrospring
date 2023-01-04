import * as Popper from '@popperjs/core';
import * as bootstrap from 'bootstrap';

/**
 * This module sets up Bootstrap's JavaScript
 *
 * Inside of the exported function below, initialize Bootstrap
 * modules that require explicit initilization, like tooltips
 */
export default function (): void {
  document.addEventListener('turbo:load', () => {
    const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));

    const dropdownElementList = document.querySelectorAll('.dropdown-toggle');
    const dropdownList = [...dropdownElementList].map(dropdownToggleEl => new bootstrap.Dropdown(dropdownToggleEl));
  });
}
