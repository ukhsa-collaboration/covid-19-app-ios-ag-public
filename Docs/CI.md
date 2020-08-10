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
- [Secrets](#secrets)
  - [Access to other repos](#access-to-other-repos)
    - [`REPOS_ACCESS_ACTOR`](#repos_access_actor)
    - [`REPOS_ACCESS_TOKEN`](#repos_access_token)
  - [Apple Development](#apple-development)
    - [`BASE64_ENCODED_IDENTITY`](#base64_encoded_identity)
    - [`IDENTITY_PASSWORD`](#identity_password)
    - [`BASE64_ENCODED_PROFILE`](#base64_encoded_profile)
  - [App Store Connect](#app-store-connect)
    - [`ASC_USERNAME`](#asc_username)
    - [`ASC_PASSWORD`](#asc_password)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Workflows

## test

Runs all automated tests when there is a PR against `master`.

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

The script looks for tags of the currect shape, with correct `variant` set to `scenarios` and `build` set to the current build number, but ignores the version. For example, these would both match as a tag for build 5:

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

# Secrets

## Access to other repos

GitHub provides builtin API tokens as part of the workflow to access the _current_ repo. Access to other repositories is managed separately.

### `REPOS_ACCESS_ACTOR`

Username of an account in the `Service Accounts` GitHub team.

Accounts in this normally only have read access to other repos.

### `REPOS_ACCESS_TOKEN`

Personal access token for `REPOS_ACCESS_ACTOR` with repo permissions.

## Apple Development

### `BASE64_ENCODED_IDENTITY`

This is a base64 encoded p12 file, containing an Apple Distribution identity (private key and certificate). 

### `IDENTITY_PASSWORD`

Password of the `BASE64_ENCODED_IDENTITY` p12 file.

### `BASE64_ENCODED_PROFILE`

A wildcard provisioning profile with necessary entitlements for App Store builds.

This profile should have correct entitlements for the app.

## App Store Connect

### `ASC_USERNAME`

An App Store Connect username (for example to be used with `altool`). This account must have access to the apps on App Store Connect with a Developer role.

### `ASC_PASSWORD`

The (app-specific) password for `ASC_USERNAME`.
