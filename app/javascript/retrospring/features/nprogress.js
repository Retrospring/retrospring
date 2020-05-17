import NProgress from 'nprogress';

/**
 * This method sets up nProgress to listen on the Turbolinks
 * site navigation events
 */
export default function nProgressSetup() {
  NProgress.configure({
    showSpinner: false
  });

  document.addEventListener('page:fetch', () => { NProgress.start(); });
  document.addEventListener('page:change', () => { NProgress.done(); });
  document.addEventListener('page:restore', () => { NProgress.remove(); });
}
