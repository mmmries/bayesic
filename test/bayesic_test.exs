defmodule BayesicTest do
  use ExUnit.Case
  doctest Bayesic

  setup do
    matcher = Bayesic.Trainer.new()
              |> Bayesic.train(["once","upon","a","time"], "story")
              |> Bayesic.train(["tonight","on","the","news"], "news")
              |> Bayesic.train(["it","was","the","best","of","times"], "novel")
              |> Bayesic.finalize
    {:ok, %{matcher: matcher}}
  end

  test "can classify matching tokens", %{matcher: matcher} do
    classification = Bayesic.classify(matcher, ["once","upon","a","time"])
    assert Map.has_key?(classification, "story")
    assert classification["story"] >= 0.9
  end

  test "can classify not exact matches", %{matcher: matcher} do
    classification = Bayesic.classify(matcher, ["the","time"])
    assert Map.has_key?(classification, "story")
    assert classification["story"] >= 0.9
  end

  test "returns no potential matches for nonsense", %{matcher: matcher} do
    classification = Bayesic.classify(matcher, ["furby"])
    assert classification == %{}
  end
end
