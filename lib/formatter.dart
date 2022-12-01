import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CustomTextInputFormatter {
  static List<TextInputFormatter> getDoubleFormatter({double? maxValue}) => [
        _DoubleTextInputFormatter(maxValue: maxValue),
        FilteringTextInputFormatter.allow(RegExp('[1234567890.]'))
      ];

  static List<TextInputFormatter> getIntFormatter({double? maxValue}) => [
        _IntTextInputFormatter(maxValue: maxValue),
        FilteringTextInputFormatter.allow(RegExp('[1234567890]'))
      ];
}

abstract class _BaseTextInputFormatter extends TextInputFormatter {
  double? maxValue;
  _BaseTextInputFormatter({this.maxValue});

  TextSelection _createTextSelection(
      TextSelection oldSelection, String oldText, String newText) {
    return TextSelection.collapsed(
        offset: oldSelection.baseOffset - (oldText.length - newText.length));
  }

  ///获取显示用的数字文本
  String getDisplayNumber(num? number) {
    if (number == null) return '0';
    String pattern = '###';

    List<String> arr = number.toString().split('\.');

    if (arr.length > 1) {
      if (arr[1].length >= 2) {
        if (arr[1] == '00') {
          pattern = "${pattern}0";
        } else {
          pattern = "${pattern}0.00";
        }
      } else {
        if (arr[1] == '0') {
          pattern = "${pattern}0";
        } else {
          pattern = "${pattern}0.0";
        }
      }
    } else {
      pattern = "${pattern}0";
    }

    return NumberFormat(pattern, "en_US").format(number);
  }

  String checkMaxValue(String value) {
    if (maxValue == null) {
      return value;
    }

    try {
      if (double.parse(value) > maxValue!) {
        return getDisplayNumber(maxValue);
      }
    } catch (e) {
      // print(e);
      // return value;
    }

    return value;
  }
}

///double
class _DoubleTextInputFormatter extends _BaseTextInputFormatter {
  double? maxValue;
  _DoubleTextInputFormatter({this.maxValue}) : super(maxValue: maxValue);

  static String? strToFloat(String str) {
    RegExp regexp = RegExp('^([0-9]+(.[0-9]{0,2})?)');
    if (regexp.hasMatch(str)) {
      return regexp.firstMatch(str)!.group(0);
    }

    return null;
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String oldText = oldValue.text;
    String newText = newValue.text;
    TextSelection textSelection = newValue.selection;
    // print(newText);
    String handleText = "";
    //这里是处理多个小数点
    if (newText.indexOf(".") != newText.lastIndexOf(".")) {
      newText = oldText;
      return new TextEditingValue(text: oldText, selection: oldValue.selection);
    }
    if (newText.endsWith(".")) {
      var text = newText.substring(0, newText.indexOf("."));
      var value = "0";
      for (var i = 0; i < text.length; i++) {
        var char = text.substring(i, i + 1);
        if (value == "0") {
          if (char != "0") {
            value = char;
          }
        } else {
          value += char;
        }
      }
      handleText = value + ".";
      textSelection = _createTextSelection(textSelection, newText, handleText);
    } else {
      handleText = newText;
    }

    String? newStr = strToFloat(handleText);
    if (newStr != null) {
      textSelection = _createTextSelection(textSelection, handleText, newStr);
      handleText = newStr;
    }

    var maxValue = checkMaxValue(handleText);
    textSelection = _createTextSelection(textSelection, handleText, maxValue);
    handleText = maxValue;

    return new TextEditingValue(text: handleText, selection: textSelection);
  }
}

///int
class _IntTextInputFormatter extends _BaseTextInputFormatter {
  double? maxValue;
  _IntTextInputFormatter({this.maxValue}) : super(maxValue: maxValue);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    var selection = newValue.selection;
    var finalText = checkMaxValue(newText);
    if (finalText.length != newText.length) {
      selection = _createTextSelection(selection, newText, finalText);
    }
    return new TextEditingValue(text: finalText, selection: selection);
  }
}
