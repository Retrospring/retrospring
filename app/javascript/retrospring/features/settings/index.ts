import registerEvents from "utilities/registerEvents";
import { userSubmitHandler } from "./password";

export default (): void => {
  registerEvents([
    { type: 'submit', target: document.querySelector('#edit_user'), handler: userSubmitHandler }
  ]);
}
