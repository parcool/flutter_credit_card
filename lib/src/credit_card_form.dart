import 'package:flutter/material.dart';
import 'package:flutter_credit_card/src/utils/helpers.dart';

import '../flutter_credit_card.dart';
import 'masked_text_controller.dart';
import 'utils/constants.dart';
import 'utils/typedefs.dart';
import 'utils/validators.dart';

class CreditCardForm extends StatefulWidget {
  const CreditCardForm({
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvvCode,
    required this.bankName,
    required this.onCreditCardModelChange,
    this.formKey,
    this.obscureCvv = false,
    this.obscureNumber = false,
    this.inputConfiguration = const InputConfiguration(),
    this.cardNumberKey,
    this.cardHolderKey,
    this.bankNameKey,
    this.expiryDateKey,
    this.cvvCodeKey,
    this.cvvValidationMessage = AppConstants.cvvValidationMessage,
    this.dateValidationMessage = AppConstants.dateValidationMessage,
    this.numberValidationMessage = AppConstants.numberValidationMessage,
    this.isBankNameVisible = true,
    this.isHolderNameVisible = true,
    this.isCardNumberVisible = true,
    this.isExpiryDateVisible = true,
    this.enableCvv = true,
    this.autovalidateMode,
    this.cardNumberValidator,
    this.expiryDateValidator,
    this.cvvValidator,
    this.cardHolderValidator,
    this.bankNameValidator,
    this.onFormComplete,
    this.disableCardNumberAutoFillHints = false,
    super.key,
  });

  /// A string indicating card number in the text field.
  final String cardNumber;

  /// A string indicating expiry date in the text field.
  final String expiryDate;

  /// A string indicating card holder name in the text field.
  final String cardHolderName;

  /// A string indicating cvv code in the text field.
  final String cvvCode;

  /// A string indicating bank name code in the text field.
  final String bankName;

  /// Error message string when invalid cvv is entered.
  final String cvvValidationMessage;

  /// Error message string when invalid expiry date is entered.
  final String dateValidationMessage;

  /// Error message string when invalid credit card number is entered.
  final String numberValidationMessage;

  /// Provides callback when there is any change in [CreditCardModel].
  final CCModelChangeCallback onCreditCardModelChange;

  /// When enabled cvv gets hidden with obscuring characters. Defaults to
  /// false.
  final bool obscureCvv;

  /// When enabled credit card number get hidden with obscuring characters.
  /// Defaults to false.
  final bool obscureNumber;

  /// Allow editing the holder name by enabling this in the credit card form.
  /// Defaults to true.
  final bool isHolderNameVisible;

  /// is bank name visible
  final bool isBankNameVisible;

  /// Allow editing the credit card number by enabling this in the credit
  /// card form. Defaults to true.
  final bool isCardNumberVisible;

  /// Allow editing the cvv code by enabling this in the credit card form.
  /// Defaults to true.
  final bool enableCvv;

  /// Allows editing the expiry date by enabling this in the credit
  /// card form. Defaults to true.
  final bool isExpiryDateVisible;

  /// A form state key for this credit card form.
  final GlobalKey<FormState>? formKey;

  /// Provides a callback when text field provides callback in
  /// [onEditingComplete].
  final Function? onFormComplete;

  /// A FormFieldState key for card number text field.
  final GlobalKey<FormFieldState<String>>? cardNumberKey;

  /// A FormFieldState key for card holder text field.
  final GlobalKey<FormFieldState<String>>? cardHolderKey;

  /// A FormFieldState key for bank name text field.
  final GlobalKey<FormFieldState<String>>? bankNameKey;

  /// A FormFieldState key for expiry date text field.
  final GlobalKey<FormFieldState<String>>? expiryDateKey;

  /// A FormFieldState key for cvv code text field.
  final GlobalKey<FormFieldState<String>>? cvvCodeKey;

  /// Provides [InputDecoration] and [TextStyle] to [CreditCardForm]'s [TextField].
  final InputConfiguration inputConfiguration;

  /// Used to configure the auto validation of [FormField] and [Form] widgets.
  final AutovalidateMode? autovalidateMode;

  /// A validator for card number text field.
  final ValidationCallback? cardNumberValidator;

  /// A validator for expiry date text field.
  final ValidationCallback? expiryDateValidator;

  /// A validator for cvv code text field.
  final ValidationCallback? cvvValidator;

  /// A validator for card holder text field.
  final ValidationCallback? cardHolderValidator;

  final ValidationCallback? bankNameValidator;

