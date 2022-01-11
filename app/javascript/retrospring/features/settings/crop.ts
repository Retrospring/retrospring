import Croppr from 'croppr';

const readImage = (file, callback) => callback((window.URL || window.webkitURL).createObjectURL(file));

export function profilePictureChangeHandler(event: Event): void {
  const input = event.target as HTMLInputElement;

  const cropControls = document.querySelector('#profile-picture-crop-controls');
  cropControls.classList.toggle('d-none');

  if (input.files && input.files[0]) {
    readImage(input.files[0], (src) => {
      const updateValues = (data) => {
        document.querySelector<HTMLInputElement>('#profile_picture_x').value = data.x;
        document.querySelector<HTMLInputElement>('#profile_picture_y').value = data.y;
        document.querySelector<HTMLInputElement>('#profile_picture_w').value = data.width;
        document.querySelector<HTMLInputElement>('#profile_picture_h').value = data.height;
      }

      const cropper = document.querySelector<HTMLImageElement>('#profile-picture-cropper');
      cropper.src = src;

      new Croppr(cropper, {
        aspectRatio: 1,
        startSize: [100, 100, '%'],
        onCropStart: updateValues,
        onCropMove: updateValues,
        onCropEnd: updateValues
      });
    });
  }
}

export function profileHeaderChangeHandler(event: Event): void {
  const input = event.target as HTMLInputElement;

  const cropControls = document.querySelector('#profile-header-crop-controls');
  cropControls.classList.toggle('d-none');

  if (input.files && input.files[0]) {
    readImage(input.files[0], (src) => {
      const updateValues = (data) => {
        document.querySelector<HTMLInputElement>('#profile_header_x').value = data.x;
        document.querySelector<HTMLInputElement>('#profile_header_y').value = data.y;
        document.querySelector<HTMLInputElement>('#profile_header_w').value = data.width;
        document.querySelector<HTMLInputElement>('#profile_header_h').value = data.height;
      }

      const cropper = document.querySelector<HTMLImageElement>('#profile-header-cropper');
      cropper.src = src;

      new Croppr(cropper, {
        aspectRatio: 7/30,
        startSize: [100, 100, '%'],
        onCropStart: updateValues,
        onCropMove: updateValues,
        onCropEnd: updateValues
      });
    });
  }
}