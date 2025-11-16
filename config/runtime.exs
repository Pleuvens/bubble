import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/bubble start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :bubble, BubbleWeb.Endpoint, server: true
end

config :bubble, Bubble.Repo,
  migration_timestamps: [
    type: :utc_datetime_usec,
    inserted_at: :inserted_at,
    updated_at: :updated_at,
    default: Ecto.Migration.fragment("NOW()")
  ],
  migration_primary_key: [
    type: :binary_id,
    name: :id,
    default: Ecto.Migration.fragment("gen_random_uuid()")
  ]

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :bubble, Bubble.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host =
    System.get_env("PHX_HOST") ||
      raise """
      environment variable PHX_HOST is missing.
      This is required in production for generating URLs in emails and other contexts.
      Example: PHX_HOST=yourdomain.com
      """

  port = String.to_integer(System.get_env("PORT") || "4000")

  config :bubble, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  # Configure WebSocket origin checking for self-hosted deployments
  # Set CHECK_ORIGIN to false to allow all origins (less secure, but flexible for self-hosting)
  # Or set it to a comma-separated list of allowed origins like:
  # CHECK_ORIGIN=https://yourdomain.com,https://www.yourdomain.com
  check_origin =
    case System.get_env("CHECK_ORIGIN") do
      "false" -> false
      nil -> ["//#{host}"]
      origins -> String.split(origins, ",")
    end

  config :bubble, BubbleWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    check_origin: check_origin,
    secret_key_base: secret_key_base

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :bubble, BubbleWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :bubble, BubbleWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.

  # ## Configuring the mailer
  #
  # Swoosh adapter can be configured via environment variables to support different email providers.
  # Set SWOOSH_ADAPTER to choose your email provider:
  #
  # - "postal" (default): Uses Postal mail server
  #   Required env vars: POSTAL_API_KEY, POSTAL_DOMAIN
  #
  # - "smtp": Uses any SMTP server
  #   Required env vars: SMTP_RELAY, SMTP_USERNAME, SMTP_PASSWORD, SMTP_PORT (optional, defaults to 587)
  #   Optional: SMTP_TLS (true/false, defaults to true), SMTP_AUTH (always/never/if_available, defaults to always)
  #
  # - "sendgrid": Uses SendGrid
  #   Required env vars: SENDGRID_API_KEY
  #
  # - "mailgun": Uses Mailgun
  #   Required env vars: MAILGUN_API_KEY, MAILGUN_DOMAIN
  #
  # - "ses": Uses Amazon SES
  #   Required env vars: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION
  #
  # Example for Postal (default):
  #   SWOOSH_ADAPTER=postal
  #   POSTAL_API_KEY=your_api_key
  #   POSTAL_DOMAIN=your_domain
  #
  # Example for SMTP:
  #   SWOOSH_ADAPTER=smtp
  #   SMTP_RELAY=smtp.example.com
  #   SMTP_USERNAME=user@example.com
  #   SMTP_PASSWORD=your_password
  #   SMTP_PORT=587

  adapter_config =
    case System.get_env("SWOOSH_ADAPTER", "postal") do
      "postal" ->
        [
          adapter: Swoosh.Adapters.Postal,
          api_key: System.get_env("POSTAL_API_KEY") || raise("POSTAL_API_KEY not set"),
          base_url: System.get_env("POSTAL_DOMAIN") || raise("POSTAL_DOMAIN not set")
        ]

      "smtp" ->
        smtp_tls =
          case System.get_env("SMTP_TLS") do
            "false" -> :never
            "if_available" -> :if_available
            _ -> :always
          end

        smtp_auth =
          case System.get_env("SMTP_AUTH") do
            "never" -> :never
            "if_available" -> :if_available
            _ -> :always
          end

        [
          adapter: Swoosh.Adapters.SMTP,
          relay: System.get_env("SMTP_RELAY") || raise("SMTP_RELAY not set"),
          username: System.get_env("SMTP_USERNAME") || raise("SMTP_USERNAME not set"),
          password: System.get_env("SMTP_PASSWORD") || raise("SMTP_PASSWORD not set"),
          port: String.to_integer(System.get_env("SMTP_PORT") || "587"),
          tls: smtp_tls,
          auth: smtp_auth
        ]

      "sendgrid" ->
        [
          adapter: Swoosh.Adapters.Sendgrid,
          api_key: System.get_env("SENDGRID_API_KEY") || raise("SENDGRID_API_KEY not set")
        ]

      "mailgun" ->
        [
          adapter: Swoosh.Adapters.Mailgun,
          api_key: System.get_env("MAILGUN_API_KEY") || raise("MAILGUN_API_KEY not set"),
          domain: System.get_env("MAILGUN_DOMAIN") || raise("MAILGUN_DOMAIN not set")
        ]

      "ses" ->
        [
          adapter: Swoosh.Adapters.AmazonSES,
          access_key: System.get_env("AWS_ACCESS_KEY_ID") || raise("AWS_ACCESS_KEY_ID not set"),
          secret:
            System.get_env("AWS_SECRET_ACCESS_KEY") || raise("AWS_SECRET_ACCESS_KEY not set"),
          region: System.get_env("AWS_REGION") || raise("AWS_REGION not set")
        ]

      adapter ->
        raise "Unknown SWOOSH_ADAPTER: #{adapter}. Valid options are: postal, smtp, sendgrid, mailgun, ses"
    end

  config :bubble, Bubble.Mailer, adapter_config
end

# Configure the sender email address for transactional emails
# This applies to all environments (dev, test, prod)
# In production, set MAIL_FROM_EMAIL to use your actual domain (e.g., contact@yourdomain.com)
# to avoid emails being sent from the default example.com address
config :bubble, :mailer,
  from_email: System.get_env("MAIL_FROM_EMAIL", "contact@example.com"),
  from_name: System.get_env("MAIL_FROM_NAME", "Bubble")
