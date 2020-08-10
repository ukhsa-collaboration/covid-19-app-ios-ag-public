# Reporting

A package used for running / reporting automated tests.

You can run integrity checks in different wasy

### From an archive

```bash
swift run Reporter archive $ARCHIVE_PATH --output $REPORT_PATH
```

### From an ipa

```bash
swift run Reporter ipa $IPA_PATH --output $REPORT_PATH
```

### From an Xcode project

```bash
swift run Reporter workspace $WORKSPACE_PATH --scheme $SCHEME --method archive --output AppReport
```

or

```bash
swift run Reporter workspace $WORKSPACE_PATH --scheme $SCHEME --method build --output AppReport
```

Using the archive method produces a more accurate result, but requires signing identity and profile.

You can use this command to configure `xcodebuild` first: 
```bash
swift run Reporter configure --base64-encoded-identity $BASE64_ENCODED_IDENTITY --identity-password $IDENTITY_PASSWORD --base64-encoded-profile $BASE64_ENCODED_PROFILE
```

## Development

Note that Xcode runs the executable in a sandbox, so even though it can *run* the executable, it may not behave as expected.
