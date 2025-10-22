defmodule Utils.DateFormatterTest do
  use ExUnit.Case, async: true

  alias Utils.DateFormatter

  describe "format_news_date/1" do
    test "formats a valid DateTime correctly" do
      datetime = ~U[2025-10-23 14:30:45Z]

      result = DateFormatter.format_news_date(datetime)

      assert result == "23 October 2025 - 14:30"
    end

    test "formats single digit day correctly" do
      datetime = ~U[2025-01-05 09:15:30Z]

      result = DateFormatter.format_news_date(datetime)

      assert result == "5 January 2025 - 09:15"
    end

    test "formats single digit hour and minute correctly" do
      datetime = ~U[2025-03-15 03:07:22Z]

      result = DateFormatter.format_news_date(datetime)

      assert result == "15 March 2025 - 03:07"
    end

    test "formats all months correctly" do
      months_expected = [
        {1, "January"},
        {2, "February"},
        {3, "March"},
        {4, "April"},
        {5, "May"},
        {6, "June"},
        {7, "July"},
        {8, "August"},
        {9, "September"},
        {10, "October"},
        {11, "November"},
        {12, "December"}
      ]

      for {month, expected_name} <- months_expected do
        datetime = DateTime.new!(Date.new!(2025, month, 15), Time.new!(12, 0, 0), "Etc/UTC")
        result = DateFormatter.format_news_date(datetime)
        assert result == "15 #{expected_name} 2025 - 12:00"
      end
    end

    test "handles edge case times correctly" do
      # Midnight
      datetime = ~U[2025-12-31 00:00:00Z]
      result = DateFormatter.format_news_date(datetime)
      assert result == "31 December 2025 - 00:00"

      # Almost midnight
      datetime = ~U[2025-12-31 23:59:59Z]
      result = DateFormatter.format_news_date(datetime)
      assert result == "31 December 2025 - 23:59"
    end

    test "handles leap year correctly" do
      datetime = ~U[2024-02-29 12:00:00Z]

      result = DateFormatter.format_news_date(datetime)

      assert result == "29 February 2024 - 12:00"
    end

    test "handles different years correctly" do
      # Past year
      datetime = ~U[2020-06-15 10:30:00Z]
      result = DateFormatter.format_news_date(datetime)
      assert result == "15 June 2020 - 10:30"

      # Future year
      datetime = ~U[2030-06-15 10:30:00Z]
      result = DateFormatter.format_news_date(datetime)
      assert result == "15 June 2030 - 10:30"
    end

    test "returns 'Unknown date' for nil input" do
      result = DateFormatter.format_news_date(nil)

      assert result == "Unknown date"
    end

    test "returns 'Unknown date' for invalid input types" do
      invalid_inputs = [
        "2025-10-23",
        %{year: 2025, month: 10, day: 23},
        123_456_789,
        :invalid_atom
      ]

      for invalid_input <- invalid_inputs do
        result = DateFormatter.format_news_date(invalid_input)
        assert result == "Unknown date"
      end
    end

    test "handles DateTime with microseconds correctly" do
      datetime = ~U[2025-07-04 16:45:30.123456Z]

      result = DateFormatter.format_news_date(datetime)

      assert result == "4 July 2025 - 16:45"
    end

    test "handles UTC datetime correctly" do
      # Test with UTC datetime (which is what we'll typically get from the database)
      datetime = ~U[2025-05-20 08:15:00Z]

      result = DateFormatter.format_news_date(datetime)

      assert result == "20 May 2025 - 08:15"
      # Verify it maintains the expected format structure
      assert String.match?(result, ~r/\d{1,2} \w+ \d{4} - \d{2}:\d{2}/)
    end
  end

  describe "integration with real use cases" do
    test "formats dates similar to RSS feed timestamps" do
      # Common RSS/news feed timestamp format when converted to DateTime
      datetime = ~U[2025-10-23 08:00:00Z]

      result = DateFormatter.format_news_date(datetime)

      assert result == "23 October 2025 - 08:00"
      # Verify it contains all expected components
      assert String.contains?(result, "23")
      assert String.contains?(result, "October")
      assert String.contains?(result, "2025")
      assert String.contains?(result, "08:00")
      assert String.contains?(result, " - ")
    end

    test "output format matches expected template usage" do
      datetime = ~U[2025-12-25 18:30:00Z]

      result = DateFormatter.format_news_date(datetime)

      # Should be suitable for display in HTML templates
      assert result == "25 December 2025 - 18:30"
      # No special characters that would need HTML escaping
      refute String.contains?(result, "&")
      refute String.contains?(result, "<")
      refute String.contains?(result, ">")
    end
  end
end
