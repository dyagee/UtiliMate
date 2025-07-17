// lib/utils/app_constants.dart
import 'package:flutter/material.dart';
import 'package:utilimate/models/tool_item.dart';
import 'package:utilimate/models/category_item.dart';
import 'package:utilimate/screens/web_view_screen.dart';

// Individual Native Tool Screens
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

// Category Screens (used in the modal sheet)
import 'package:utilimate/screens/pdf_tools_category_screen.dart';
import 'package:utilimate/screens/text_tools_category_screen.dart';
import 'package:utilimate/screens/image_tools_category_screen.dart';
import 'package:utilimate/screens/video_downloaders_category_screen.dart';
import 'package:utilimate/screens/qr_barcode_tools_category_screen.dart';
import 'package:utilimate/screens/calculators_category_screen.dart';
import 'package:utilimate/screens/generators_category_screen.dart';
import 'package:utilimate/screens/time_tools_category_screen.dart';
import 'package:utilimate/screens/color_tools_category_screen.dart';

class AppConstants {
  // Helper for 'All Tools' category help content
  static const String allToolsCategoryHelp = '''
    **All Tools Help:**
    This section provides a comprehensive list of all utility tools available in UtiliMate.
    * **Offline Tools:** These tools work directly on your device and do not require an internet connection (unless for specific functionalities like OCR's initial model download).
    * **Online Tools:** These tools are accessed via external websites (e.g., smallseotools.com) and require an active internet connection. File handling for online tools occurs outside the app's direct control.
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
    **Disclaimer:** Be aware of copyright and platform terms of service when downloading online content. UtiliMate does not endorse or facilitate unauthorized downloads.
    ''',
    'WEB_TOOLS_CATEGORY': '''
    **Online Tools Category Help:**
    This section provides access to various utility tools hosted on external websites (e.g., smallseotools.com).
    **External Content:** Please note that these tools are provided by third-party websites. UtiliMate does not control their content, advertisements, or data handling.
    **File Downloads:** When using these online tools, any file uploads or downloads will be handled by the website and your device's browser, not directly by UtiliMate's internal file management.
    **Internet Connection Required:** An active internet connection is necessary to use these online tools.
    ''',
    'WEB_WORD_TO_PDF': '''
    **Word to PDF Converter (Online Tool) Help:**
    * **Upload Word File:** On the web page, you will find an option to upload your Word document (.docx).
    * **Convert:** Follow the website's instructions to initiate the conversion.
    * **Download PDF:** Once converted, the website will provide a link to download the resulting PDF file. This download will be handled by your device's browser.
    ''',
    'WEB_PDF_TO_WORD': '''
    **PDF to Word Converter (Online Tool) Help:**
    * **Upload PDF File:** On the web page, upload your PDF document.
    * **Convert:** Follow the website's instructions to convert the PDF to an editable Word document.
    * **Download Word File:** The website will provide a link to download the converted Word file (.docx). This download will be handled by your device's browser.
    ''',
    'WEB_PPT_TO_PDF': '''
    **PowerPoint to PDF Converter (Online Tool) Help:**
    * **Upload PowerPoint File:** On the web page, upload your PowerPoint presentation (.pptx).
    * **Convert:** Follow the website's instructions to convert the presentation to PDF.
    * **Download PDF:** The website will provide a link to download the resulting PDF. This download will be handled by your device's browser.
    ''',
    'WEB_EXCEL_TO_PDF': '''
    **Excel to PDF Converter (Online Tool) Help:**
    * **Upload Excel File:** On the web page, upload your Excel spreadsheet (.xlsx).
    * **Convert:** Follow the website's instructions to convert the spreadsheet to PDF.
    * **Download PDF:** The website will provide a link to download the resulting PDF. This download will be handled by your device's browser.
    ''',
    'WEB_CROP_IMAGE': '''
    **Crop Image (Online Tool) Help:**
    * **Upload Image:** On the web page, upload the image you wish to crop.
    * **Crop:** Use the website's interface to select the desired cropping area.
    * **Download Image:** Download the cropped image from the website.
    ''',
    'WEB_IMAGE_COMPRESSOR': '''
    **Image Compressor (Online Tool) Help:**
    * **Upload Image:** On the web page, upload the image you want to compress.
    * **Compress:** Follow the website's instructions to compress the image.
    * **Download Image:** Download the compressed image from the website.
    ''',
    'WEB_PHOTO_EDITOR': '''
    **Online Photo Editor (Online Tool) Help:**
    * **Upload Image:** On the web page, upload the image you want to edit.
    * **Edit Tools:** Use the various editing tools provided by the website (e.g., crop, resize, filters).
    * **Save/Download:** Once you're done editing, the website will provide options to save or download your modified image.
    ''',
    'WEB_WEBSITE_SCREENSHOT': '''
    **Website Screenshot Generator (Online Tool) Help:**
    * **Enter URL:** On the web page, enter the URL of the website you want to screenshot.
    * **Generate:** Follow the website's instructions to generate the screenshot.
    * **Download Screenshot:** Download the generated image.
    ''',
    'WEB_FAVICON_GENERATOR': '''
    **Favicon Generator (Online Tool) Help:**
    * **Upload Image:** On the web page, upload an image to use for your favicon.
    * **Generate Favicon:** Follow the website's instructions to create the favicon.
    * **Download Favicon:** Download the generated favicon file.
    ''',
    'WEB_ANY_VIDEO_DOWNLOADER': '''
    **Any Video Downloader (Online Tool) Help:**
    * **Paste Video URL:** On the web page, paste the URL of the video you want to download.
    * **Download:** Follow the website's instructions to initiate the download.
    * **Disclaimer:** Be aware of copyright and platform terms of service when downloading online content. UtiliMate does not endorse or facilitate unauthorized downloads.
    ''',
    'WEB_FACEBOOK_VIDEO_DOWNLOADER': '''
    **Facebook Video Downloader (Online Tool) Help:**
    * **Paste Facebook Video URL:** On the web page, paste the URL of the Facebook video.
    * **Download:** Follow the website's instructions to download the video.
    * **Disclaimer:** Respect copyright and Facebook's terms of service.
    ''',
    'WEB_TWITTER_VIDEO_DOWNLOADER': '''
    **Twitter Video Downloader (Online Tool) Help:**
    * **Paste Twitter Video URL:** On the web page, paste the URL of the Twitter video.
    * **Download:** Follow the website's instructions to download the video.
    * **Disclaimer:** Respect copyright and Twitter's terms of service.
    ''',
    'WEB_INSTAGRAM_VIDEO_DOWNLOADER': '''
    **Instagram Video Downloader (Online Tool) Help:**
    * **Paste Instagram Video URL:** On the web page, paste the URL of the Instagram video.
    * **Download:** Follow the website's instructions to download the video.
    * **Disclaimer:** Respect copyright and Instagram's terms of service.
    ''',
    'WEB_PINTEREST_VIDEO_DOWNLOADER': '''
    **Pinterest Video Downloader (Online Tool) Help:**
    * **Paste Pinterest Video URL:** On the web page, paste the URL of the Pinterest video.
    * **Download:** Follow the website's instructions to download the video.
    * **Disclaimer:** Respect copyright and Pinterest's terms of service.
    ''',
    'WEB_TIKTOK_VIDEO_DOWNLOADER': '''
    **TikTok Video Downloader (Online Tool) Help:**
    * **Paste TikTok Video URL:** On the web page, paste the URL of the TikTok video.
    * **Download:** Follow the website's instructions to download the video.
    * **Disclaimer:** Respect copyright and TikTok's terms of service.
    ''',
    'WEB_KEYWORD_SUGGESTION': '''
    **Keyword Suggestion Tool (Online Tool) Help:**
    * **Enter Topic/Keyword:** On the web page, enter your initial topic or keyword.
    * **Generate Suggestions:** Follow the website's instructions to get a list of related keyword suggestions.
    * **Analyze/Copy:** Review the suggestions and copy the relevant ones for your use.
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
    * **Copy to Clipboard:** Easily copy the picked number for use.
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
    * **Copy to Clipboard:** Use the copy icons next to each format to quickly copy the color code.
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
      screen: const ImageToPdfScreen(),
      type: ToolType.offline,
      helpContentKey: 'IMAGE_TO_PDF',
    ),
    ToolItem(
      name: 'Merge PDFs',
      icon: Icons.merge_type,
      screen: const MergePdfScreen(),
      type: ToolType.offline,
      helpContentKey: 'MERGE_PDF',
    ),
    ToolItem(
      name: 'Split PDF',
      icon: Icons.call_split,
      screen: const SplitPdfScreen(),
      type: ToolType.offline,
      helpContentKey: 'SPLIT_PDF',
    ),
    ToolItem(
      name: 'Compress PDF',
      icon: Icons.compress,
      screen: const CompressPdfScreen(),
      type: ToolType.offline,
      helpContentKey: 'COMPRESS_PDF',
    ),

    // Text Tools (Offline)
    ToolItem(
      name: 'OCR (Image to Text)',
      icon: Icons.text_fields,
      screen: const OcrScreen(),
      type: ToolType.offline,
      helpContentKey: 'OCR_TOOL',
    ),
    ToolItem(
      name: 'Password Generator',
      icon: Icons.vpn_key,
      screen: const PasswordGeneratorScreen(),
      type: ToolType.offline,
      helpContentKey: 'PASSWORD_GENERATOR',
    ),
    ToolItem(
      name: 'Text Manipulation',
      icon: Icons.wrap_text,
      screen: const TextManipulationScreen(),
      type: ToolType.offline,
      helpContentKey: 'TEXT_MANIPULATION',
    ),
    ToolItem(
      name: 'Find and Replace',
      icon: Icons.find_replace,
      screen: const FindReplaceScreen(),
      type: ToolType.offline,
      helpContentKey: 'FIND_REPLACE_TOOL',
    ),

    // Image Tools (Offline)
    ToolItem(
      name: 'Image Resizer',
      icon: Icons.aspect_ratio,
      screen: const ImageResizerScreen(),
      type: ToolType.offline,
      helpContentKey: 'IMAGE_RESIZER',
    ),
    ToolItem(
      name: 'Image Cropper',
      icon: Icons.crop,
      screen: const ImageCropperScreen(),
      type: ToolType.offline,
      helpContentKey: 'IMAGE_CROPPER',
    ),
    ToolItem(
      name: 'Image Format Converter',
      icon: Icons.compare_arrows,
      screen: const ImageFormatConverterScreen(),
      type: ToolType.offline,
      helpContentKey: 'IMAGE_FORMAT_CONVERTER',
    ),

    // Unit Converter (Offline)
    ToolItem(
      name: 'Unit Converter',
      icon: Icons.straighten,
      screen: const UnitConverterScreen(),
      type: ToolType.offline,
      helpContentKey: 'UNIT_CONVERTER_TOOL',
    ),

    // QR & Barcode Tools (Offline)
    ToolItem(
      name: 'QR Code Generator',
      icon: Icons.qr_code,
      screen: const QrGeneratorScreen(),
      type: ToolType.offline,
      helpContentKey: 'QR_GENERATOR_TOOL',
    ),
    ToolItem(
      name: 'QR & Barcode Scanner',
      icon: Icons.qr_code_scanner,
      screen: const QrScannerScreen(),
      type: ToolType.offline,
      helpContentKey: 'QR_SCANNER_TOOL',
    ),

    // Currency Converter (Online)
    ToolItem(
      name: 'Currency Converter',
      icon: Icons.currency_exchange,
      screen: const CurrencyConverterScreen(),
      type: ToolType.online,
      helpContentKey: 'CURRENCY_CONVERTER_TOOL',
    ),

    // Calculators (Offline)
    ToolItem(
      name: 'Age Calculator',
      icon: Icons.calendar_month,
      screen: const AgeCalculatorScreen(),
      type: ToolType.offline,
      helpContentKey: 'AGE_CALCULATOR_TOOL',
    ),
    ToolItem(
      name: 'Discount Calculator',
      icon: Icons.discount,
      screen: const DiscountCalculatorScreen(),
      type: ToolType.offline,
      helpContentKey: 'DISCOUNT_CALCULATOR_TOOL',
    ),
    ToolItem(
      name: 'BMI Calculator',
      icon: Icons.monitor_weight,
      screen: const BmiCalculatorScreen(),
      type: ToolType.offline,
      helpContentKey: 'BMI_CALCULATOR_TOOL',
    ),

    // Generators (Offline)
    ToolItem(
      name: 'Fake Name Generator',
      icon: Icons.badge,
      screen: const FakeNameGeneratorScreen(),
      type: ToolType.offline,
      helpContentKey: 'FAKE_NAME_GENERATOR_TOOL',
    ),
    ToolItem(
      name: 'Random Text Generator',
      icon: Icons.text_snippet,
      screen: const RandomTextGeneratorScreen(),
      type: ToolType.offline,
      helpContentKey: 'RANDOM_TEXT_GENERATOR_TOOL',
    ),
    ToolItem(
      name: 'Fake Address Generator',
      icon: Icons.location_city,
      screen: const FakeAddressGeneratorScreen(),
      type: ToolType.offline,
      helpContentKey: 'FAKE_ADDRESS_GENERATOR_TOOL',
    ),
    ToolItem(
      name: 'Random Number Generator',
      icon: Icons.numbers,
      screen: const RandomNumberGeneratorScreen(),
      type: ToolType.offline,
      helpContentKey: 'RANDOM_NUMBER_GENERATOR_TOOL',
    ),
    ToolItem(
      name: 'Range Number Picker',
      icon: Icons.format_list_numbered,
      screen: const RangeNumberPickerScreen(),
      type: ToolType.offline,
      helpContentKey: 'RANGE_NUMBER_PICKER_TOOL',
    ),

    // Time Tools (Offline)
    ToolItem(
      name: 'Stopwatch & Timer',
      icon: Icons.access_time,
      screen: const StopwatchTimerScreen(),
      type: ToolType.offline,
      helpContentKey: 'STOPWATCH_TIMER_TOOL',
    ),

    // Color Tools (Offline)
    ToolItem(
      name: 'Color Picker & Converter',
      icon: Icons.color_lens,
      screen: const ColorPickerConverterScreen(),
      type: ToolType.offline,
      helpContentKey: 'COLOR_PICKER_CONVERTER_TOOL',
    ),

    // --- Online Tools ---
    // Document Conversions (Online)
    ToolItem(
      name: 'Word to PDF',
      icon: Icons.description,
      screen: const WebViewScreen(
        title: 'Word to PDF Converter',
        url: 'https://smallseotools.com/word-to-pdf/',
        helpContentKey: 'WEB_WORD_TO_PDF',
      ),
      type: ToolType.online,
      helpContentKey: 'WEB_WORD_TO_PDF',
    ),
    ToolItem(
      name: 'PDF to Word',
      icon: Icons.text_snippet,
      screen: const WebViewScreen(
        title: 'PDF to Word Converter',
        url: 'https://smallseotools.com/pdf-to-word-converter/',
        helpContentKey: 'WEB_PDF_TO_WORD',
      ),
      type: ToolType.online,
      helpContentKey: 'WEB_PDF_TO_WORD',
    ),
    ToolItem(
      name: 'PowerPoint to PDF',
      icon: Icons.slideshow,
      screen: const WebViewScreen(
        title: 'PowerPoint to PDF Converter',
        url: 'https://smallseotools.com/powerpoint-to-pdf/',
        helpContentKey: 'WEB_PPT_TO_PDF',
      ),
      type: ToolType.online,
      helpContentKey: 'WEB_PPT_TO_PDF',
    ),
    ToolItem(
      name: 'Excel to PDF',
      icon: Icons.table_chart,
      screen: const WebViewScreen(
        title: 'Excel to PDF Converter',
        url: 'https://smallseotools.com/excel-to-pdf/',
        helpContentKey: 'WEB_EXCEL_TO_PDF',
      ),
      type: ToolType.online,
      helpContentKey: 'WEB_EXCEL_TO_PDF',
    ),

    // Image Tools (Online)
    ToolItem(
      name: 'Crop Image',
      icon: Icons.crop_free,
      screen: const WebViewScreen(
        title: 'Crop Image Online',
        url: 'https://smallseotools.com/crop-image/',
        helpContentKey: 'WEB_CROP_IMAGE',
      ),
      type: ToolType.online,
      helpContentKey: 'WEB_CROP_IMAGE',
    ),
    ToolItem(
      name: 'Image Compressor',
      icon: Icons.photo_size_select_large,
      screen: const WebViewScreen(
        title: 'Image Compressor Online',
        url: 'https://smallseotools.com/image-compressor/',
        helpContentKey: 'WEB_IMAGE_COMPRESSOR',
      ),
      type: ToolType.online,
      helpContentKey: 'WEB_IMAGE_COMPRESSOR',
    ),

    // Website Tools (Online)
    ToolItem(
      name: 'Website Screenshot',
      icon: Icons.web_asset,
      screen: const WebViewScreen(
        title: 'Website Screenshot Generator',
        url: 'https://smallseotools.com/website-screenshot/',
        helpContentKey: 'WEB_WEBSITE_SCREENSHOT',
      ),
      type: ToolType.online,
      helpContentKey: 'WEB_WEBSITE_SCREENSHOT',
    ),
    ToolItem(
      name: 'Favicon Generator',
      icon: Icons.star_border,
      screen: const WebViewScreen(
        title: 'Favicon Generator',
        url: 'https://smallseotools.com/favicon-generator/',
        helpContentKey: 'WEB_FAVICON_GENERATOR',
      ),
      type: ToolType.online,
      helpContentKey: 'WEB_FAVICON_GENERATOR',
    ),

    // Video Downloaders (Online)
    ToolItem(
      name: 'Any Video Downloader',
      icon: Icons.download_for_offline,
      screen: const WebViewScreen(
        title: 'Any Video Downloader',
        url: 'https://smallseotools.com/online-video-downloader/',
        helpContentKey: 'WEB_ANY_VIDEO_DOWNLOADER',
      ),
      type: ToolType.online,
      helpContentKey: 'WEB_ANY_VIDEO_DOWNLOADER',
    ),
    ToolItem(
      name: 'Facebook Video Downloader',
      icon: Icons.facebook,
      screen: const WebViewScreen(
        title: 'Facebook Video Downloader',
        url:
            'https://en1.savefrom.net/9-how-to-download-facebook-video-6CY.html',
        helpContentKey: 'WEB_FACEBOOK_VIDEO_DOWNLOADER',
      ),
      type: ToolType.online,
      helpContentKey: 'WEB_FACEBOOK_VIDEO_DOWNLOADER',
    ),
    ToolItem(
      name: 'Twitter Video Downloader',
      icon: Icons.alternate_email,
      screen: const WebViewScreen(
        title: 'Twitter Video Downloader',
        url: 'https://smallseotools.com/twitter-video-downloader/',
        helpContentKey: 'WEB_TWITTER_VIDEO_DOWNLOADER',
      ),
      type: ToolType.online,
      helpContentKey: 'WEB_TWITTER_VIDEO_DOWNLOADER',
    ),
    ToolItem(
      name: 'Instagram Video Downloader',
      icon: Icons.camera_alt,
      screen: const WebViewScreen(
        title: 'Instagram Video Downloader',
        url: 'https://smallseotools.com/instagram-video-downloader/',
        helpContentKey: 'WEB_INSTAGRAM_VIDEO_DOWNLOADER',
      ),
      type: ToolType.online,
      helpContentKey: 'WEB_INSTAGRAM_VIDEO_DOWNLOADER',
    ),
    ToolItem(
      name: 'Pinterest Video Downloader',
      icon: Icons.push_pin,
      screen: const WebViewScreen(
        title: 'Pinterest Video Downloader',
        url: 'https://smallseotools.com/pinterest-video-downloader/',
        helpContentKey: 'WEB_PINTEREST_VIDEO_DOWNLOADER',
      ),
      type: ToolType.online,
      helpContentKey: 'WEB_PINTEREST_VIDEO_DOWNLOADER',
    ),
    ToolItem(
      name: 'TikTok Video Downloader',
      icon: Icons.music_note,
      screen: const WebViewScreen(
        title: 'TikTok Video Downloader',
        url: 'https://smallseotools.com/tiktok-video-downloader/',
        helpContentKey: 'WEB_TIKTOK_VIDEO_DOWNLOADER',
      ),
      type: ToolType.online,
      helpContentKey: 'WEB_TIKTOK_VIDEO_DOWNLOADER',
    ),

    // SEO Tools (Online)
    ToolItem(
      name: 'Keyword Suggestion',
      icon: Icons.lightbulb_outline,
      screen: const WebViewScreen(
        title: 'Keyword Suggestion Tool',
        url: 'https://smallseotools.com/keyword-suggestion-tool/',
        helpContentKey: 'WEB_KEYWORD_SUGGESTION',
      ),
      type: ToolType.online,
      helpContentKey: 'WEB_KEYWORD_SUGGESTION',
    ),
  ];

  // Helper to get tools by type (for category screens)
  static List<ToolItem> getPdfTools() =>
      allTools
          .where(
            (tool) =>
                tool.screen is ImageToPdfScreen ||
                tool.screen is MergePdfScreen ||
                tool.screen is SplitPdfScreen ||
                tool.screen is CompressPdfScreen ||
                (tool.type == ToolType.online &&
                    tool.helpContentKey.startsWith('WEB_') &&
                    tool.helpContentKey.contains('PDF')),
          )
          .toList();

  static List<ToolItem> getTextTools() =>
      allTools
          .where(
            (tool) =>
                tool.screen is OcrScreen ||
                tool.screen is PasswordGeneratorScreen ||
                tool.screen is TextManipulationScreen ||
                tool.screen is FindReplaceScreen,
          )
          .toList();

  static List<ToolItem> getImageTools() =>
      allTools
          .where(
            (tool) =>
                tool.screen is ImageResizerScreen ||
                tool.screen is ImageCropperScreen ||
                tool.screen is ImageFormatConverterScreen ||
                (tool.type == ToolType.online &&
                    (tool.helpContentKey == 'WEB_CROP_IMAGE' ||
                        tool.helpContentKey == 'WEB_IMAGE_COMPRESSOR')),
          )
          .toList();

  static List<ToolItem> getVideoDownloaders() =>
      allTools
          .where(
            (tool) =>
                tool.type == ToolType.online &&
                tool.helpContentKey.startsWith('WEB_') &&
                tool.helpContentKey.contains('VIDEO_DOWNLOADER'),
          )
          .toList();

  static List<ToolItem> getQrBarcodeTools() =>
      allTools
          .where(
            (tool) =>
                tool.screen is QrGeneratorScreen ||
                tool.screen is QrScannerScreen,
          )
          .toList();

  // Helper to get Calculator tools
  static List<ToolItem> getCalculatorTools() =>
      allTools
          .where(
            (tool) =>
                tool.screen is AgeCalculatorScreen ||
                tool.screen is DiscountCalculatorScreen ||
                tool.screen is BmiCalculatorScreen,
          )
          .toList();

  // Helper to get Generator tools
  static List<ToolItem> getGeneratorsTools() =>
      allTools
          .where(
            (tool) =>
                tool.screen is FakeNameGeneratorScreen ||
                tool.screen is RandomTextGeneratorScreen ||
                tool.screen is FakeAddressGeneratorScreen ||
                tool.screen is RandomNumberGeneratorScreen ||
                tool.screen is RangeNumberPickerScreen,
          )
          .toList();

  // Helper to get Time tools - Ensure this correctly filters for StopwatchTimerScreen
  static List<ToolItem> getTimeTools() =>
      allTools.where((tool) => tool.screen is StopwatchTimerScreen).toList();

  // Helper to get Color tools - Ensure this correctly filters for ColorPickerConverterScreen
  static List<ToolItem> getColorTools() =>
      allTools
          .where((tool) => tool.screen is ColorPickerConverterScreen)
          .toList();

  // --- Categories for Modal Sheet ---
  static final List<CategoryItem> toolCategories = [
    CategoryItem(
      name: 'PDF Tools',
      icon: Icons.picture_as_pdf,
      screen: const PdfToolsCategoryScreen(),
    ),
    CategoryItem(
      name: 'Text Tools',
      icon: Icons.text_fields,
      screen: const TextToolsCategoryScreen(),
    ),
    CategoryItem(
      name: 'Image Tools',
      icon: Icons.image,
      screen: const ImageToolsCategoryScreen(),
    ),
    CategoryItem(
      name: 'Video Downloaders',
      icon: Icons.video_collection,
      screen: const VideoDownloadersCategoryScreen(),
    ),
    CategoryItem(
      name: 'QR & Barcode',
      icon: Icons.qr_code_scanner,
      screen: const QrBarcodeToolsCategoryScreen(),
    ),
    CategoryItem(
      name: 'Unit Converter',
      icon: Icons.straighten,
      screen: const UnitConverterScreen(),
    ),
    CategoryItem(
      name: 'Currency Converter',
      icon: Icons.currency_exchange,
      screen: const CurrencyConverterScreen(),
    ),
    CategoryItem(
      name: 'Calculators',
      icon: Icons.calculate,
      screen: const CalculatorsCategoryScreen(),
    ),
    CategoryItem(
      name: 'Generators',
      icon: Icons.auto_awesome,
      screen: const GeneratorsCategoryScreen(),
    ),
    // Ensure Time Tools category is explicitly added here and references the correct screen
    CategoryItem(
      name: 'Time Tools',
      icon: Icons.access_time,
      screen: const TimeToolsCategoryScreen(),
    ),
    // Ensure Color Tools category is explicitly added here and references the correct screen
    CategoryItem(
      name: 'Color Tools',
      icon: Icons.color_lens,
      screen: const ColorToolsCategoryScreen(),
    ),
  ];
}
