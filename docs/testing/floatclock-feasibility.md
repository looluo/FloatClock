# FloatClock feasibility gate

Use this checklist for ticket 01. The result is valid only on an iPhone 15 or later without an attached Xcode debugger.

## Preparation

- Choose a personal development team and a unique bundle identifier in Xcode if automatic signing requests them.
- Build and install the `FloatClock` scheme on the physical device.
- Confirm the device has sufficient charge and Low Power Mode is off.
- Launch the app once, turn FloatClock on, and confirm the Live Activity appears.
- Stop the Xcode run session or launch the installed app directly so no debugger remains attached.

## Home Screen observation

1. Launch the installed app and turn FloatClock on.
2. Return to the Home Screen while keeping the display awake.
3. Observe FloatClock for at least 10 consecutive seconds.
4. Record whether elapsed duration visibly advances throughout the observation.

## Result

- Device model:
- iOS version:
- Build commit or identifier:
- Ten-second Home Screen start/end:
- Observed cadence:
- Maximum visible error:
- Pass or fail:
- Additional notes:

If the duration doesn't visibly advance during the short smoke test, stop and preserve the minimal reproduction before considering a change to product semantics or architecture.
