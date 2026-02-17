# Contributing to Zupa na Plantach

Thank you for your interest in contributing! This guide will help you get started.

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Follow the setup instructions in [README.md](README.md#getting-started)
4. Create a feature branch from `main`

## Development Workflow

1. Make sure all tests pass before starting:
   ```bash
   bundle exec rspec
   yarn test
   ```
2. Make your changes
3. Add tests for new functionality
4. Ensure code style is correct:
   ```bash
   bundle exec standardrb
   ```
5. Commit your changes with a clear, descriptive message
6. Push to your fork and open a Pull Request

## Code Style

- **Ruby:** Follow [Standard Ruby](https://github.com/testdouble/standard) — enforced via `bundle exec standardrb`
- **TypeScript/React:** ESLint + Prettier
- **CSS:** BEM methodology for class naming, SCSS for styling
- **Components:** Follow Atomic Design methodology

## Testing

- Ruby: RSpec + FactoryBot
- Frontend: Jest + React Testing Library
- All new features and bug fixes should include tests

## Pull Requests

- Keep PRs focused — one feature or fix per PR
- Include a clear description of what changed and why
- Reference any related issues
- Make sure CI passes before requesting review

## Reporting Issues

- Use GitHub Issues to report bugs or suggest features
- Include steps to reproduce for bug reports
- Check existing issues before creating a new one

## Security

If you discover a security vulnerability, please see [SECURITY.md](SECURITY.md) for responsible disclosure instructions.
