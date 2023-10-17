export default function (): void {
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register("/service_worker.js", { scope: "/" });
  }
}
