# 09 — Localize and make FloatClock accessible

**What to build:** A complete Simplified Chinese, English, and VoiceOver experience across the one-toggle app, failure alerts, and every FloatClock presentation.

**Blocked by:** 04 — Handle permission failures and rapid input safely; 06 — Support the expanded presentation; 07 — Support the minimal presentation; 08 — Show FloatClock on the Lock Screen.

**Mode:** AFK

**Status:** resolved

- [x] Failure alerts, system Settings guidance, supporting Lock Screen text, and accessibility descriptions are localized in Simplified Chinese and English.
- [x] The product name `FloatClock` remains unchanged, and system timer text owns localized duration formatting.
- [x] The main toggle exposes a meaningful VoiceOver label, current value, and enabled or disabled state.
- [x] Compact, expanded, minimal, and Lock Screen presentations expose meaningful accessible descriptions appropriate to their visible content.
- [x] UI tests verify the main screen and failure paths in both languages without adding persistent controls or explanatory text.
- [x] Accessibility checks verify the toggle semantics and Live Activity descriptions as external behavior rather than private view structure.

## Result

A String Catalog (`FloatClockApp/Localizable.xcstrings`) ships Simplified Chinese for every user-facing literal: the three failure alert titles/messages, the `OK` button, and the toggle's VoiceOver hint. The product name `FloatClock` is left untranslated and duration formatting stays with system timer text. `FloatClockFailureAlert` now returns `LocalizedStringKey`, and the alert title/message/button and the toggle hint resolve through the catalog. The main toggle keeps its `FloatClock` label (value and on/off state are the Toggle's default semantics), gains a localized accessibility hint and an `accessibilityIdentifier`, and its disabled-in-flight state reports dimmed. The `FloatClockMark` exposes an `FloatClock` image accessibility label, and the Lock Screen content combines its children into one accessible description (mark + name + duration); compact/expanded/minimal inherit the mark's label. New localization unit tests load the compiled `en.lproj` and `zh-Hans.lproj` bundles and assert the alert, Settings-guidance, and `OK` strings resolve to the expected translations in each language. Device build succeeds and all sixteen tests pass.

