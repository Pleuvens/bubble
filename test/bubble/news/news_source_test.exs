defmodule Bubble.News.NewsSourceTest do
  use Bubble.DataCase, async: true

  alias Bubble.News.NewsSource
  alias Bubble.News.UserNewsSource

  describe "NewsSource.changeset/2" do
    test "accepts a well formed url" do
      changeset = NewsSource.changeset(%NewsSource{}, valid_source_attrs())

      assert changeset.valid?
    end

    test "rejects a url with no host" do
      changeset =
        NewsSource.changeset(%NewsSource{}, %{valid_source_attrs() | url: "https:\\\\bsky.app"})

      refute changeset.valid?

      assert %{url: ["must start with http:// or https:// and include a domain"]} =
               errors_on(changeset)
    end
  end

  describe "UserNewsSource.changeset/2" do
    test "accepts a blank custom_url" do
      assert UserNewsSource.changeset(%UserNewsSource{}, valid_link_attrs()).valid?

      assert UserNewsSource.changeset(%UserNewsSource{}, %{valid_link_attrs() | custom_url: ""}).valid?
    end

    test "rejects a custom_url with no host" do
      changeset =
        UserNewsSource.changeset(%UserNewsSource{}, %{
          valid_link_attrs()
          | custom_url: "https:\\\\bsky.app"
        })

      refute changeset.valid?

      assert %{custom_url: ["must start with http:// or https:// and include a domain"]} =
               errors_on(changeset)
    end

    test "accepts a custom_name and custom_description" do
      changeset =
        UserNewsSource.changeset(%UserNewsSource{}, %{
          valid_link_attrs()
          | custom_name: "My Bluesky",
            custom_description: "Only the posts I care about"
        })

      assert changeset.valid?
      assert changeset.changes.custom_name == "My Bluesky"
      assert changeset.changes.custom_description == "Only the posts I care about"
    end

    test "rejects a custom_name longer than 255 characters" do
      changeset =
        UserNewsSource.changeset(%UserNewsSource{}, %{
          valid_link_attrs()
          | custom_name: String.duplicate("a", 256)
        })

      refute changeset.valid?
      assert %{custom_name: ["should be at most 255 character(s)"]} = errors_on(changeset)
    end
  end

  defp valid_source_attrs do
    %{name: "Bluesky", url: "https://bsky.app/rss", content_type: :article}
  end

  defp valid_link_attrs do
    %{
      user_id: Ecto.UUID.generate(),
      news_source_id: Ecto.UUID.generate(),
      custom_url: nil,
      custom_name: nil,
      custom_description: nil
    }
  end
end
