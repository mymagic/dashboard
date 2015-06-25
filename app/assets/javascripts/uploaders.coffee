$ ->
  init = ->
    $(".uploader.member-avatar").uploader(
      progressBar: $(".progress")
      directUploadUrl: gon.directUploadUrl
      directUploadFormData: gon.directUploadFormData
      model: gon.model
      id: gon.id
      success: (imageUrl) ->
        $("img.member-avatar").prop("src", imageUrl)
    )

    $(".uploader.company-logo").uploader(
      progressBar: $(".progress")
      directUploadUrl: gon.directUploadUrl
      directUploadFormData: gon.directUploadFormData
      model: gon.model
      id: gon.id
      success: (imageUrl) ->
        $("img.company-logo").prop("src", imageUrl)
    )

  $(document).on 'ujs', -> init()
