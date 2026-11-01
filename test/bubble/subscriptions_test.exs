defmodule Bubble.SubscriptionsTest do
  use Bubble.DataCase
  use Oban.Testing, repo: Bubble.Repo

  import Bubble.AccountsFixtures
  import Bubble.NewsFixtures

  alias Bubble.News.FetchSingleSourceJob
  alias Bubble.Subscriptions

  describe "subscribe_user_and_fetch/2" do
    test "enqueues a fetch when the source has gone stale" do
      user = user_fixture()
      source = news_source_fixture()

      assert {:ok, _} = Subscriptions.subscribe_user_and_fetch(user.id, source.id)

      assert_enqueued worker: FetchSingleSourceJob, args: %{news_source_id: source.id}
    end

    test "does not enqueue a fetch when the source was fetched recently" do
      user = user_fixture()
      source = news_source_fixture(%{last_fetched_at: DateTime.utc_now()})

      assert {:ok, _} = Subscriptions.subscribe_user_and_fetch(user.id, source.id)

      refute_enqueued worker: FetchSingleSourceJob
    end
  end
end
