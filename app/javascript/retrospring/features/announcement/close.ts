export default function (event: Event): void {
  const announcement = (event.target as HTMLElement).closest(".announcement") as HTMLDivElement;
  const aId = announcement.dataset.announcementId;
  window.localStorage.setItem(`announcement${aId}`, 'true');
}