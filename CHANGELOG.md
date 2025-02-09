## Changelog

This project follows [Semantic Versioning (SemVer)](https://semver.org/spec/v2.0.0.html).

### 1.1.2

- Fixed: there should be no error messages when there are no config files in the top-level config directory, since the recommended practice is now to use subdirectories corresponding to DNS zones
- Updated example configs to use subdirectories

### 1.1.1

- Fixed errors in documentation
	- Config directories for installations with Docker (with and without Compose) are different, and have now been noted
	- `docker run` instructions was missing a mount

### 1.1

- Added support for multiple DNS zones
- Improved documentation

### 1.0.1

- Fixed: Docker Compose now builds from latest release version (branch `release-v1`) rather than latest dev version
- Updated documentation to install from latest release as well

### 1.0

- Initial release
