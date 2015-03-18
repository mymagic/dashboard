$ ->
  $(document)
    .on 'click', '.browse-image-preview', (event) ->
      event.preventDefault()
      $(@).closest('.image_preview').find("input[type='file']").click()

    .on 'change', ".image_preview input[type='file']", ->
      self = $(@)
      fileReader = new FileReader()
      fileReader.readAsDataURL event.target.files[0]

      fileReader.onload = (event) ->
        self.closest('.image_preview').find('img').prop('src', event.target.result)
