import 'dart:io';
import 'dart:math';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextUtils {
  /// Extracts text from an image using Google ML Kit Text Recognition.
  static Future<String?> extractTextFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    // Corrected: Use TextRecognitionScript.latin instead of TextScript.latin
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );
    await textRecognizer.close();
    return recognizedText.text;
  }

  /// Generates a secure random password.
  /// Includes uppercase, lowercase, numbers, and symbols.
  static String generateSecurePassword({int length = 16}) {
    const String lowerCase = 'abcdefghijklmnopqrstuvwxyz';
    const String upperCase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String numbers = '0123456789';
    const String symbols = '!@#\$%^&*()_+{}[]|:;"<>,.?/~`';
    const String allChars = lowerCase + upperCase + numbers + symbols;

    Random random = Random.secure();
    StringBuffer password = StringBuffer();

    // Ensure at least one of each type
    password.write(lowerCase[random.nextInt(lowerCase.length)]);
    password.write(upperCase[random.nextInt(upperCase.length)]);
    password.write(numbers[random.nextInt(numbers.length)]);
    password.write(symbols[random.nextInt(symbols.length)]);

    // Fill the rest of the length
    for (int i = password.length; i < length; i++) {
      password.write(allChars[random.nextInt(allChars.length)]);
    }

    // Shuffle the password to make it more random
    List<String> passwordChars = password.toString().split('');
    passwordChars.shuffle(random);

    return passwordChars.join();
  }

  /// Converts a given text string to its binary representation.
  static String textToBinary(String text) {
    StringBuffer binaryString = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      String charBinary = text.codeUnitAt(i).toRadixString(2);
      // Pad with leading zeros to ensure 8-bit representation for each character
      binaryString.write(charBinary.padLeft(8, '0'));
      binaryString.write(' '); // Add a space for readability
    }
    return binaryString.toString().trim();
  }

  /// Converts a given text string to its hexadecimal representation.
  static String textToHexadecimal(String text) {
    StringBuffer hexString = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      String charHex = text.codeUnitAt(i).toRadixString(16);
      // Pad with leading zeros to ensure 2-digit representation for each byte
      hexString.write(charHex.padLeft(2, '0'));
      hexString.write(' '); // Add a space for readability
    }
    return hexString.toString().trim();
  }
}
