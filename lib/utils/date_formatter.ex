defmodule Utils.DateFormatter do
  @doc """
  Formats a DateTime to "Day Month Year - hour : minute" format
  Example: "23 October 2025 - 14:30"
  """
  def format_news_date(datetime) do
    case datetime do
      %DateTime{} = dt ->
        date = DateTime.to_date(dt)
        time = DateTime.to_time(dt)

        month_name = get_month_name(date.month)

        hour = time.hour |> Integer.to_string() |> String.pad_leading(2, "0")
        minute = time.minute |> Integer.to_string() |> String.pad_leading(2, "0")

        "#{date.day} #{month_name} #{date.year} - #{hour}:#{minute}"

      _ ->
        "Unknown date"
    end
  end

  defp get_month_name(month) do
    case month do
      1 -> "January"
      2 -> "February"
      3 -> "March"
      4 -> "April"
      5 -> "May"
      6 -> "June"
      7 -> "July"
      8 -> "August"
      9 -> "September"
      10 -> "October"
      11 -> "November"
      12 -> "December"
      _ -> "Unknown"
    end
  end
end
