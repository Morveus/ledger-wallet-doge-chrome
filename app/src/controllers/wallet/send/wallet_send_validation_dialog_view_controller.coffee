class @WalletSendValidationDialogViewController extends @DialogViewController

  view:
    cardContainer: "#card_container"
    enteredCode: "#entered_code"
    validationIndication: "#validation_indication"
    validationSubtitle: "#validation_subtitle"
    keycard: undefined
    tinyPincode: undefined
  _validationDetails: undefined

  onAfterRender: ->
    super
    @_setupUI()
    @_updateUI()

  onShow: ->
    super
    @view.keycard.stealFocus()

  _setupUI: ->
    @view.keycard = new ledger.pin_codes.KeyCard()
    @view.tinyPincode = new ledger.pin_codes.TinyPinCode()
    @view.keycard.insertIn @view.cardContainer[0]
    @view.tinyPincode.insertIn @view.enteredCode[0]
    @_listenEvents()

  _updateUI: ->
    @_validationDetails = @params.transaction.getValidationDetails()
    @_validationDetails = _.extend @_validationDetails, @_buildValidableSettings(@_validationDetails)
    @view.keycard.setValidableValues @_validationDetails.validationCharacters
    @view.tinyPincode.setInputsCount @_validationDetails.validationCharacters.length
    if @_validationDetails.needsAmountValidation
      @view.validationSubtitle.text t 'wallet.send.validation.amount_and_address_to_validate'
    else
      @view.validationSubtitle.text t 'wallet.send.validation.address_to_validate'

  _updateValidableIndication: ->
    return if @_validationDetails.localizedIndexes.length == 0
    index = @_validationDetails.localizedIndexes[0]
    value = @_validationDetails.localizedString.slice(0, index)
    value += '<mark>'
    value += @_validationDetails.localizedString[index]
    value += '</mark>'
    remainingIndex = @_validationDetails.localizedString.length - index - 1
    if remainingIndex > 0
      value += @_validationDetails.localizedString.slice(-remainingIndex)
    @view.validationIndication.html value

  _buildValidableSettings: (validationDetails) ->
    string = ''
    indexes = []
    decal = 0
    # add amount
    if validationDetails.needsAmountValidation
      value = ledger.formatters.bitcoin.fromValue(validationDetails.amount.text, 3)
      string += value + ' BTC'
      indexes = indexes.concat validationDetails.amount.indexes[0]
      indexes = indexes.concat _.map(validationDetails.amount.indexes.slice(1), (num) => num + 1) # decalage virgule
      string += ' ' + t('wallet.send.validation.to') + ' '
    # add address
    decal += string.length
    string += validationDetails.recipientsAddress.text
    indexes = indexes.concat _.map(validationDetails.recipientsAddress.indexes, (num) => num + decal)
    {localizedString: string, localizedIndexes: indexes}

  _listenEvents: ->
    @view.keycard.once 'completed', (event, value) =>
      @once 'dismiss', =>
        dialog = new WalletSendProcessingDialogViewController transaction: @params.transaction, keycode: value
        dialog.show()
      @dismiss()
    @view.keycard.on 'character:input', (event, value) =>
      @view.tinyPincode.setValuesCount @view.keycard.value().length
      @_validationDetails.localizedIndexes.splice(0, 1)
    @view.keycard.on 'character:waiting', (event, value) =>
      @_updateValidableIndication()
    @once 'dismiss', =>
      @view.keycard.off 'completed'
      @view.keycard.off 'character:input'
      @view.keycard.off 'character:waiting'
