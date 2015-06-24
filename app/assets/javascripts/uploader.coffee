$.fn.uploader = (options) ->
  defaultOptions =
    root:                    @
    progressBar:             null
    model:                   null
    success:                 ->
    directUploadUrl:         null
    directUploadFormData:    null
    maxProcessingCheckCount: 30
  options = $.extend({}, defaultOptions, options)

  progressBarContainer = options.progressBar
  progressBar          = progressBarContainer.find(".progress-bar")
  helpMessage          = options.root.find("span.help-block")
  uploadButton         = options.root.find("input[type='file']")
  uploadButtonSpan     = options.root.find("span.btn-file")
  processingCheckCount = 0

  # ****************************
  # CALLBACKS
  # ****************************

  resetProgressBar = () ->
    progressBarContainer.show()
    progressBar.css('width', '0%')
    progressBar.removeClass("error")
    helpMessage.hide()

  periodicProgressUpdate = (data) ->
    maxPercent = 50
    currentPercent = parseInt(data.loaded / data.total * maxPercent, 10)
    progressUpdate(currentPercent + '%')

  progressUpdate = (percent) ->
    progressBar.css('width', percent)

  delayedProgressUpdate = (percent, delayMs) ->
    setTimeout ->
      progressUpdate(percent)
    , delayMs

  markProgressBarAsFailed = () ->
    progressBar.addClass("error")
    helpMessage.show()

  requestPostProcessing = (data) ->
    s3key          = $(data.jqXHR.responseXML).find("Key").text()
    processingUrl  = Routes.s3CallbackPath(options.model) + '?key=' + s3key
    $.ajax
      url: processingUrl,
      success: (data) ->
        processingCheckCount = 0
        waitForProcessingToFinish(data["img_url"], 55)

  waitForProcessingToFinish = (imageUrl, percent) ->
    progressUpdate(percent + '%')

    randomTimeout = Math.floor((Math.random() * 2000) + 1000)
    incrementPrecent = (100 - percent) / 4

    checkProcessingStatusTimeout = setTimeout ->
      if processingCheckCount < options.maxProcessingCheckCount
        processingCheckCount = processingCheckCount + 1
        $.ajax
          url: imageUrl
          success: (data) ->
            clearTimeout(checkProcessingStatusTimeout)
            processingSuccess(imageUrl)
          error: ->
            waitForProcessingToFinish(imageUrl, percent + incrementPrecent)
      else
        clearTimeout(checkProcessingStatusTimeout)
        disableUploadButton(false)
        markProgressBarAsFailed()
    , randomTimeout

  processingSuccess = (imageUrl) ->
    setTimeout ->
      options.success(imageUrl)
      disableUploadButton(false)
    , 1000
    delayedProgressUpdate('100%', 1000);
    setTimeout ->
      progressBarContainer.hide()
    , 2500

  disableUploadButton = (disable) ->
    uploadButton.attr("disabled", disable)
    uploadButtonSpan.toggleClass("disabled", disable)

  # ****************************
  # END CALLBACKS
  # ****************************

  uploadButton.fileupload
    url:              options.directUploadUrl,
    type:             'POST',
    autoUpload:       true,
    paramName:        'file',
    dataType:         'XML',
    replaceFileInput: false,

    add: (e, data) ->
      formData = options.directUploadFormData
      formData["Content-Type"] = data.files[0].type
      data.formData = formData
      data.submit()

    start: (e, data) ->
      resetProgressBar()
      disableUploadButton(true)

    progressall: (e, data) ->
      periodicProgressUpdate(data)

    done: (e, data) ->
      requestPostProcessing(data)

    fail: (e, data) ->
      markProgressBarAsFailed()
      disableUploadButton(false)

  options.root
