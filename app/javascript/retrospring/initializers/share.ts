import $ from 'jquery';

export default (): void => {
    document.addEventListener('turbolinks:load', function () {
        if (navigator.share) {
            document.body.classList.add('cap-web-share')
            $(document).on('click', 'button[name=ab-share]', function () {
                const card = $(this).closest('.card')

                navigator.share({
                    url: card.find('.answerbox__answer-date a')[0].href
                }).then(() => {
                    // do nothing, prevents exception from being thrown
                }).catch(() => {
                    // do nothing, prevents exception from being thrown
                })
            })
        }
    })
}