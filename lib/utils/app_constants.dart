// lib/utils/app_constants.dart
import 'package:flutter/material.dart';
import 'package:utilimate/models/tool_item.dart';
import 'package:utilimate/models/category_item.dart';
import 'package:utilimate/screens/web_view_screen.dart';

// Individual Native Tool Screens (KEEP THESE - these are the actual tools)
// PDF Tools
import 'package:utilimate/screens/pdf_tools/image_to_pdf_screen.dart';
import 'package:utilimate/screens/pdf_tools/merge_pdf_screen.dart';
import 'package:utilimate/screens/pdf_tools/split_pdf_screen.dart';
import 'package:utilimate/screens/pdf_tools/compress_pdf_screen.dart';

// Text Tools
import 'package:utilimate/screens/text_tools/ocr_screen.dart';
import 'package:utilimate/screens/text_tools/password_generator_screen.dart';
import 'package:utilimate/screens/text_tools/text_manipulation_screen.dart';
import 'package:utilimate/screens/text_tools/find_replace_screen.dart';

// Image Tools
import 'package:utilimate/screens/image_tools/image_resizer_screen.dart';
import 'package:utilimate/screens/image_tools/image_cropper_screen.dart';
import 'package:utilimate/screens/image_tools/image_format_converter_screen.dart';

// Unit Converter
import 'package:utilimate/screens/unit_converter_screen.dart';

// QR & Barcode Tools
import 'package:utilimate/screens/qr_barcode_tools/qr_generator_screen.dart';
import 'package:utilimate/screens/qr_barcode_tools/qr_scanner_screen.dart';

// Currency Converter
import 'package:utilimate/screens/currency_converter_screen.dart';

// Calculators
import 'package:utilimate/screens/calculators/age_calculator_screen.dart';
import 'package:utilimate/screens/calculators/discount_calculator_screen.dart';
import 'package:utilimate/screens/calculators/bmi_calculator_screen.dart';

// Generators
import 'package:utilimate/screens/generators/fake_name_generator_screen.dart';
import 'package:utilimate/screens/generators/random_text_generator_screen.dart';
import 'package:utilimate/screens/generators/fake_address_generator_screen.dart';
import 'package:utilimate/screens/generators/random_number_generator_screen.dart';
import 'package:utilimate/screens/generators/range_number_picker_screen.dart';

// Time Tools
import 'package:utilimate/screens/time_tools/stopwatch_timer_screen.dart';

// Color Tools
import 'package:utilimate/screens/color_tools/color_picker_converter_screen.dart';

// FIX: Import the new generic category screen
import 'package:utilimate/screens/generic_category_screen.dart';

class AppConstants {
  // Helper for 'All Tools' category help content
  static const String allToolsCategoryHelp = '''
    **All Tools Help:**
    This section provides a comprehensive list of all utility tools available in UtiliMate.
    * **Offline Tools:** These tools work directly on your device and do not require an internet connection (unless for specific functionalities like OCR's initial model download).
    * **Online Tools:** These tools are accessed via external websites/APIs and require an active internet connection. File handling for online tools occurs outside the app's direct control.
    Tap on any tool card to navigate to its dedicated screen and start using it!
    ''';

