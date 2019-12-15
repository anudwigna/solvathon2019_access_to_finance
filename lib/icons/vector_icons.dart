import 'package:flutter/widgets.dart';

import 'glyph_map.dart';

enum IconProvider {
  AntDesign,
  Entypo,
  EvilIcons,
  Feather,
  FontAwesome,
  FontAwesome5,
  Foundation,
  Ionicons,
  MaterialIcons,
  MaterialCommunityIcons,
  Octicons,
  Zocial,
  SimpleLineIcons,
}

class VectorIcons {
  VectorIcons._();

  static IconData fromName(
    String iconName, {
    IconProvider provider = IconProvider.MaterialIcons,
  }) {
    final _exception = Exception(
        "No icon found for the name '$iconName'.\n Please verify icon name at https://oblador.github.io/react-native-vector-icons");
    iconName = iconName?.trim();
    switch (provider) {
      case IconProvider.AntDesign:
        if (AntDesign.containsKey(iconName))
          return IconData(AntDesign[iconName], fontFamily: 'AntDesign');
        throw _exception;
      case IconProvider.Entypo:
        if (Entypo.containsKey(iconName))
          return IconData(Entypo[iconName], fontFamily: 'Entypo');
        throw _exception;
      case IconProvider.EvilIcons:
        if (EvilIcons.containsKey(iconName))
          return IconData(EvilIcons[iconName], fontFamily: 'EvilIcons');
        throw _exception;
      case IconProvider.Feather:
        if (Feather.containsKey(iconName))
          return IconData(Feather[iconName], fontFamily: 'Feather');
        throw _exception;
      case IconProvider.FontAwesome:
        if (FontAwesome.containsKey(iconName))
          return IconData(FontAwesome[iconName], fontFamily: 'FontAwesome');
        throw _exception;
      case IconProvider.FontAwesome5:
        if (FontAwesome5.containsKey(iconName)) {
          if (FontAwesome5Meta['brands'].contains(iconName))
            return IconData(FontAwesome5[iconName],
                fontFamily: 'FontAwesomeBrands');
          if (FontAwesome5Meta['regular'].contains(iconName))
            return IconData(FontAwesome5[iconName],
                fontFamily: 'FontAwesomeRegular');
          return IconData(FontAwesome5[iconName],
              fontFamily: 'FontAwesomeSolid');
        }
        throw _exception;
      case IconProvider.Foundation:
        if (Foundation.containsKey(iconName))
          return IconData(Foundation[iconName], fontFamily: 'Foundation');
        throw _exception;
      case IconProvider.Ionicons:
        if (Ionicons.containsKey(iconName))
          return IconData(Ionicons[iconName], fontFamily: 'Ionicons');
        throw _exception;
      case IconProvider.MaterialCommunityIcons:
        if (MaterialCommunityIcons.containsKey(iconName))
          return IconData(MaterialCommunityIcons[iconName],
              fontFamily: 'MaterialCommunityIcons');
        throw _exception;
      case IconProvider.MaterialIcons:
        if (MaterialIcons.containsKey(iconName))
          return IconData(MaterialIcons[iconName], fontFamily: 'MaterialIcons');
        throw _exception;
      case IconProvider.Octicons:
        if (Octicons.containsKey(iconName))
          return IconData(Octicons[iconName], fontFamily: 'Octicons');
        throw _exception;
      case IconProvider.SimpleLineIcons:
        if (SimpleLineIcons.containsKey(iconName))
          return IconData(SimpleLineIcons[iconName],
              fontFamily: 'SimpleLineIcons');
        throw _exception;
      case IconProvider.Zocial:
        if (Zocial.containsKey(iconName))
          return IconData(Zocial[iconName], fontFamily: 'Zocial');
        throw _exception;
      default:
        throw Exception("Icon Provider Not Found");
    }
  }
}
