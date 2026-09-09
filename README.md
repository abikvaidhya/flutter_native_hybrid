## Flutter + Native Android Hybrid

Portfolio project that shows how to combine a Flutter UI with a real native Android feature written
in Kotlin + Jetpack Compose.

### Purpose

Many Swedish companies run mixed codebases: Flutter for most of the UI, and native Kotlin/Compose
for performance-critical or platform-specific features.

In project:

* A clean Flutter app
* Implementation of native feature using Kotlin + Jetpack Compose
* Connect the two sides safely using platform channels (MethodChannel + EventChannel)

The chosen native feature is a Device Metrics dashboard (battery, memory, network, device info).