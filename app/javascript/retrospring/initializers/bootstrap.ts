import * as bootstrap from 'bootstrap';

/**
 * This module sets up Bootstrap's JavaScript
 *
 * Inside of the exported function below, initialize Bootstrap
 * modules that require explicit initilization, like tooltips
 */
export default function (): void {
  document.addEventListener('turbo:load', () => {
    const dropdownElementList = document.querySelectorAll('[data-bs-toggle="dropdown"]');
    [...dropdownElementList].map(dropdownToggleEl => new bootstrap.Dropdown(dropdownToggleEl));

    // HACK/BUG?: Bootstrap disables dropdowns in navbars, here we re-enable and "kinda" fix it
    // By the time Bootstrap 6 releases this probably won't be needed anymore
    const navigationElementList = document.querySelectorAll('#rs-mobile-nav .nav-link[data-bs-toggle="dropdown"]');
    [...navigationElementList].map(dropdownToggleEl => new bootstrap.Dropdown(dropdownToggleEl, {
      popperConfig(defaultPopperConfig) {
        return {
          ...defaultPopperConfig,
          strategy: 'fixed',
          modifiers: [
            {
              name: 'applyStyles',
              enabled: true
            },
            {
              name: 'preventOverflow',
              options: {
                boundary: document.querySelector('body')
              }
            },
          ]
        }
      }
    }));
  });
}