  // --- Help Content Map ---
  static const Map<String, String> helpContent = {
    'ALL_TOOLS_CATEGORY': allToolsCategoryHelp,
    'PDF_TOOLS_CATEGORY': '''
    **PDF Tools Category Help:**
    Browse and select from various tools to manage and manipulate your PDF documents.
    ''',
    'IMAGE_TO_PDF': '''
    **Convert Image to PDF Help:**
    Select multiple images (PNG, JPG, etc.) from your gallery to combine them into a single PDF document.
    ''',
    'MERGE_PDF': '''
    **Merge PDFs Help:**
    Choose two or more PDF files from your device to combine them into one new PDF.
    ''',
    'SPLIT_PDF': '''
    **Split PDF Help:**
    Divide a PDF into separate pages (each page becomes a new PDF) or extract a specific range of pages into a new PDF.
    ''',
    'COMPRESS_PDF': '''
    **Compress PDF Help:**
    Reduce the file size of your PDF documents using basic compression. This is useful for sharing or saving space.
    ''',
    'TEXT_TOOLS_CATEGORY': '''
    **Text Tools Category Help:**
    Explore a range of tools for text extraction, generation, manipulation, and analysis.
    ''',
    'OCR_TOOL': '''
    **Extract Text from Image (OCR) Help:**
    Pick an image (containing text) from your gallery. The app will use Optical Character Recognition (OCR) to extract the text, which you can then copy to your clipboard.
    ''',
    'PASSWORD_GENERATOR': '''
    **Password Generator Help:**
    Generate strong, random passwords based on your criteria (length, inclusion of numbers, symbols, uppercase, lowercase).
    ''',
    'TEXT_MANIPULATION': '''
    **Text Manipulation Help:**
    Input text and perform various operations:
    * **Word Count:** Get the total number of words.
    * **Character Count:** Get the total number of characters (with/without spaces).
    * **Sentence Count:** Get the total number of sentences.
    * **Reverse Text:** Reverse the order of characters.
    * **Uppercase/Lowercase:** Convert all text to uppercase or lowercase.
    * **Capitalize Words:** Capitalize the first letter of each word.
    * **Remove Extra Spaces:** Clean up multiple spaces between words.
    * **Remove All Spaces:** Remove all spaces from the text.
    * **Copy/Clear:** Easily copy the modified text or clear the input.
    ''',
    'IMAGE_TOOLS_CATEGORY': '''
    **Image Tools Category Help:**
    Discover tools for resizing, cropping, and converting image formats.
    ''',
    'IMAGE_RESIZER': '''
    **Resize Image Help:**
    Enter new width or height (or both) to change the image dimensions. Leave one field empty to maintain the aspect ratio.
    ''',
    'IMAGE_CROPPER': '''
    **Crop Image Help:**
    Define a rectangular area using X, Y coordinates (top-left) and Width, Height to crop the image.
    ''',
    'IMAGE_FORMAT_CONVERTER': '''
    **Convert Image Format Help:**
    Change the format of your image (e.g., from WEBP to PNG, or JPEG to GIF).
    ''',
    'UNIT_CONVERTER_TOOL': '''
    **Unit Converter Help:**
    * **Select Category:** Choose the type of units you want to convert (e.g., Length, Weight, Temperature).
    * **From Unit / To Unit:** Select the original unit and the target unit within the chosen category.
    * **Input Value:** Enter the numerical value you want to convert.
    * **Convert Button:** Tap to see the converted result immediately.
    ''',
    'FILE_MANAGEMENT_TOOL': '''
    **File Management Help:**
    * **Browse Files:** View all files generated by UtiliMate in a dedicated folder. Files are sorted by the newest first.
    * **Open File:** Tap on a file to open it. PDFs will open in the in-app PDF viewer; other files will use your device's default app.
    * **Rename File:** Tap the edit (pencil) icon next to a file to change its name.
    * **Delete File:** Tap the trash can icon next to a file to permanently delete it. Confirm your action in the dialog.
    * **Refresh Files:** Pull down to refresh the list or tap the refresh button in the bottom right corner.
    ''',
    'QR_BARCODE_TOOLS_CATEGORY': '''
    **QR & Barcode Tools Category Help:**
    Quickly generate or scan QR codes and various barcodes.
    ''',
    'QR_GENERATOR_TOOL': '''
    **QR Code Generator Help:**
    * **Enter Data:** Type or paste the text, URL, or any information you want to encode into the QR code.
    * **Generate QR Code:** Tap the button to instantly see your QR code appear below.
    * **Save QR Code as Image:** Once generated, tap this button to save the QR code image to your device's files. You can then open or share it.
    ''',
    'QR_SCANNER_TOOL': '''
    **QR & Barcode Scanner Help:**
    * **Grant Camera Permission:** The first time you use the scanner, you'll be asked for camera permission. Please grant it to proceed.
    * **Position Code:** Point your device's camera at the QR code or barcode. The scanner will automatically detect and read it.
    * **Scan Result:** The scanned data will appear at the bottom of the screen.
    * **Copy Result / Scan Again:** You can copy the scanned text to your clipboard or tap "Scan Again" to continue scanning.
    * **Flashlight:** Tap the flashlight icon in the top right corner to toggle your device's flash for better scanning in low light.
    ''',
    'VIDEO_DOWNLOADERS_CATEGORY': '''
    **Video Downloaders Category Help:**
    Access various online video downloaders via external websites.
    **Disclaimer:** Be aware of copyright and platform terms of service when downloading online content. UtiliMate does not endorse or facilitate unauthorized downloads. Download links will open in your device's default browser.
    ''',
    'WEB_TOOLS_CATEGORY': '''
    **Online Tools Category Help:**
    This section provides access to various utility tools hosted on external websites/APIs.
    **External Content:** Please note that these tools are provided by third-party websites. UtiliMate does not control their content, advertisements, or data handling.
    **File Downloads:** When using these online tools, any file uploads or downloads will be handled by the website and your device's browser, not directly by UtiliMate's internal file management.
    **Internet Connection Required:** An active internet connection is necessary to use these online tools.
    ''',
    'WEB_ANY_VIDEO_DOWNLOADER': '''
    **Any Video Downloader (Online Tool) Help:**
    * **Paste Video URL:** On the web page, paste the URL of the video you want to download.
    * **Download:** Follow the website's instructions to initiate the download.
    * **Disclaimer:** Be aware of copyright and platform terms of service when downloading online content. UtiliMate does not endorse or facilitate unauthorized downloads. Download links will open in your device's default browser.
    ''',
    'CURRENCY_CONVERTER_TOOL': '''
    **Currency Converter Help:**
    Convert amounts between different global currencies using real-time exchange rates.
    * **Amount:** Enter the numerical value you want to convert.
    * **From/To:** Select the original currency and the target currency from the dropdown lists.
    * **Swap:** Use the swap icon to quickly reverse the 'From' and 'To' currencies.
    * **Convert:** Tap the button to see the converted amount.
    * **Note:** Exchange rates are fetched from an online service and require an internet connection.
    ''',
    'AGE_CALCULATOR_TOOL': '''
    **Age Calculator Help:**
    Calculate your precise age in years, months, and days.
    * **Select Birth Date:** Tap the text field to open a date picker and choose your birth date.
    * **Calculate Age:** Tap the button to see your calculated age displayed below.
    ''',
    'DISCOUNT_CALCULATOR_TOOL': '''
    **Discount Calculator Help:**
    Quickly calculate the final price after a discount and the amount you save.
    * **Original Price:** Enter the initial price of the item.
    * **Discount Percentage:** Enter the percentage discount (e.g., 20 for 20%).
    * **Calculate Discount:** Tap the button to see the discounted price and the amount saved.
    ''',
    'BMI_CALCULATOR_TOOL': '''
    **BMI Calculator Help:**
    Calculate your Body Mass Index (BMI) to assess if your weight is healthy relative to your height.
    * **Height:** Enter your height in centimeters (cm).
    * **Weight:** Enter your weight in kilograms (kg).
    * **Calculate BMI:** Tap the button to see your BMI score and its corresponding category (e.g., Normal weight, Overweight).
    ''',
    'FAKE_NAME_GENERATOR_TOOL': '''
    **Fake Name Generator Help:**
    Generate random first and last names for various purposes (e.g., placeholder data, creative writing).
    * **Generate Name:** Tap the button to instantly create a new random name.
    * **Copy to Clipboard:** Tap the button below the generated name to copy it for easy use.
    ''',
    'RANDOM_TEXT_GENERATOR_TOOL': '''
    **Random Text Generator Help:**
    Generate random paragraphs of "Lorem Ipsum" style text.
    * **Number of Paragraphs:** Enter how many paragraphs you want to generate.
    * **Generate Text:** Tap the button to create the random text.
    * **Copy to Clipboard:** Easily copy the generated text for use in your projects.
    ''',
    'FAKE_ADDRESS_GENERATOR_TOOL': '''
    **Fake Address Generator Help:**
    Generate a random, plausible-looking address for placeholder data or testing.
    * **Generate Address:** Tap the button to create a new random address.
    * **Copy to Clipboard:** Easily copy the generated address for use.
    ''',
    'RANDOM_NUMBER_GENERATOR_TOOL': '''
    **Random Number Generator Help:**
    Generate a random number with a specified length of digits.
    * **Number Length:** Enter the desired number of digits (e.g., 10 for a 10-digit number).
    * **Generate Number:** Tap the button to create the random number.
    * **Copy to Clipboard:** Easily copy the generated number for use.
    ''',
    'RANGE_NUMBER_PICKER_TOOL': '''
    **Range Number Picker Help:**
    Pick a single random number within a specified range (from 1 up to your chosen maximum number).
    * **Maximum Range:** Enter the highest possible number you want to be picked (e.g., 100). The lowest possible number is always 1.
    * **Pick Number:** Tap the button to generate a random number within your defined range.
    * **Copy to Clipboard:** Easily copy the picked number for.
    ''',
    'FIND_REPLACE_TOOL': '''
    **Find and Replace Help:**
    Quickly find specific text within a larger body of text and replace it with something else.
    * **Original Text:** Enter or paste the text you want to modify.
    * **Text to Find:** Enter the exact text you want to locate.
    * **Replace With:** Enter the text you want to substitute for the found text. Leave empty to delete found text.
    * **Perform Find & Replace:** Tap the button to see the modified text.
    * **Copy to Clipboard:** Easily copy the result.
    ''',
    'STOPWATCH_TIMER_TOOL': '''
    **Stopwatch & Timer Help:**
    A versatile tool combining a stopwatch and a countdown timer.
    * **Stopwatch Tab:**
    * **Start:** Begin timing.
    * **Pause:** Temporarily stop the stopwatch.
    * **Reset:** Clear the elapsed time and stop the stopwatch.
    * **Timer Tab:**
    * **Set Timer:** Tap to choose a duration (hours and minutes) for the countdown.
    * **Start:** Begin the countdown.
    * **Pause:** Temporarily stop the timer.
    * **Reset:** Return the timer to its initially set duration.
    * An alert will notify you when the timer finishes.
    ''',
    'COLOR_PICKER_CONVERTER_TOOL': '''
    **Color Picker & Converter Help:**
    Identify and convert color codes between Hex, RGB, and HSL formats.
    * **Color Preview:** Adjust the Red, Green, and Blue sliders to visually pick a color. The preview box will update in real-time.
    * **Hex Input:** Enter a 6-digit (e.g., FF0000) or 8-digit (e.g., FFFF0000 for transparent red) Hex code. The other fields and preview will update.
    * **RGB Input:** Enter Red, Green, and Blue values (0-255). The other fields and preview will update.
    * **HSL Input:** Enter Hue (0-360), Saturation (0-100%), and Lightness (0-100%). The other fields and preview will update.
    * **Copy/Clear:** Easily copy the modified text or clear the input.
    ''',
    'CALCULATORS_CATEGORY': '''
    **Calculators Category Help:**
    A collection of useful calculators for various daily needs, including age, discounts, and BMI.
    ''',
    'GENERATORS_CATEGORY': '''
    **Generators Category Help:**
    Tools to generate various types of random data, such as names, text, and addresses.
    ''',
    'TIME_TOOLS_CATEGORY': '''
    **Time Tools Category Help:**
    Essential tools for managing and tracking time, including a stopwatch and a countdown timer.
    ''',
    'COLOR_TOOLS_CATEGORY': '''
    **Color Tools Category Help:**
    Tools for working with colors, including a color picker and converter for various formats.
    ''',
  };

