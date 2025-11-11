# Bubble

A personal RSS/news feed aggregator built with Elixir, Phoenix Framework, and LiveView. Bubble helps you consolidate and manage all your favorite RSS feeds in one clean, modern interface.

## Features

- **RSS/Atom Feed Aggregation** - Subscribe to multiple RSS and Atom feeds from various sources
- **Personal News Feed** - View all your subscribed content in a unified, chronological feed
- **User Authentication** - Secure user accounts with personalized feed management
- **Feed Management** - Easy-to-use interface for adding, removing, and organizing feed sources
- **Toggle Active/Inactive Sources** - Control which feeds are actively fetched
- **Automatic Feed Fetching** - Background jobs automatically fetch new content from your sources
- **Rich Metadata Extraction** - Automatically extracts metadata using OpenGraph, Twitter Cards, and HTML parsing
- **Real-time Updates** - Built with Phoenix LiveView for a responsive, real-time experience
- **Clean, Modern UI** - Simple and intuitive interface built with Tailwind CSS

## Tech Stack

- **Elixir 1.18** - Functional programming language for the backend
- **Phoenix 1.7** - Web framework
- **Phoenix LiveView** - Real-time, server-rendered UI
- **PostgreSQL** - Database
- **Oban** - Background job processing for feed fetching
- **Tailwind CSS** - Styling

## Prerequisites

Before you begin, ensure you have the following installed:

- **Elixir 1.18 or higher** - [Installation guide](https://elixir-lang.org/install.html)
- **Erlang/OTP 26 or higher** - Usually installed with Elixir
- **PostgreSQL** - [Installation guide](https://www.postgresql.org/download/)
- **Node.js 18+** - For asset compilation

## Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/Pleuvens/bubble.git
   cd bubble
   ```

2. **Install dependencies**

   ```bash
   mix setup
   ```

   This will:
   - Install Elixir dependencies
   - Create and migrate the database
   - Install Node.js dependencies for assets
   - Build assets

3. **Configure your environment**

   Copy the example environment file and configure it:

   ```bash
   cp .env.example .env
   ```

   Edit the `.env` file with your configuration (see Configuration section below).

4. **Start the server**

   ```bash
   mix phx.server
   ```

   Or start it inside IEx for interactive development:

   ```bash
   iex -S mix phx.server
   ```

5. **Visit the application**

   Open your browser and navigate to [`localhost:4000`](http://localhost:4000)

## Configuration

### Environment Variables

The following environment variables can be configured:

**Development:**

- `DATABASE_URL` - PostgreSQL connection string (optional, defaults to localhost)
- `PHX_HOST` - Hostname for the application (optional, defaults to localhost)
- `PORT` - Port to run the server on (optional, defaults to 4000)

**Production:**

- `DATABASE_URL` - PostgreSQL connection string (required)
- `SECRET_KEY_BASE` - Secret key for encryption (required, generate with `mix phx.gen.secret`)
- `PHX_HOST` - Your production domain (required)
- `PORT` - Port to run the server on (optional, defaults to 4000)

**Optional API Keys:**

- Any additional API keys for feed-specific features can be added as needed

### Database Configuration

For development, the default PostgreSQL credentials are:

- **Username:** `postgres`
- **Password:** `postgres`
- **Database:** `bubble_dev`

You can modify these in `config/dev.exs` if needed.

## Usage

### Creating an Account

1. Navigate to the application in your browser
2. Click "Register" to create a new account
3. Fill in your details and submit

### Adding Feed Sources

1. Log in to your account
2. Navigate to "Settings" or "Manage Sources"
3. Click "Add Source"
4. Enter the RSS/Atom feed URL
5. Optionally provide a name for the source
6. Click "Save"

### Managing Your Feeds

- **View Feed:** Your main feed shows all articles from active sources
- **Toggle Sources:** Enable/disable sources without deleting them
- **Remove Sources:** Delete sources you no longer want to follow
- **Refresh:** Background jobs automatically fetch new content, but you can manually trigger refreshes

## Development

### Project Structure

```
bubble/
├── lib/
│   ├── bubble/              # Core business logic
│   │   ├── accounts/        # User authentication and management
│   │   ├── news/            # News feed and article management
│   │   └── sources/         # RSS source management
│   ├── bubble_web/          # Web interface
│   │   ├── components/      # LiveView components
│   │   ├── controllers/     # HTTP controllers
│   │   └── live/            # LiveView pages
│   └── bubble.ex
├── test/                    # Test files
├── priv/
│   └── repo/
│       └── migrations/      # Database migrations
├── config/                  # Configuration files
└── assets/                  # Frontend assets (CSS, JS)
```

### Running Tests

Run the full test suite:

```bash
mix test
```

Run tests with coverage:

```bash
mix test --cover
```

Run a specific test file:

```bash
mix test test/bubble/news_test.exs
```

### Code Quality

Format code:

```bash
mix format
```

### Background Jobs

Bubble uses Oban for background job processing. The main scheduled jobs include:

- **Daily Feed Fetching** - Automatically fetches new content from all active sources

You can view the Oban dashboard at `/dev/dashboard` in development mode.

### Database Operations

Create the database:

```bash
mix ecto.create
```

Run migrations:

```bash
mix ecto.migrate
```

Reset the database:

```bash
mix ecto.reset
```

Generate a new migration:

```bash
mix ecto.gen.migration migration_name
```

## Deployment

### Production Setup

1. **Set environment variables** - Ensure all required production environment variables are set

2. **Generate a secret key base**

   ```bash
   mix phx.gen.secret
   ```

3. **Compile assets**

   ```bash
   mix assets.deploy
   ```

4. **Run migrations**

   ```bash
   mix ecto.migrate
   ```

5. **Start the application**

   ```bash
   mix phx.server
   ```

For more detailed deployment instructions, refer to the [Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to get started.

## Security

If you discover a security vulnerability, please refer to our [SECURITY.md](SECURITY.md) file for instructions on how to report it responsibly.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [Phoenix Framework](https://www.phoenixframework.org/)
- RSS parsing powered by [SweetXml](https://github.com/kbrw/sweet_xml)
- Background jobs managed by [Oban](https://github.com/sorentwo/oban)
- UI components from [Lucide Icons](https://lucide.dev/)

## Project Status

Bubble is currently in early development (v0.1.0). Features and APIs may change as the project evolves.

## Support

For questions, issues, or feature requests, please [open an issue](https://github.com/yourusername/bubble/issues) on GitHub.

---

Made with ❤️ by the Bubble community
