$ ->
  init = ->
    $(".uploader.member-avatar").uploader(
      progressBar: $(".progress")
      directUploadUrl: gon.directUploadUrl
      directUploadFormData: gon.directUploadFormData
      model: gon.model
      success: (imageUrl) ->
        $("img.member-avatar").prop("src", imageUrl)
        $("img.navbar-avatar").prop("src", imageUrl)
    )

  $(document).on 'ujs', ->
    init()