  // --- All Tool Items List ---
  static final List<ToolItem> allTools = [
    // PDF Tools (Offline)
    ToolItem(
      name: 'Image to PDF',
      icon: Icons.insert_photo,
      screenBuilder: (context) => const ImageToPdfScreen(),
      screenType: ImageToPdfScreen,
      type: ToolType.offline,
      helpContentKey: 'IMAGE_TO_PDF',
    ),
    ToolItem(
      name: 'Merge PDFs',
      icon: Icons.merge_type,
      screenBuilder: (context) => const MergePdfScreen(),
      screenType: MergePdfScreen,
      type: ToolType.offline,
      helpContentKey: 'MERGE_PDF',
    ),
    ToolItem(
      name: 'Split PDF',
      icon: Icons.call_split,
      screenBuilder: (context) => const SplitPdfScreen(),
      screenType: SplitPdfScreen,
      type: ToolType.offline,
      helpContentKey: 'SPLIT_PDF',
    ),
    ToolItem(
      name: 'Compress PDF',
      icon: Icons.compress,
      screenBuilder: (context) => const CompressPdfScreen(),
      screenType: CompressPdfScreen,
      type: ToolType.offline,
      helpContentKey: 'COMPRESS_PDF',
    ),

    // Text Tools (Offline)
    ToolItem(
      name: 'OCR (Image to Text)',
      icon: Icons.text_fields,
      screenBuilder: (context) => const OcrScreen(),
      screenType: OcrScreen,
      type: ToolType.offline,
      helpContentKey: 'OCR_TOOL',
    ),
    ToolItem(
      name: 'Password Generator',
      icon: Icons.vpn_key,
      screenBuilder: (context) => const PasswordGeneratorScreen(),
      screenType: PasswordGeneratorScreen,
      type: ToolType.offline,
      helpContentKey: 'PASSWORD_GENERATOR',
    ),
    ToolItem(
      name: 'Text Manipulation',
      icon: Icons.wrap_text,
      screenBuilder: (context) => const TextManipulationScreen(),
      screenType: TextManipulationScreen,
      type: ToolType.offline,
      helpContentKey: 'TEXT_MANIPULATION',
    ),
    ToolItem(
      name: 'Find and Replace',
      icon: Icons.find_replace,
      screenBuilder: (context) => const FindReplaceScreen(),
      screenType: FindReplaceScreen,
      type: ToolType.offline,
      helpContentKey: 'FIND_REPLACE_TOOL',
    ),

    // Image Tools (Offline)
    ToolItem(
      name: 'Image Resizer',
      icon: Icons.aspect_ratio,
      screenBuilder: (context) => const ImageResizerScreen(),
      screenType: ImageResizerScreen,
      type: ToolType.offline,
      helpContentKey: 'IMAGE_RESIZER',
    ),
    ToolItem(
      name: 'Image Cropper',
      icon: Icons.crop,
      screenBuilder: (context) => const ImageCropperScreen(),
      screenType: ImageCropperScreen,
      type: ToolType.offline,
      helpContentKey: 'IMAGE_CROPPER',
    ),
    ToolItem(
      name: 'Image Format Converter',
      icon: Icons.compare_arrows,
      screenBuilder: (context) => const ImageFormatConverterScreen(),
      screenType: ImageFormatConverterScreen,
      type: ToolType.offline,
      helpContentKey: 'IMAGE_FORMAT_CONVERTER',
    ),

    // Unit Converter (Offline)
    ToolItem(
      name: 'Unit Converter',
      icon: Icons.straighten,
      screenBuilder: (context) => const UnitConverterScreen(),
      screenType: UnitConverterScreen,
      type: ToolType.offline,
      helpContentKey: 'UNIT_CONVERTER_TOOL',
    ),

    // QR & Barcode Tools (Offline)
    ToolItem(
      name: 'QR Code Generator',
      icon: Icons.qr_code,
      screenBuilder: (context) => const QrGeneratorScreen(),
      screenType: QrGeneratorScreen,
      type: ToolType.offline,
      helpContentKey: 'QR_GENERATOR_TOOL',
    ),
    ToolItem(
      name: 'QR & Barcode Scanner',
      icon: Icons.qr_code_scanner,
      screenBuilder: (context) => const QrScannerScreen(),
      screenType: QrScannerScreen,
      type: ToolType.offline,
      helpContentKey: 'QR_SCANNER_TOOL',
    ),

    // Currency Converter (Online)
    ToolItem(
      name: 'Currency Converter',
      icon: Icons.currency_exchange,
      screenBuilder: (context) => const CurrencyConverterScreen(),
      screenType: CurrencyConverterScreen,
      type: ToolType.online,
      helpContentKey: 'CURRENCY_CONVERTER_TOOL',
    ),

    // Calculators (Offline)
    ToolItem(
      name: 'Age Calculator',
      icon: Icons.calendar_month,
      screenBuilder: (context) => const AgeCalculatorScreen(),
      screenType: AgeCalculatorScreen,
      type: ToolType.offline,
      helpContentKey: 'AGE_CALCULATOR_TOOL',
    ),
    ToolItem(
      name: 'Discount Calculator',
      icon: Icons.discount,
      screenBuilder: (context) => const DiscountCalculatorScreen(),
      screenType: DiscountCalculatorScreen,
      type: ToolType.offline,
      helpContentKey: 'DISCOUNT_CALCULATOR_TOOL',
    ),
    ToolItem(
      name: 'BMI Calculator',
      icon: Icons.monitor_weight,
      screenBuilder: (context) => const BmiCalculatorScreen(),
      screenType: BmiCalculatorScreen,
      type: ToolType.offline,
      helpContentKey: 'BMI_CALCULATOR_TOOL',
    ),

    // Generators (Offline)
    ToolItem(
      name: 'Fake Name Generator',
      icon: Icons.badge,
      screenBuilder: (context) => const FakeNameGeneratorScreen(),
      screenType: FakeNameGeneratorScreen,
      type: ToolType.offline,
      helpContentKey: 'FAKE_NAME_GENERATOR_TOOL',
    ),
    ToolItem(
      name: 'Random Text Generator',
      icon: Icons.text_snippet,
      screenBuilder: (context) => const RandomTextGeneratorScreen(),
      screenType: RandomTextGeneratorScreen,
      type: ToolType.offline,
      helpContentKey: 'RANDOM_TEXT_GENERATOR_TOOL',
    ),
    ToolItem(
      name: 'Fake Address Generator',
      icon: Icons.location_city,
      screenBuilder: (context) => const FakeAddressGeneratorScreen(),
      screenType: FakeAddressGeneratorScreen,
      type: ToolType.offline,
      helpContentKey: 'FAKE_ADDRESS_GENERATOR_TOOL',
    ),
    ToolItem(
      name: 'Random Number Generator',
      icon: Icons.numbers,
      screenBuilder: (context) => const RandomNumberGeneratorScreen(),
      screenType: RandomNumberGeneratorScreen,
      type: ToolType.offline,
      helpContentKey: 'RANDOM_NUMBER_GENERATOR_TOOL',
    ),
    ToolItem(
      name: 'Range Number Picker',
      icon: Icons.format_list_numbered,
      screenBuilder: (context) => const RangeNumberPickerScreen(),
      screenType: RangeNumberPickerScreen,
      type: ToolType.offline,
      helpContentKey: 'RANGE_NUMBER_PICKER_TOOL',
    ),

    // Time Tools (Offline)
    ToolItem(
      name: 'Stopwatch & Timer',
      icon: Icons.access_time,
      screenBuilder: (context) => const StopwatchTimerScreen(),
      screenType: StopwatchTimerScreen,
      type: ToolType.offline,
      helpContentKey: 'STOPWATCH_TIMER_TOOL',
    ),

    // Color Tools (Offline)
    ToolItem(
      name: 'Color Picker & Converter',
      icon: Icons.color_lens,
      screenBuilder: (context) => const ColorPickerConverterScreen(),
      screenType: ColorPickerConverterScreen,
      type: ToolType.offline,
      helpContentKey: 'COLOR_PICKER_CONVERTER_TOOL',
    ),

    // --- Online Tools ---
    // Consolidated Video Downloader to SaveFrom.net
    ToolItem(
      name: 'Universal Video Downloader',
      icon: Icons.download_for_offline,
      screenBuilder:
          (context) => const WebViewScreen(
            title: 'Universal Video Downloader',
            url: 'https://en1.savefrom.net/', // Consolidated URL
            helpContentKey:
                'WEB_ANY_VIDEO_DOWNLOADER', // Re-using this general help key
          ),
      screenType: WebViewScreen,
      type: ToolType.online,
      helpContentKey: 'WEB_ANY_VIDEO_DOWNLOADER',
    ),
  ];

