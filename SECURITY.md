# Security Policy

## Supported Versions

The following versions of Bubble are currently being supported with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

As the project is in early development (v0.1.0), we recommend always using the latest version from the main branch.

## Reporting a Vulnerability

We take the security of Bubble seriously. If you believe you have found a security vulnerability, please report it to us responsibly.

### How to Report

**Please do NOT report security vulnerabilities through public GitHub issues.**

Instead, please report security vulnerabilities by emailing:

**[pleuvens.fervil@gmail.com]**

Include the following information in your report:

- **Type of vulnerability** (e.g., XSS, SQL injection, authentication bypass)
- **Full paths of source file(s)** related to the manifestation of the vulnerability
- **Location of the affected source code** (tag/branch/commit or direct URL)
- **Step-by-step instructions** to reproduce the issue
- **Proof-of-concept or exploit code** (if possible)
- **Impact of the issue**, including how an attacker might exploit it

### What to Expect

When you report a vulnerability, you can expect:

1. **Acknowledgment** - We will acknowledge receipt of your vulnerability report within 48 hours
2. **Assessment** - We will investigate and assess the severity of the issue
3. **Updates** - We will provide regular updates on our progress (at least every 7 days)
4. **Resolution** - We will work to fix the vulnerability and release a patch
5. **Disclosure** - We will coordinate with you on public disclosure timing

### Response Timeline

- **Initial Response:** Within 48 hours
- **Status Update:** Within 7 days
- **Fix Timeline:** Varies by severity
  - Critical: Within 7 days
  - High: Within 14 days
  - Medium: Within 30 days
  - Low: Next scheduled release

### Disclosure Policy

- We follow a **responsible disclosure** policy
- We request that you give us a reasonable amount of time to fix the vulnerability before public disclosure
- We will credit you for your discovery (unless you prefer to remain anonymous)
- Once the vulnerability is fixed, we will:
  - Release a security update
  - Publish a security advisory
  - Credit the reporter (if desired)

## Security Best Practices for Users

If you're deploying Bubble, please follow these security best practices:

### 1. Environment Variables

- **Never commit** `.env` files or configuration files with secrets to version control
- Use strong, randomly generated values for `SECRET_KEY_BASE`
- Generate secrets using: `mix phx.gen.secret`

### 2. Database Security

- Use strong, unique passwords for database credentials
- Restrict database access to only necessary hosts
- Enable SSL/TLS for database connections in production
- Regularly backup your database

### 3. HTTPS/SSL

- **Always use HTTPS** in production
- Enable `force_ssl` in your production configuration
- Use valid SSL/TLS certificates (e.g., from Let's Encrypt)

### 4. Dependencies

- Regularly update dependencies to get security patches
- Run `mix deps.audit` to check for known vulnerabilities
- Subscribe to security advisories for Elixir, Phoenix, and other dependencies

### 5. Authentication

- Use strong password requirements
- Consider implementing rate limiting for login attempts
- Enable two-factor authentication if handling sensitive data

### 6. Input Validation

- The application sanitizes HTML input, but always validate user input
- Be cautious when adding new RSS sources from untrusted origins
- Review feed content for malicious scripts or content

### 7. Server Security

- Keep your operating system and Erlang/Elixir runtime updated
- Use firewalls to restrict access to necessary ports only
- Implement proper logging and monitoring
- Use a reverse proxy (nginx, Apache) in production

### 8. Rate Limiting

- Implement rate limiting for API endpoints
- Protect against abuse and denial-of-service attacks

## Known Security Considerations

### RSS Feed Content

- Bubble fetches and displays content from external RSS feeds
- Feed content is sanitized using `html_sanitize_ex`
- However, users should be cautious about subscribing to untrusted sources
- Malicious feeds could potentially serve harmful content

### Background Jobs

- Oban is used for background job processing
- Jobs fetch external content which could timeout or cause issues
- Rate limiting is recommended for feed fetching

## Security Updates

Security updates will be released as soon as possible after a vulnerability is confirmed and fixed. Updates will be announced via:

- GitHub Security Advisories
- Release notes in CHANGELOG.md
- GitHub Releases

## Questions?

If you have questions about this security policy or general security concerns (not vulnerability reports), please open a GitHub issue labeled with "security question".

---

Thank you for helping keep Bubble and its users safe!
