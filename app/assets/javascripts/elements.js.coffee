$ ->
  $(document)
    .on 'click', '.browse-image-preview', (event) ->
      event.preventDefault()
      $(@).closest('.image_preview').find("input[type='file']").click()
