import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:MunshiG/models/category/category.dart';
import 'package:MunshiG/providers/preference_provider.dart';

import '../resource_map.dart';

class AdaptiveText extends StatelessWidget {
  final String data;
  final int maxLines;
  final TextOverflow overflow;
  final bool softWrap;
  final TextStyle style;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final double textScaleFactor;
  final Category category;

  AdaptiveText(
    this.data, {
    Key key,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.style,
    this.textAlign,
    this.textDirection,
    this.textScaleFactor,
    this.category,
  })  : assert(
          data != null,
          'A non-null String must be provided to a AdaptiveText widget.',
        ),
        assert(data != '' || category != null,
            'Both data and category cannot have value.'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(
      builder: (context, preferenceProvider, _) => Text(
        preferenceProvider.language == Lang.EN
            ? category == null ? data : category.en ?? data
            : category == null
                ? ResourceMap[data.toLowerCase()] ?? data
                : category.np ?? data,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
        style: style,
        textAlign: textAlign,
        textDirection: textDirection,
        textScaleFactor: textScaleFactor,
      ),
    );
  }
}
