# Raising and Reviewing PRs

Changes to this code base are raised as pull Requests before they are merged into the main branch. The [CI](CI.md) will run automated tests of the PR before they are merged. In addition, each PR needs to be approved by a reviewer.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [What to look for in a PR](#what-to-look-for-in-a-pr)
  - [Amount of changes](#amount-of-changes)
  - [Acceptance Criteria](#acceptance-criteria)
  - [Testing](#testing)
  - [Description](#description)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## What to look for in a PR

The following should guide both creators and reviewers of the PR on what to do.

### Amount of changes

PRs should be kept small and focused on delivering a specific improvement. As a rule of thumb, PRs should have around 100 additions or deletions.

* If possible, create even smaller PRs are encouraged as long as they can be self contained.
* If a change has to impact multiple files, try to make the logic change as small as possible. For example, if refactoring and renaming a method that is used from many places, it might be a good idea to first create a PR that changes the method signature, but keeps its functionality the same otherwise. Then, deliver the functional changes separately.

### Acceptance Criteria

All functional changes in a PR should be covered as part the ACs of a story. Since we prefer small PRs, it’s ok to merge a PR that covers only part of a story. It is also possible that a PR doesn’t have _any_ functional changes and it’s just a refactor to enable future changes.

However, there should not be any functional changes that are _not_ requested by any tickets.

### Testing

Any functional changes should be covered by the appropriate tests, as described in the [App Architecture](AppArchitecture.md).

### Description

Use the PR description as a way to communicate what changes you are making; and what the other developers should be aware of when merging this PR.

Since we create small PRs, they are usually part of a bigger piece of work. If possible, layout the larger plan so the reviewer can understand your motivations more easily.