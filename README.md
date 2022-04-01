# ToGather

A decentralised, secure and robust communications app for use during protests, utilising the Scuttlebutt protocol.

## Obtaining the app
ToGather can be built locally, or a pre-built built binary can be downloaded from the releases section of this repository.

### Build requirements
- As a Flutter application, ToGather requires a Flutter installation along with the Android SDK and build tools to successfully build the app.  
- A libsodium installation is also required to build its cryptographic features.

### Build steps
- Clone repository
- In flutter_scuttlebutt:
  - `flutter pub get`
  - `flutter build apk`

## Testing codebase
Flutter's built-in testing capabilities (`flutter test`) can be used to run unit tests; no unit tests are provided.
