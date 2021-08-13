# flutter_custom_text_input_formatter

```dart
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
```