  /// Setting this flag to true will disable autofill hints for Credit card
  /// number text field. Flutter has a bug when auto fill hints are enabled for
  /// credit card numbers it shows keyboard with characters. But, disabling
  /// auto fill hints will show correct keyboard.
  ///
  /// Defaults to false.
  ///
  /// You can follow the issue here
  /// [https://github.com/flutter/flutter/issues/104604](https://github.com/flutter/flutter/issues/104604).
  final bool disableCardNumberAutoFillHints;

  @override
  State<CreditCardForm> createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  late String cardNumber;
  late String expiryDate;
  late String cardHolderName;
  late String cvvCode;
  late String bankName;
  bool isCvvFocused = false;

  late final CreditCardModel creditCardModel;
  late final CCModelChangeCallback onCreditCardModelChange =
      widget.onCreditCardModelChange;

  late MaskedTextController _cardNumberController;

  late TextEditingController _expiryDateController;

  late TextEditingController _cardHolderNameController;

  late TextEditingController _bankNameController;

  late TextEditingController _cvvCodeController;

  final FocusNode cvvFocusNode = FocusNode();
  final FocusNode expiryDateNode = FocusNode();
  final FocusNode cardHolderNode = FocusNode();
  final FocusNode bankNameNode = FocusNode();

  void initTextControllers() {
    _cardNumberController = MaskedTextController(
      mask: AppConstants.cardNumberMask,
      text: widget.cardNumber,
    );
    _expiryDateController = MaskedTextController(
      mask: AppConstants.expiryDateMask,
      text: widget.expiryDate,
    );
    _cardHolderNameController = TextEditingController(
      text: widget.cardHolderName,
    );
    _bankNameController = TextEditingController(
      text: widget.bankName,
    );
    _cvvCodeController = MaskedTextController(
      mask: AppConstants.cvvMask,
      text: widget.cvvCode,
    );
  }

  @override
  void initState() {
    super.initState();
    initTextControllers();
    createCreditCardModel();
    cvvFocusNode.addListener(textFieldFocusDidChange);
  }

  void resetControllersValue() {
    _cardNumberController.text = widget.cardNumber;
    _expiryDateController.text = widget.expiryDate;
    _cardHolderNameController.text = widget.cardHolderName;
    _bankNameController.text = widget.bankName;
    _cvvCodeController.text = widget.cvvCode;
  }


