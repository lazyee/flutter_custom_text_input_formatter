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
      print(e);
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

    int selectionIndex = newValue.selection.end;

    if (oldText == '0' && newText != "0." && newText != '') {
      newText = newText.substring(1, newText.length);
    } else if (newText == ".") {
      newText = "0.";
    } else {
      String? newStr = strToFloat(newText);
      if (newStr != null) {
        newText = newStr;
      }
    }

    newText = checkMaxValue(newText);
    selectionIndex = newText.length;

    return new TextEditingValue(
      text: newText,
      selection: new TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

///int
class _IntTextInputFormatter extends _BaseTextInputFormatter {
  double? maxValue;
  _IntTextInputFormatter({this.maxValue}) : super(maxValue: maxValue);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String oldText = oldValue.text;
    String newText = newValue.text;

    int selectionIndex = newValue.selection.end;

    if (oldText == '0') {
      newText = newText.substring(1, newText.length);
    }

    newText = checkMaxValue(newText);
    selectionIndex = newText.length;

    return new TextEditingValue(
      text: newText,
      selection: new TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
