# 05 — Deliver the brand and compact presentation

**What to build:** A recognizable production FloatClock identity across the App Icon, toggle, and primary compact Dynamic Island presentation, following the reference's concept without copying an SF Symbol.

**Blocked by:** 02 — Start one FloatClock from the only switch.

**Mode:** HITL — completion requires visual confirmation of the original mark and compact presentation.

**Status:** resolved

- [x] The app has an original alarm-clock App Icon inspired by the reference's pink-red rounded-square and white-clock concept.
- [x] The brand mark isn't an SF Symbol or a confusingly similar reproduction of one.
- [x] A simplified small-size-safe form of the same mark appears in the compact leading region.
- [x] Compact trailing content displays white, monospaced system elapsed-duration text with no decimal digit.
- [x] The main toggle uses the same pink-red brand accent.
- [x] The app uses the system background in light and dark appearance, and the Live Activity doesn't draw a competing pill behind the Dynamic Island.
- [x] Visual review confirms the App Icon and compact mark remain recognizable at their actual sizes and that the compact layout matches the intended left-mark/right-time composition.

## Result

The shared pink-red accent lives in `FloatClockBrand`. The Live Activity no longer uses `Image(systemName: "clock")`; compact leading, minimal, expanded leading, and the lock/banner content use an original SwiftUI vector `FloatClockMark` (pink-red rounded square + simplified white clock face, all drawn in one coordinate system so hands originate at the face center). Compact trailing duration is system timer text with monospaced white digits and no decimal. The main toggle uses `.tint(.floatClockAccent)`. The system owns the Dynamic Island shape and the app background, so no competing pill is drawn. The App Icon is the same mark exported to a 1024×1024 PNG in an Asset Catalog `AppIcon.appiconset` (single universal size); `ASSETCATALOG_COMPILER_APPICON_NAME` is wired in `project.yml`. The compact mark was visually confirmed at actual Dynamic Island size on device; the App Icon shares the identical geometry. Device build succeeds and all thirteen tests pass.

