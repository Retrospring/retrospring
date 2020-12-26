import NProgress from 'nprogress';

/**
 * NProgress initializer method, setting up NProgress to work
 * on Turbolinks site navigation events
 */
export default function (): void {
  NProgress.configure({
    showSpinner: false,
  });

  document.addEventListener('page:fetch', () => { NProgress.start(); });
  document.addEventListener('page:change', () => { NProgress.done(); });
  document.addEventListener('page:restore', () => { NProgress.remove(); });
}