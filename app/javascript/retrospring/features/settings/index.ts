import registerEvents from "utilities/registerEvents";
import { muteDocumentHandler } from "./mute";
import { profileHeaderChangeHandler, profilePictureChangeHandler } from "./crop";
import { themeDocumentHandler, themeSubmitHandler } from "./theme";
import { userSubmitHandler } from "./password";
import { unblockAnonymousHandler } from "./block";

export default (): void => {
  muteDocumentHandler();
  themeDocumentHandler();

  registerEvents([
    { type: 'submit', target: document.querySelector('form.edit_theme, form.new_theme'), handler: themeSubmitHandler },
    { type: 'submit', target: document.querySelector('#edit_user'), handler: userSubmitHandler },
    { type: 'change', target: document.querySelector('#user_profile_picture[type=file]'), handler: profilePictureChangeHandler },
    { type: 'change', target: document.querySelector('#user_profile_header[type=file]'), handler: profileHeaderChangeHandler },
    { type: 'click', target: document.querySelectorAll('[data-action="anon-unblock"]'), handler: unblockAnonymousHandler }
  ]);
}