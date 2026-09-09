
# flutter_native_hybrid
<h1 align="center">
    <br>
    Flutter + Native Android Hybrid
</h1>
<h4 align="center">
 Portfolio project that shows how to combine a Flutter UI with a real native Android feature written in Kotlin + Jetpack Compose.
</h4>
<hr>

### Purpose

Many companies (especially in Sweden) ship apps that mix Flutter with native modules. Recruiters and interviewers often ask:

“Can you work in a hybrid codebase?”

This project answers that question with working code.

## What it shows:

- Clean Flutter architecture using GetX
- Native Android feature in Kotlin + Jetpack Compose
- Communication via MethodChannel and EventChannel
- Clear separation between UI, state, and platform code
- Path to type-safe channels with Pigeon


## Overview:

- A clean Flutter app
- Implementation of native feature using Kotlin + Jetpack Compose
- Connect the two sides safely using platform channels (MethodChannel + EventChannel)

The chosen native feature is a Device Metrics dashboard (battery, memory, network, device info).

## Dependencies

  cupertino_icons: ^1.0.2<br/>
  get:<br/>

## How to use

To clone and run this application, you'll need [Git](https://git-scm.com/downloads)
and [Flutter](https://flutter.dev/docs/get-started/install) installed on your computer.

### Clone this repo

```
gh repo clone abikvaidhya/flutter_native_hybrid
```

### Navigate to the repo

```
cd flutter_native_hybrid
```

### Install dependencies

```
flutter packages get
```

### Run the app

```
flutter run
```
