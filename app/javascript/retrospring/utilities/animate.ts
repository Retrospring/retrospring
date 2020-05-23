function animateNodeList(resolve: Function, target: NodeList, animationClasses: string[]): void {
  const elementCount: number = target.length;
  let animationEndedCount = 0;

  target.forEach((element: HTMLElement) => {
    element.classList.add(...animationClasses);

    element.addEventListener('animationend', () => {
      animationEndedCount += 1;

      element.classList.remove(...animationClasses);

      if (animationEndedCount === elementCount) {
        resolve(target);
      }
    });
  });
}

function animateNode(resolve: Function, target: Node, animationClasses: string[]): void {
  const element: HTMLElement = (target as HTMLElement);
  element.classList.add(...animationClasses);

  element.addEventListener('animationend', () => {
    element.classList.remove(...animationClasses);

    resolve(target);
  });
}

/**
 * Animate given target element(s) with an animate.css (conform) animation.
 * Resolves into a promise once all animations have ended.
 * 
 * @param target {Node | NodeList} target elements to be animation
 * @param animationName {string} name of the animation to be applied
 */
export default function animate(target: Node | NodeList, animationName: string): Promise<Node | NodeList> {
  return new Promise((resolve) => {
    const animationClasses: string[] = ['animate__animated', `animate__${animationName}`];

    if (target instanceof NodeList) {
      animateNodeList(resolve, target, animationClasses);
    }
    else if (target instanceof Node) {
      animateNode(resolve, target, animationClasses);
    }
  });
}
