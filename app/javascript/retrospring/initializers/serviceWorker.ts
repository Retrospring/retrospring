export default function (): void {
  navigator.serviceWorker.register("/service_worker.js", { scope: "/" });
}
