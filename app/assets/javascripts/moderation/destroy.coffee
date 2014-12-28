$(document).on "click", "button[name=mod-delete-report]", ->
  if confirm 'Are you sure?'
    btn = $(this)
    id = btn[0].dataset.id
    $.ajax
      url: '/ajax/mod/destroy_report'
      type: 'POST'
      data:
        id: id
      success: (data, status, jqxhr) ->
        if data.success
          $("div.moderationbox[data-id=#{id}]").slideUp()
        showNotification data.message, data.success
      error: (jqxhr, status, error) ->
        console.log jqxhr, status, error
        showNotification "An error occurred, a developer should check the console for details", false
      complete: (jqxhr, status) ->