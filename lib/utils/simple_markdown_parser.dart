import 'package:flutter/material.dart';

class SimpleMarkdownParser {
  static List<TextSpan> parse(String markdown, BuildContext context) {
    final List<TextSpan> spans = [];
    final TextStyle defaultStyle = Theme.of(context).textTheme.bodyMedium!
        .copyWith(color: Theme.of(context).colorScheme.onSurface);
    final TextStyle boldStyle = defaultStyle.copyWith(
      fontWeight: FontWeight.bold,
    );
    final TextStyle italicStyle = defaultStyle.copyWith(
      fontStyle: FontStyle.italic,
    );
    final TextStyle boldItalicStyle = defaultStyle.copyWith(
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
    );
    final TextStyle headingStyle1 = Theme.of(
      context,
    ).textTheme.headlineSmall!.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.bold,
    );
    // ignore: unused_local_variable
    final TextStyle headingStyle2 = Theme.of(
      context,
    ).textTheme.titleLarge!.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.bold,
    );
    final TextStyle listItemStyle = defaultStyle;

    // Split by lines to handle list items and headings
    final List<String> lines = markdown.split('\n');

    for (String line in lines) {
      line =
          line.trim(); // Trim leading/trailing whitespace for line processing

      if (line.isEmpty) {
        // Add an empty TextSpan for line breaks between paragraphs/list items
        spans.add(TextSpan(text: '\n', style: defaultStyle));
        continue;
      }

      // Handle Headings (e.g., **PDF Tools Help:**)
      if (line.startsWith('**') && line.endsWith(':**')) {
        final String headingText = line.substring(2, line.length - 3).trim();
        spans.add(TextSpan(text: '$headingText:\n', style: headingStyle1));
        continue;
      }

      // Handle List Items (e.g., * **Convert Image to PDF:**)
      if (line.startsWith('* ')) {
        final String listItemContent = line.substring(2).trim();
        spans.add(
          TextSpan(text: '• ', style: listItemStyle),
        ); // Add a bullet point
        spans.addAll(
          _parseInlineFormatting(
            listItemContent,
            defaultStyle,
            boldStyle,
            italicStyle,
            boldItalicStyle,
          ),
        );
        spans.add(
          TextSpan(text: '\n', style: defaultStyle),
        ); // New line after list item
        continue;
      }

      // Handle general paragraphs and inline formatting
      spans.addAll(
        _parseInlineFormatting(
          line,
          defaultStyle,
          boldStyle,
          italicStyle,
          boldItalicStyle,
        ),
      );
      spans.add(
        TextSpan(text: '\n', style: defaultStyle),
      ); // Add a newline after each parsed line
    }

    return spans;
  }

  static List<TextSpan> _parseInlineFormatting(
    String text,
    TextStyle defaultStyle,
    TextStyle boldStyle,
    TextStyle italicStyle,
    TextStyle boldItalicStyle,
  ) {
    final List<TextSpan> inlineSpans = [];
    RegExp regex = RegExp(
      r'(\*\*\*.*?\*\*\*|\*\*.*?\*\*|\*.*?\*)',
    ); // Matches ***bold/italic***, **bold**, *italic*

    int currentMatchEnd = 0;
    for (RegExpMatch match in regex.allMatches(text)) {
      // Add text before the match
      if (match.start > currentMatchEnd) {
        inlineSpans.add(
          TextSpan(
            text: text.substring(currentMatchEnd, match.start),
            style: defaultStyle,
          ),
        );
      }

      String matchedText = match.group(0)!;
      String innerText = matchedText.substring(
        matchedText.startsWith('***')
            ? 3
            : (matchedText.startsWith('**') ? 2 : 1),
        matchedText.endsWith('***')
            ? matchedText.length - 3
            : (matchedText.endsWith('**')
                ? matchedText.length - 2
                : matchedText.length - 1),
      );

      if (matchedText.startsWith('***') && matchedText.endsWith('***')) {
        inlineSpans.add(TextSpan(text: innerText, style: boldItalicStyle));
      } else if (matchedText.startsWith('**') && matchedText.endsWith('**')) {
        inlineSpans.add(TextSpan(text: innerText, style: boldStyle));
      } else if (matchedText.startsWith('*') && matchedText.endsWith('*')) {
        inlineSpans.add(TextSpan(text: innerText, style: italicStyle));
      } else {
        // Fallback if regex matched something unexpected (shouldn't happen with this regex)
        inlineSpans.add(TextSpan(text: matchedText, style: defaultStyle));
      }
      currentMatchEnd = match.end;
    }

    // Add any remaining text after the last match
    if (currentMatchEnd < text.length) {
      inlineSpans.add(
        TextSpan(text: text.substring(currentMatchEnd), style: defaultStyle),
      );
    }

    return inlineSpans;
  }
}
