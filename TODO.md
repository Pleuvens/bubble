<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# I would prefer if you create a development plan as a todo list with unit task

**Development Plan for Elixir/Phoenix/LiveView Twitter Feed Aggregator**

***

### Project Setup

- [x] Initialize new Phoenix project with LiveView support.
- [x] Set up git (version control) and create initial repository.
- [x] Configure database using Ecto (Postgres recommended).

### User/Account Management

- [ ] Implement UI to add Twitter/X usernames ("accounts to follow") via LiveView form.
- [ ] Store handpicked account list in a database table (e.g., `followed_accounts`).
- [ ] Add UI for removing/unfollowing accounts.

### Twitter/X API Integration

- [ ] Add ExTwitter (or alternative) as a dependency in `mix.exs`.
- [ ] Obtain Twitter API credentials and securely store configuration.
- [ ] Implement code to fetch latest tweets for a given username.
- [ ] Handle authentication and error states (e.g., API rate limits).
- [ ] Save raw tweet data to a `tweets` table with appropriate fields.

### Fetching \& Scheduling

- [ ] Add Oban (or Quantum) for background job processing.
- [ ] Implement job to fetch new tweets for all followed accounts daily.
- [ ] Track last fetch per account to avoid duplicate tweets.

### Feed Display

- [ ] Design the main LiveView page to display tweets in a feed-style UI.
- [ ] Add support for sorting (newest first) and filtering by account.
- [ ] Show tweet details: author, content, timestamp, and any media links.

### Admin/UX Features

- [ ] Provide feedback on success/failure of adding or removing accounts.
- [ ] Show loading/error states for background fetching.
- [ ] Optionally: allow marking tweets as "read" or "favorite" for personal triage.

### Testing \& Quality

- [ ] Write tests for critical functions: account registration, tweet fetching and parsing, job scheduling.
- [ ] Add seed data for local testing.

### Deployment \& Maintenance

- [ ] Prepare deployment scripts/configs (Docker, fly.io, etc.).
- [ ] Document installation, config, Twitter API setup, and job scheduling.
- [ ] Create README and troubleshooting section.

***

Let me know if you’d like further breakdowns (e.g., database schema, specific module suggestions, etc.) or help with wiring up any section!
