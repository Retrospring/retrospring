interface EventDef {
  type: string;
  target: Node | NodeList;
  handler: EventListenerOrEventListenerObject;
}

export default function registerEvents(events: EventDef[]): void {
  events.forEach(event => {
    if (event.target instanceof NodeList) {
      event.target.forEach(element => {
        element.addEventListener(event.type, event.handler);
      });
    } else if (event.target instanceof Node) {
      event.target.addEventListener(event.type, event.handler);
    }
  });
}
