# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Open source documentation and contribution guidelines
- LICENSE (MIT)
- README with comprehensive installation and usage instructions
- CONTRIBUTING.md with development guidelines
- CODE_OF_CONDUCT.md (Contributor Covenant)
- SECURITY.md with vulnerability reporting process
- GitHub issue templates (bug report, feature request, question)
- GitHub pull request template
- GitHub Actions CI/CD workflow
- .env.example file for environment configuration

## [0.1.0] - 2025-11-06

### Added

- Initial release of Bubble RSS feed aggregator
- User authentication and account management
- RSS/Atom feed subscription and management
- News feed with aggregated articles from subscribed sources
- Feed source management (add, remove, toggle active/inactive)
- Automatic feed fetching with background jobs (Oban)
- Metadata extraction from web pages (OpenGraph, Twitter Cards, HTML parsing)
- Real-time UI updates with Phoenix LiveView
- Landing page
- Multi-step source feed form in settings
- Database migrations with timestamp and UUID defaults

### Changed

- Renamed "feed" to "news" throughout the application
- Moved `is_active` column from `feed_sources` to `users_feed_sources`

### Fixed

- Tests failing due to application changes
- Various bug fixes and improvements

### Technical Details

- Built with Elixir 1.18 and Phoenix 1.7.18
- Phoenix LiveView for real-time interface
- PostgreSQL database with Ecto
- Oban for background job processing
- Tailwind CSS for styling
- Comprehensive test suite

## [0.0.1] - 2024-08-XX

### Added

- Initial project setup
- Basic Phoenix application structure
- Database schema design

---

## Release Types

- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** in case of vulnerabilities

[Unreleased]: https://github.com/Pleuvens/bubble/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/Pleuvens/bubble/releases/tag/v0.1.0
[0.0.1]: https://github.com/Pleuvens/bubble/releases/tag/v0.0.1
