import { on, OnCallbackFunction } from './on';

export interface EventDef {
    type: string;
    target: Node | NodeList | string;
    handler: EventListenerOrEventListenerObject;
    global?: boolean;
}

export default function registerEvents(events: EventDef[]): void {
    events.forEach(event => {
        if (event.global) {
            if (typeof event.target === 'string') {
                on(event.type, event.target, event.handler as OnCallbackFunction);
            }
        } else if (event.target instanceof NodeList) {
            event.target.forEach((element: HTMLElement) => {
                if (!element.classList.contains('js-initialized')) {
                    element.addEventListener(event.type, event.handler);
                    element.classList.add('js-initialized');
                }
            });
        } else if (event.target instanceof Node) {
            if (!(event.target as HTMLElement).classList.contains('js-initialized')) {
                event.target.addEventListener(event.type, event.handler);
                (event.target as HTMLElement).classList.add('js-initialized');
            }
        }
    });
}