  // Helper to get tools by type (for category screens)
  static List<ToolItem> getPdfTools() =>
      allTools
          .where(
            (tool) =>
                tool.screenType == ImageToPdfScreen ||
                tool.screenType == MergePdfScreen ||
                tool.screenType == SplitPdfScreen ||
                tool.screenType == CompressPdfScreen,
          )
          .toList();

  static List<ToolItem> getTextTools() =>
      allTools
          .where(
            (tool) =>
                tool.screenType == OcrScreen ||
                tool.screenType == PasswordGeneratorScreen ||
                tool.screenType == TextManipulationScreen ||
                tool.screenType == FindReplaceScreen,
          )
          .toList();

  static List<ToolItem> getImageTools() =>
      allTools
          .where(
            (tool) =>
                tool.screenType == ImageResizerScreen ||
                tool.screenType == ImageCropperScreen ||
                tool.screenType == ImageFormatConverterScreen,
          )
          .toList();

  // Simplified getVideoDownloaders to only return the consolidated one
  static List<ToolItem> getVideoDownloaders() =>
      allTools
          .where((tool) => tool.helpContentKey == 'WEB_ANY_VIDEO_DOWNLOADER')
          .toList();

  static List<ToolItem> getQrBarcodeTools() =>
      allTools
          .where(
            (tool) =>
                tool.screenType == QrGeneratorScreen ||
                tool.screenType == QrScannerScreen,
          )
          .toList();

