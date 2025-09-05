import 'package:flutter/services.dart';

/// Formatter для номера телефона
/// +7 (###) ###-##-##
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    if (newValue.text.length < oldValue.text.length) {
      // Если текст уменьшается, возвращаем обновленное значение без дополнительной обработки
      return newValue;
    }

    // Только цифры
    newText = newValue.text.replaceAll(RegExp('[^0-9]'), '');

    // Форматирование номера
    String formattedText = '+7';
    if (newText.length > 1) {
      formattedText += ' (${newText.substring(1, newText.length.clamp(1, 4))}';
    }
    if (newText.length > 4) {
      formattedText += ') ${newText.substring(4, newText.length.clamp(4, 7))}';
    }
    if (newText.length > 7) {
      formattedText += '-${newText.substring(7, newText.length.clamp(7, 9))}';
    }
    if (newText.length > 9) {
      formattedText += '-${newText.substring(9, newText.length.clamp(9, 11))}';
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

/// Formatter который проверяет если строка без букв
/// То запрещает вводить только пробелы
class LetterWithSpaceInputFormatter extends TextInputFormatter {
  LetterWithSpaceInputFormatter({required this.firstWordCapitalization});

  final bool firstWordCapitalization;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Проверяем, содержит ли текст только пробелы
    if (text.trim().isEmpty && text.isNotEmpty) {
      // Если содержит только пробелы и текст не пустой, возвращаем старое значение
      return oldValue;
    }

    if (firstWordCapitalization) {
      if (newValue.text.length == 1) {
        return TextEditingValue(
          text: newValue.text.toUpperCase(),
          selection: newValue.selection,
        );
      }
    }
    // В противном случае, возвращаем новое значение
    return newValue;
  }
}

/// Formatter для ввода даты в формате DD.MM.YYYY
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // Если текст сокращается, возвращаем новое значение (удаление символов)
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    // Удаляем все некорректные символы (оставляем только цифры)
    newText = newText.replaceAll(RegExp('[^0-9]'), '');

    // Форматирование текста
    String formattedText = '';
    if (newText.isNotEmpty) {
      formattedText += newText.substring(0, newText.length.clamp(0, 2)); // День
    }
    if (newText.length > 2) {
      formattedText += '.${newText.substring(2, newText.length.clamp(2, 4))}'; // Месяц
    }
    if (newText.length > 4) {
      formattedText += '.${newText.substring(4, newText.length.clamp(4, 8))}'; // Год
    }

    // Ограничиваем длину текста до 10 символов (полный формат DD.MM.YYYY)
    if (formattedText.length > 10) {
      formattedText = formattedText.substring(0, 10);
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

// class TimeInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
//     // String newText = newValue.text;
//   }
// }
