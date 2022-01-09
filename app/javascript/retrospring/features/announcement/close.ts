export default function (event: Event): void {
  const announcement = (event.target as HTMLElement).closest(".announcement") as HTMLDivElement;
  const announcementId = announcement.dataset.announcementId;
  window.localStorage.setItem(`announcement${announcementId}`, 'true');
}