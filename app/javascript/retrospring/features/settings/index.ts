import registerEvents from "utilities/registerEvents";
import { muteDocumentHandler } from "./mute";
import { profileHeaderChangeHandler, profilePictureChangeHandler } from "./crop";
import { themeDocumentHandler, themeSubmitHandler } from "./theme";
import { userSubmitHandler } from "./password";

export default (): void => {
  muteDocumentHandler();
  themeDocumentHandler();

  registerEvents([
    { type: 'submit', target: document.querySelector('#update_theme'), handler: themeSubmitHandler },
    { type: 'submit', target: document.querySelector('#edit_user'), handler: userSubmitHandler },
    { type: 'change', target: document.querySelector('#user_profile_picture[type=file]'), handler: profilePictureChangeHandler },
    { type: 'change', target: document.querySelector('#user_profile_header[type=file]'), handler: profileHeaderChangeHandler }
  ]);
}