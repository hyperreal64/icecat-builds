# Todo

- [ ] Add all build dependencies from https://salsa.debian.org/mozilla-team/firefox/-/blob/esr115/master/debian/control
- [ ] Review and edit debian/control
  - [ ] Add dependencies
  - [ ] Flatten debian/control
- [ ] Add build.sh to a GitHub workflow
  - [ ] Have a workflow task that sends the resulting icecat package to this repository's Releases
- [ ] Separate build.sh into steps
- [ ] Increase idempotency of build.sh