  @override
  Widget build(BuildContext context) {
    resetControllersValue();
    return Form(
      key: widget.formKey,
      child: Column(
        children: <Widget>[
          Visibility(
            visible: widget.isCardNumberVisible,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              margin: const EdgeInsets.only(left: 8, top: 0, right: 8),
              child: TextFormField(
                key: widget.cardNumberKey,
                obscureText: widget.obscureNumber,
                controller: _cardNumberController,
                onChanged: _onCardNumberChange,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(expiryDateNode),
                decoration: widget.inputConfiguration.cardNumberDecoration,
                style: widget.inputConfiguration.cardNumberTextStyle,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                autofillHints: widget.disableCardNumberAutoFillHints
                    ? null
                    : const <String>[AutofillHints.creditCardNumber],
                autovalidateMode: widget.autovalidateMode,
                validator: widget.cardNumberValidator ??
                    (String? value) => Validators.cardNumberValidator(
                          value,
                          widget.numberValidationMessage,
                        ),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Visibility(
                visible: widget.isExpiryDateVisible,
                child: Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                    margin: const EdgeInsets.only(left: 8, top: 0, right: 8),
                    child: TextFormField(
                      key: widget.expiryDateKey,
                      controller: _expiryDateController,
                      onChanged: _onExpiryDateChange,
                      focusNode: expiryDateNode,
                      onEditingComplete: () =>
                          FocusScope.of(context).requestFocus(cvvFocusNode),
                      decoration:
                          widget.inputConfiguration.expiryDateDecoration,
                      style: widget.inputConfiguration.expiryDateTextStyle,
                      autovalidateMode: widget.autovalidateMode,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[
                        AutofillHints.creditCardExpirationDate
                      ],
                      validator: widget.expiryDateValidator ??
                          (String? value) => Validators.expiryDateValidator(
                                value,
                                widget.dateValidationMessage,
                              ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Visibility(
                  visible: widget.enableCvv,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                    margin: const EdgeInsets.only(left: 8, top: 0, right: 8),
                    child: TextFormField(
                      key: widget.cvvCodeKey,
                      obscureText: widget.obscureCvv,
                      focusNode: cvvFocusNode,
                      controller: _cvvCodeController,
                      onEditingComplete: _onCvvEditComplete,
                      decoration: widget.inputConfiguration.cvvCodeDecoration,
                      style: widget.inputConfiguration.cvvCodeTextStyle,
                      keyboardType: TextInputType.number,
                      autovalidateMode: widget.autovalidateMode,
                      textInputAction: widget.isHolderNameVisible
                          ? TextInputAction.next
                          : TextInputAction.done,
                      autofillHints: const <String>[
                        AutofillHints.creditCardSecurityCode
                      ],
                      onChanged: _onCvvChange,
                      validator: widget.cvvValidator ??
                          (String? value) => Validators.cvvValidator(
                                value,
                                widget.cvvValidationMessage,
                              ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Visibility(
            visible: widget.isHolderNameVisible,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              margin: const EdgeInsets.only(left: 8, top: 0, right: 8),
              child: TextFormField(
                key: widget.cardHolderKey,
                controller: _cardHolderNameController,
                onChanged: _onCardHolderNameChange,
                focusNode: cardHolderNode,
                decoration: widget.inputConfiguration.cardHolderDecoration,
                style: widget.inputConfiguration.cardHolderTextStyle,
                keyboardType: TextInputType.text,
                autovalidateMode: widget.autovalidateMode,
                textInputAction: widget.isBankNameVisible
                    ? TextInputAction.next
                    : TextInputAction.done,
                autofillHints: const <String>[AutofillHints.creditCardName],
                onEditingComplete: _onHolderNameEditComplete,
                validator: widget.cardHolderValidator,
              ),
            ),
          ),
          Visibility(
            visible: widget.isBankNameVisible,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              margin: const EdgeInsets.only(left: 8, top: 0, right: 8),
              child: TextFormField(
                key: widget.bankNameKey,
                controller: _bankNameController,
                onChanged: _onBankNameChange,
                focusNode: bankNameNode,
                decoration: widget.inputConfiguration.bankNameDecoration,
                style: widget.inputConfiguration.bankNameTextStyle,
                keyboardType: TextInputType.text,
                autovalidateMode: widget.autovalidateMode,
                textInputAction: TextInputAction.done,
                autofillHints: const <String>[AutofillHints.creditCardName],
                onEditingComplete: _onBankNameEditComplete,
                validator: widget.bankNameValidator,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cardHolderNode.dispose();
    cvvFocusNode.dispose();
    expiryDateNode.dispose();
    super.dispose();
  }

  void textFieldFocusDidChange() {
    isCvvFocused = creditCardModel.isCvvFocused = cvvFocusNode.hasFocus;

    onCreditCardModelChange(creditCardModel);
  }

  void createCreditCardModel() {
    cardNumber = widget.cardNumber;
    expiryDate = widget.expiryDate;
    cardHolderName = widget.cardHolderName;
    cvvCode = widget.cvvCode;
    bankName = widget.bankName;

    creditCardModel = CreditCardModel(
      cardNumber,
      expiryDate,
      cardHolderName,
      cvvCode,
      isCvvFocused,
      bankName,
      detectCCType(cardNumber).name,
    );
  }

  void _onCardNumberChange(String value) {
    setState(() {
      creditCardModel.cardNumber = cardNumber = _cardNumberController.text;
      creditCardModel.type = detectCCType(cardNumber).name;
      onCreditCardModelChange(creditCardModel);
    });
  }

  void _onExpiryDateChange(String value) {
    final String expiry = _expiryDateController.text;
    _expiryDateController.text =
        expiry.startsWith(RegExp('[2-9]')) ? '0$expiry' : expiry;
    setState(() {
      creditCardModel.expiryDate = expiryDate = expiry;
      onCreditCardModelChange(creditCardModel);
    });
  }

  void _onCvvChange(String text) {
    setState(() {
      creditCardModel.cvvCode = cvvCode = text;
      onCreditCardModelChange(creditCardModel);
    });
  }

  void _onBankNameChange(String text) {
    setState(() {
      creditCardModel.bankName = bankName = text;
      onCreditCardModelChange(creditCardModel);
    });
  }

  void _onCardHolderNameChange(String value) {
    setState(() {
      creditCardModel.cardHolderName =
          cardHolderName = _cardHolderNameController.text;
      onCreditCardModelChange(creditCardModel);
    });
  }

  void _onCvvEditComplete() {
    if (widget.isHolderNameVisible) {
      FocusScope.of(context).requestFocus(cardHolderNode);
    } else {
      FocusScope.of(context).unfocus();
      onCreditCardModelChange(creditCardModel);
      widget.onFormComplete?.call();
    }
  }

  void _onHolderNameEditComplete() {
    if (widget.isBankNameVisible) {
      FocusScope.of(context).requestFocus(bankNameNode);
    } else {
      FocusScope.of(context).unfocus();
      onCreditCardModelChange(creditCardModel);
      widget.onFormComplete?.call();
    }
  }

  void _onBankNameEditComplete() {
    FocusScope.of(context).unfocus();
    onCreditCardModelChange(creditCardModel);
    widget.onFormComplete?.call();
  }
}
