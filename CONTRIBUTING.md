# Contributing to Bubble

Thank you for your interest in contributing to Bubble! We welcome contributions from the community and appreciate your help in making this project better.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)
- [Documentation](#documentation)
- [Getting Help](#getting-help)

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to [project maintainers].

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- Elixir 1.18 or higher
- Erlang/OTP 26 or higher
- PostgreSQL
- Node.js 18+
- Git

### Development Setup

1. **Fork the repository** on GitHub

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/bubble.git
   cd bubble
   ```

3. **Add the upstream remote**
   ```bash
   git remote add upstream https://github.com/original-owner/bubble.git
   ```

4. **Install dependencies**
   ```bash
   mix setup
   ```

5. **Create the development database**
   ```bash
   mix ecto.create
   mix ecto.migrate
   ```

6. **Start the development server**
   ```bash
   mix phx.server
   ```

7. **Visit the application**
   Open http://localhost:4000 in your browser

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the behavior
- **Expected behavior**
- **Actual behavior**
- **Screenshots** (if applicable)
- **Environment details** (Elixir version, OS, browser, etc.)
- **Error messages** or logs

Use the bug report template when creating an issue.

### Suggesting Features

Feature suggestions are welcome! When suggesting a feature:

- **Check if it's already been suggested** in existing issues
- **Explain the problem** you're trying to solve
- **Describe the solution** you'd like to see
- **Consider alternative solutions** you've thought about
- **Explain why this would be useful** to most Bubble users

Use the feature request template when creating an issue.

### Your First Contribution

Unsure where to begin? Look for issues labeled:

- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed
- `documentation` - Improvements or additions to documentation

### Development Workflow

1. **Create a branch** for your work
   ```bash
   git checkout -b feature/my-new-feature
   # or
   git checkout -b fix/bug-description
   ```

2. **Make your changes**
   - Write clear, concise code
   - Follow the coding standards (see below)
   - Add tests for new functionality
   - Update documentation as needed

3. **Test your changes**
   ```bash
   mix test
   mix format --check-formatted
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "Add feature: description of feature"
   ```

5. **Keep your branch updated**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

6. **Push to your fork**
   ```bash
   git push origin feature/my-new-feature
   ```

7. **Create a Pull Request** on GitHub

## Coding Standards

### Elixir Style Guide

We follow the [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide) with some project-specific conventions:

- **Format your code** using `mix format` before committing
- **Use descriptive variable and function names**
- **Write documentation** for public functions using `@doc` and `@moduledoc`
- **Keep functions small** and focused on a single task
- **Use pattern matching** effectively
- **Handle errors explicitly** - avoid generic try/catch blocks

### Code Organization

- **Contexts** - Business logic goes in context modules (`lib/bubble/`)
- **Controllers** - Keep controllers thin, delegate to contexts
- **LiveView** - UI logic in LiveView modules (`lib/bubble_web/live/`)
- **Components** - Reusable UI components in `lib/bubble_web/components/`
- **Tests** - Mirror the source file structure in `test/`

### Documentation

- **Module documentation** - Use `@moduledoc` for every module
- **Function documentation** - Use `@doc` for public functions
- **Examples** - Include examples in documentation when helpful
- **Type specs** - Add `@spec` for public functions

Example:
```elixir
@doc """
Fetches a news article by ID.

Returns `{:ok, article}` if found, `{:error, :not_found}` otherwise.

## Examples

    iex> get_article(123)
    {:ok, %Article{id: 123, title: "Example"}}

    iex> get_article(999)
    {:error, :not_found}
"""
@spec get_article(integer()) :: {:ok, Article.t()} | {:error, :not_found}
def get_article(id) do
  # Implementation
end
```

## Commit Guidelines

### Commit Message Format

We follow conventional commit format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style changes (formatting, no logic change)
- `refactor` - Code refactoring
- `test` - Adding or updating tests
- `chore` - Maintenance tasks

**Scope:** (optional) The area of code affected (e.g., `accounts`, `news`, `sources`)

**Examples:**
```
feat(news): add pagination to news feed

fix(sources): handle invalid RSS feed URLs gracefully

docs: update installation instructions in README

test(accounts): add tests for user registration
```

### Commit Best Practices

- **Keep commits atomic** - One logical change per commit
- **Write clear messages** - Explain what and why, not how
- **Reference issues** - Include issue numbers (e.g., "Fixes #123")

## Pull Request Process

### Before Submitting

- [ ] All tests pass (`mix test`)
- [ ] Code is formatted (`mix format`)
- [ ] Documentation is updated (if applicable)
- [ ] New tests added for new features
- [ ] Commit messages follow guidelines
- [ ] Branch is up to date with main

### PR Description

Your pull request should include:

- **Clear title** describing the change
- **Description** of what changed and why
- **Related issue** references (e.g., "Closes #123")
- **Screenshots** (for UI changes)
- **Testing notes** - How to test the changes

### Review Process

1. **Automated checks** must pass (tests, linting, formatting)
2. **At least one maintainer** will review your PR
3. **Address feedback** by pushing new commits
4. **Maintainer will merge** once approved

### After Your PR is Merged

- **Delete your branch** (GitHub will prompt you)
- **Pull the latest main** branch
- **Celebrate!** You've contributed to Bubble!

## Testing

### Running Tests

```bash
# Run all tests
mix test

# Run specific test file
mix test test/bubble/news_test.exs

# Run specific test
mix test test/bubble/news_test.exs:42

# Run with coverage
mix test --cover
```

### Writing Tests

- **Write tests for new features** - All new code should have tests
- **Test edge cases** - Consider boundary conditions and error cases
- **Use descriptive test names** - Clearly state what is being tested
- **Follow AAA pattern** - Arrange, Act, Assert

Example:
```elixir
test "creates article with valid attributes" do
  # Arrange
  user = insert(:user)
  attrs = %{title: "Test", url: "http://example.com"}

  # Act
  {:ok, article} = News.create_article(user, attrs)

  # Assert
  assert article.title == "Test"
  assert article.user_id == user.id
end
```

## Documentation

When adding features or changing behavior:

- Update the README if user-facing changes
- Add or update function documentation
- Update CHANGELOG.md
- Consider adding examples or guides

## Getting Help

If you need help with your contribution:

- **Ask questions** in issue comments
- **Reach out** to maintainers
- **Check documentation** for Phoenix and Elixir
- **Join the discussion** in open issues

## Recognition

Contributors will be recognized in:

- The project's README
- GitHub's contributors page
- Release notes (for significant contributions)

---

Thank you for contributing to Bubble! Every contribution, no matter how small, helps make this project better for everyone.
