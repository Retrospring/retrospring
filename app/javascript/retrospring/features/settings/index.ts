import registerEvents from "utilities/registerEvents";
import { profileHeaderChangeHandler, profilePictureChangeHandler } from "./crop";
import { userSubmitHandler } from "./password";

export default (): void => {
  registerEvents([
    { type: 'submit', target: document.querySelector('#edit_user'), handler: userSubmitHandler },
    { type: 'change', target: document.querySelector('#user_profile_picture[type=file]'), handler: profilePictureChangeHandler },
    { type: 'change', target: document.querySelector('#user_profile_header[type=file]'), handler: profileHeaderChangeHandler }
  ]);
}
