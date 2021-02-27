$(document).on 'ready turbolinks:load', ->
  if $('#pagination').length > 0
    $('#pagination').hide()
    loading_posts = false

    $('#load-more-btn').show().click ->
      unless loading_posts
        loading_posts = true
        more_posts_url = $('#pagination .pagination .next a').attr('href')
        $this = $(this)
        $this.html('<i class="fa fa-spinner fa-spin"></i>').addClass('disabled')
        $.getScript more_posts_url, ->
          $this.text('Load more').removeClass('disabled') if $this
          loading_posts = false
          $('[data-toggle="tooltip"]').tooltip()
      return