  // Helper to get Calculator tools
  static List<ToolItem> getCalculatorTools() =>
      allTools
          .where(
            (tool) =>
                tool.screenType == AgeCalculatorScreen ||
                tool.screenType == DiscountCalculatorScreen ||
                tool.screenType == BmiCalculatorScreen,
          )
          .toList();

  static List<ToolItem> getGeneratorsTools() =>
      allTools
          .where(
            (tool) =>
                tool.screenType == FakeNameGeneratorScreen ||
                tool.screenType == RandomTextGeneratorScreen ||
                tool.screenType == FakeAddressGeneratorScreen ||
                tool.screenType == RandomNumberGeneratorScreen ||
                tool.screenType == RangeNumberPickerScreen,
          )
          .toList();

  static List<ToolItem> getTimeTools() =>
      allTools
          .where((tool) => tool.screenType == StopwatchTimerScreen)
          .toList();

  static List<ToolItem> getColorTools() =>
      allTools
          .where((tool) => tool.screenType == ColorPickerConverterScreen)
          .toList();

  // Define toolCategories getter
  static final List<CategoryItem> toolCategories = [
    CategoryItem(
      name: 'PDF Tools',
      icon: Icons.picture_as_pdf,
      screenBuilder:
          (context) => GenericCategoryScreen(
            // FIX: Use GenericCategoryScreen
            title: 'PDF Tools',
            tools: getPdfTools(),
            categoryHelpContentKey: 'PDF_TOOLS_CATEGORY',
          ),
      helpContentKey: 'PDF_TOOLS_CATEGORY',
    ),
    CategoryItem(
      name: 'Text Tools',
      icon: Icons.text_fields,
      screenBuilder:
          (context) => GenericCategoryScreen(
            // FIX: Use GenericCategoryScreen
            title: 'Text Tools',
            tools: getTextTools(),
            categoryHelpContentKey: 'TEXT_TOOLS_CATEGORY',
          ),
      helpContentKey: 'TEXT_TOOLS_CATEGORY',
    ),
    CategoryItem(
      name: 'Image Tools',
      icon: Icons.image,
      screenBuilder:
          (context) => GenericCategoryScreen(
            // FIX: Use GenericCategoryScreen
            title: 'Image Tools',
            tools: getImageTools(),
            categoryHelpContentKey: 'IMAGE_TOOLS_CATEGORY',
          ),
      helpContentKey: 'IMAGE_TOOLS_CATEGORY',
    ),
    CategoryItem(
      name: 'Video Downloaders',
      icon: Icons.video_library,
      screenBuilder:
          (context) => GenericCategoryScreen(
            // FIX: Use GenericCategoryScreen
            title: 'Video Downloaders',
            tools: getVideoDownloaders(),
            categoryHelpContentKey: 'VIDEO_DOWNLOADERS_CATEGORY',
          ),
      helpContentKey: 'VIDEO_DOWNLOADERS_CATEGORY',
    ),
    CategoryItem(
      name: 'QR & Barcode Tools',
      icon: Icons.qr_code_scanner,
      screenBuilder:
          (context) => GenericCategoryScreen(
            // FIX: Use GenericCategoryScreen
            title: 'QR & Barcode Tools',
            tools: getQrBarcodeTools(),
            categoryHelpContentKey: 'QR_BARCODE_TOOLS_CATEGORY',
          ),
      helpContentKey: 'QR_BARCODE_TOOLS_CATEGORY',
    ),
    CategoryItem(
      name: 'Calculators',
      icon: Icons.calculate,
      screenBuilder:
          (context) => GenericCategoryScreen(
            // FIX: Use GenericCategoryScreen
            title: 'Calculators',
            tools: getCalculatorTools(),
            categoryHelpContentKey: 'CALCULATORS_CATEGORY',
          ),
      helpContentKey: 'CALCULATORS_CATEGORY',
    ),
    CategoryItem(
      name: 'Generators',
      icon: Icons.auto_awesome,
      screenBuilder:
          (context) => GenericCategoryScreen(
            // FIX: Use GenericCategoryScreen
            title: 'Generators',
            tools: getGeneratorsTools(),
            categoryHelpContentKey: 'GENERATORS_CATEGORY',
          ),
      helpContentKey: 'GENERATORS_CATEGORY',
    ),
    CategoryItem(
      name: 'Time Tools',
      icon: Icons.access_time,
      screenBuilder:
          (context) => GenericCategoryScreen(
            // FIX: Use GenericCategoryScreen
            title: 'Time Tools',
            tools: getTimeTools(),
            categoryHelpContentKey: 'TIME_TOOLS_CATEGORY',
          ),
      helpContentKey: 'TIME_TOOLS_CATEGORY',
    ),
    CategoryItem(
      name: 'Color Tools',
      icon: Icons.color_lens,
      screenBuilder:
          (context) => GenericCategoryScreen(
            // FIX: Use GenericCategoryScreen
            title: 'Color Tools',
            tools: getColorTools(),
            categoryHelpContentKey: 'COLOR_TOOLS_CATEGORY',
          ),
      helpContentKey: 'COLOR_TOOLS_CATEGORY',
    ),
  ];
}
