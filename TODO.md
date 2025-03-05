# Todo

- [X] Add all build dependencies from https://salsa.debian.org/mozilla-team/firefox/-/blob/esr115/master/debian/control
- [X] Review and edit debian/control
  - [X] Add dependencies
  - [X] Flatten debian/control
- [ ] Add build.sh to a GitHub workflow
  - [ ] Have a workflow task that sends the resulting icecat package to this repository's Releases
- [ ] Separate build.sh into workflow steps
- [ ] Increase idempotency of build.sh/workflow steps
