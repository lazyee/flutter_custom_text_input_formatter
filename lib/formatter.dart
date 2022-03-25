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

  static String removeAllIllegalChar(String str) {
    return str.replaceAll(RegExp("([^0-9.]+)"), "");
  }

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
    if (newText.indexOf(".") != newText.lastIndexOf(".")) {
      newText = oldText;
    }

    TextSelection textSelection = newValue.selection;
    if (oldText.startsWith("0") &&
        newText.startsWith("0") &&
        !newText.startsWith("0.")) {
      newText = newText.substring(1, newText.length);
    } else if (oldText.length > 0 &&
        newText.startsWith("0") &&
        !newText.startsWith("0.")) {
      newText = newText.substring(1, newText.length);
    } else if (newText == ".") {
      newText = "0.";
      textSelection = new TextSelection.collapsed(offset: newText.length);
    } else {
      newText = removeAllIllegalChar(newText);
      String? newStr = strToFloat(newText);
      if (newStr != null) {
        newText = newStr;
      }
    }

    newText = checkMaxValue(newText);

    return new TextEditingValue(
        text: newText,
        selection: newText == oldText ? oldValue.selection : textSelection);
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

    if (oldText.startsWith("0") && newText.startsWith("0")) {
      if (newText == "0.") {
        newText = "0";
      } else {
        newText = newText.substring(1, newText.length);
      }
    }

    newText = checkMaxValue(newText);
    return new TextEditingValue(text: newText, selection: newValue.selection);
  }
}

// int _getSelectionIndex(String newText, String oldText) {
//   if (newText.length < oldText.length) {
//     for (int i = 0; i < newText.length; i++) {
//       if (newText.codeUnitAt(i) != oldText.codeUnitAt(i)) {
//         return i;
//       }
//     }
//   } else {
//     for (int i = 0; i < oldText.length; i++) {
//       if (newText.length <= i) {
//         return i;
//       }
//       if (oldText.codeUnitAt(i) != newText.codeUnitAt(i)) {
//         return i + 1;
//       }
//     }
//   }
//   return newText.length;
// }
