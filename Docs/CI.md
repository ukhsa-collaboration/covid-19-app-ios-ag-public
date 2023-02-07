# Project CI Infrastructure

We use GitHub Actions to help automate testing and deployment.

_Note_

Since this document is manually updated, parts of it may be out of date. If you notice anything in this document does not match the CI, please contact a member of the team who is familiar with the workflows to update this.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Workflows](#workflows)
  - [test](#test)
  - [deploy](#deploy)
  - [monitor-version](#monitor-version)
  - [report](#report)
  - [update_translations](#update_translations)
    - [Troubleshooting](#troubleshooting)
- [Secrets](#secrets)
  - [Access to other repos](#access-to-other-repos)
    - [`REPOS_ACCESS_ACTOR`](#repos_access_actor)
    - [`REPOS_ACCESS_TOKEN`](#repos_access_token)
  - [Access to AWS](#access-to-aws)
    - [`AWS_ACCESS_KEY_ID`](#aws_access_key_id)
    - [`AWS_SECRET_ACCESS_KEY`](#aws_secret_access_key)
  - [Apple Development](#apple-development)
    - [`BASE64_ENCODED_IDENTITY`](#base64_encoded_identity)
    - [`IDENTITY_PASSWORD`](#identity_password)
    - [`BASE64_ENCODED_PROFILE`](#base64_encoded_profile)
  - [App Store Connect](#app-store-connect)
    - [`ASC_API_KEY`](#asc_api_key)
    - [`ASC_API_KEY_ID`](#asc_api_key_id)
    - [`ASC_API_KEY_ISSUER_ID`](#asc_api_key_issuer_id)
  - [Access to Lokalise](#access-to-lokalise)
    - [`LOKALISE_PROJECT_ID`](#lokalise_project_id)
    - [`LOKALISE_API_TOKEN`](#lokalise_api_token)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Workflows

## test

Runs all automated tests when there is a PR against `master`.

* **Test**: The default test plan `AllTests` runs all our unit tests and UI tests in English on the Simulator. This happens for all PRs.
  * Generally these tests **must** pass before GitHub will allow you to merge the PR.
* **Language Tests**: There is an additional test plan, `LanguageTests`, which runs a subset of the UI tests in all the languages the app supports. This is run when the pull request contains changes in the localisation files.
  * Because `LanguageTests` takes a long time to run (up to 6 hours), the chance of a spurious failure (or a 'flake') is quite high.
  * You don't need to wait for it to complete to merge the pull request, and can even merge your pull request if it failed.
  * **However,** you should not do this unless you can positively be sure that the failure was a flake (i.e. you have failed to reproduce it locally and the pull request doesn't touch the area where the failure happened.) Otherwise you could miss legitimate failures that might highlight a bug in the app.
  * In particular, **do not ignore these tests** if they fail on a pull request raised by the [update_translations](#update_translations) workflow. This could show that there's a problem with the imported copy. This means you shouldn't turn on auto-merge for these pull requests, because it will automatically merge as soon as the shorter `AllTests` plan is run.

## deploy

This job is triggered after a push to master. It does two things:

* Runs all automated tests.
* If the tests pass, it checks if there is a tag associated with the current build number.
* If there’s no tag for the associated build, it attempts to upload a new build to App Store Connect.
* If the build is successful, it adds the relevant tag to the repo.

The build tags are in the form `$variant-v$version-$build`. For example:

* `scenarios-v1.0-4`
* `production-v1.0.3-178`

## monitor-version

This jobs runs periodically. It checks the build number on `master`. If there’s a tag for the build number, but there has been new commits since then, it will increment the build number and commits to `master`.

The script looks for tags of the correct shape, with correct `variant` set to `scenarios` and `build` set to the current build number, but ignores the version. For example, these would both match as a tag for build 5:

* `scenarios-v1.0-5`
* `scenarios-somethingelse-5`

These would not match:

* `scenarios-v1.0-4`
* `production-v1.0-5`
* `scenarios-multiple-parts-5`

## report

This jobs runs periodically. It

* runs UI tests in “report” mode. This will generate screenshots and content that is used for documentation.
* creates an archive of the app and uses it to generate artefact reports.
* generates static web content from these reports and uploads them as artefacts.

## update_translations

Runs on demand. It requests an updated set of `Localizable.strings` and `Localizable.stringsdict` files from our localisation tool, moves them into place and creates a pull request for this change.

If you like, you can specify a 'slug' to put at the front of the commit message - e.g. if you want to include ticket numbers, etc.

You should always wait to see if the localisation tests (the test plan that runs our UI tests in all languages) pass before approving and merging this change. This can take a while - up to 5 hours.

### Troubleshooting

If the "Update Translations" job has recently started failing with an error that looks like this:

```
Requesting translations...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed

  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100   306    0    44  100   262     69    415 --:--:-- --:--:-- --:--:--   487
Downloading translations...
curl: no URL specified!
```

...it might be because the person who created the current Lokalise API token has left, or been removed from our Lokalise team. For context, Lokalise API keys are specific to individual users, and **not** shared between everyone on the project.

To fix it:

1. Get a person who has Lokalise access and will be on the project for a while to [generate a new API token on Lokalise](https://docs.lokalise.com/en/articles/1929556-api-tokens) under their user name;
2. Update the `LOKALISE_API_TOKEN` secret;
3. Re-run the "Update Translations" job to see if it worked.


# Secrets

These are configured in the repository settings on GitHub. You need to be an admin to update them and might need to enter sudo mode.

## Access to other repos

GitHub provides builtin API tokens as part of the workflow to access the _current_ repo. Access to other repositories is managed separately.

### `REPOS_ACCESS_ACTOR`

Username of an account in the `Service Accounts` GitHub team.

Accounts in this normally only have read access to other repos.

### `REPOS_ACCESS_TOKEN`

Personal access token for `REPOS_ACCESS_ACTOR` with repo permissions.

## Access to AWS

Test and App reports get uploaded to an S3 bucket for further visualization and documentation tools to consume. To perform this, a technical user account is used. The build environment authenticates as that user programmatically via access key ID and secret access key. The user's access is limited to the `dev-mobile-build-reports`, where they are permitted to `s3:PutObject`, `s3:GetObject`, `s3:ListBucket` and `s3:DeleteObject`.

### `AWS_ACCESS_KEY_ID`

Access key ID for the technical user.

### `AWS_SECRET_ACCESS_KEY`

Secret access key for the technical user.

## Apple Development

### `BASE64_ENCODED_IDENTITY`

This is a base64 encoded p12 file, containing an Apple Distribution identity (private key and certificate). 

### `IDENTITY_PASSWORD`

Password of the `BASE64_ENCODED_IDENTITY` p12 file.

### `BASE64_ENCODED_PROFILE`

A distribution provisioning profile with necessary entitlements for App Store builds.

This profile should have correct entitlements for the app. The profile should use a wildcard app ID as it will be used for both Production and Scenarios apps.

### `KEYCHAIN_PASSWORD`

Password used for new keychains created on the runner.

## App Store Connect

### `ASC_API_KEY`

An App Store Connect API Key. This key must have developer role access to the app on App Store Connect.

This key is the content of the `p8` generated by App Store Connect without any modifications.

### `ASC_API_KEY_ID`

The ID of the key.

### `ASC_API_KEY_ISSUER_ID`

The issuer ID for the key.

## Access to Lokalise

Copy for the app is managed in Lokalise. We use a script to download the latest copy and import it to the app. 

### `LOKALISE_PROJECT_ID`

The project id for this project on Lokalise.

### `LOKALISE_API_TOKEN`

The API token from Lokalise to get access to the copy for this project.

**Note:** Lokalise API tokens are specific to individual people, not shared amongst teams/projects. If the `update_translations` job has started failing, it might be because the user who created the Lokalise API token has left. Create a new token and update this secret to fix the problem.

