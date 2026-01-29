# Plan: Add EduRisk Logo and Update App Name

Update the Flutter app from "Student Progress"/"Flutter Application 1" to **EduRisk** across all platforms, and add a custom logo as the app icon.

## Steps

1. **Create and add logo asset** — Create the logo image file (PNG recommended, 1024×1024px minimum), place it in `assets/images/logo.png`, and uncomment/configure the assets section in pubspec.yaml.

2. **Update Flutter app name** — Change the `title` field from `'Student Progress'` to `'EduRisk'` in lib/main.dart (MyApp widget).

3. **Update iOS app name** — Change `CFBundleDisplayName` to `"EduRisk"` and `CFBundleName` to `"edurisk"` in ios/Runner/Info.plist.

4. **Update Android app name** — Change `android:label` to `"EduRisk"` in android/app/src/main/AndroidManifest.xml.

5. **Replace app icons** — Replace default Flutter icons with your EduRisk logo in iOS (ios/Runner/Assets.xcassets/AppIcon.appiconset/) and Android (android/app/src/main/res/mipmap-*/ic_launcher.png) — requires icons in multiple sizes per platform specifications.

6. **Rebuild app** — Run `flutter clean` and `flutter pub get`, then rebuild for iOS/Android to apply platform-specific changes.

## Further Considerations

1. **Logo design** — You mentioned "make your own" — should I create a simple logo design for EduRisk (suggest: text-based "EduRisk" with professional styling, or educational/risk-themed icon), or will you provide the logo image?

2. **Icon generation** — iOS requires ~13 different icon sizes (20×20 to 1024×1024); Android requires 5 sizes (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi). Should I use a tool like `flutter pub add flutter_launcher_icons` to automate multi-size icon generation from a single source image?
