# NHS COVID-19 AG

An app using Apple’s `ExposureNotification` API to detect contacts with other users of the app that may have had COVID-19.

## Dependencies

All depedencies are fetched using Swift Package Manager. Make sure you have access to the internal dependencies, and that git is properly configured to access these.

## Development

### Running the app on a simulator

The app requires Xcode 11.7+. There are no other dependencies.

### Running the app on a device

This app requires entitlements that Xcode can not set up automatically. In order to run on a device:

* Ensure you are logged into the development team in Xcode.
* Ensure you have a development certificate and that your device is registered. Talk to a member of the team to learn about the latest policy around adding devices.
* Ask one of the technical App Managers to regenerate the provisioning profiles so it includes your device.
* Ask Xcode to download the latest profiles (Preferences > Accounts > Download Manual Profiles).

You should then be able to build and run on a device.

## Documentation

* [App Architecture](Docs/AppArchitecture.md) provides high level description of how the code is structured.
* [CI Workflows](Docs/CI.md) documents how we use GitHub Actions.
* [Development Guides](Docs/Development/Guides)
  * [PRs](Docs/Development/Guides/PRs.md) documents our approach to raising and reviewing PRs.
  * [Using `Domain`](Docs/Development/Guides/UsingDomain.md) is a good starting point for learning how the app’s backend works. 
