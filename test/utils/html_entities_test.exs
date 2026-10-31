defmodule Utils.HtmlEntitiesTest do
  use ExUnit.Case, async: true

  alias Utils.HtmlEntities

  describe "decode/1" do
    test "decodes named entities" do
      assert "Hello & World" == HtmlEntities.decode("Hello &amp; World")
      assert "<div>" == HtmlEntities.decode("&lt;div&gt;")
      assert ~s("quoted") == HtmlEntities.decode("&quot;quoted&quot;")
      assert "It's great" == HtmlEntities.decode("It&apos;s great")
      assert "a b" == HtmlEntities.decode("a&nbsp;b")
    end

    test "decodes numeric entities" do
      assert "a b" == HtmlEntities.decode("a&#32;b")
      assert "It's great" == HtmlEntities.decode("It&#39;s great")
      assert "'quoted'" == HtmlEntities.decode("&#8216;quoted&#8217;")
      assert ~s("quoted") == HtmlEntities.decode("&#8220;quoted&#8221;")
    end

    test "decodes several entities in one string" do
      assert "Hello & goodbye <world>" ==
               HtmlEntities.decode("Hello &amp; goodbye &lt;world&gt;")
    end

    test "leaves text without entities untouched" do
      assert "plain text" == HtmlEntities.decode("plain text")
      assert "" == HtmlEntities.decode("")
    end
  end
end
