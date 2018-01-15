defmodule Bayesic do
  @moduledoc """
  A data matcher that uses Bayes' Theorem to calculate the probability of a given match.
  This is similar to [Naive Bayes](https://en.wikipedia.org/wiki/Naive_Bayes_classifier),
  but it is optimized for cases where you have many possible classifications, with a
  relatively small amount of data per class.

  ## Matching Words

      iex> matcher = Bayesic.Trainer.new()
      ...>           |> Bayesic.train(["once","upon","a","time"], "story")
      ...>           |> Bayesic.train(["tonight","on","the","news"], "news")
      ...>           |> Bayesic.finalize()
      iex> Bayesic.classify(matcher, ["once","upon"])
      %{"story" => 1.0}
      iex> Bayesic.classify(matcher, ["tonight"])
      %{"news" => 1.0}

  ## Matching Trigrams

      iex> tri = fn(str) -> str |> String.codepoints |> Enum.chunk_every(3, 1, :discard) |> Enum.map(&(Enum.join(&1,""))) end
      iex> tri.("teeth")
      ["tee","eet","eth"]
      iex> matcher = Bayesic.Trainer.new()
      ...>           |> Bayesic.train(tri.("triassic"), "old")
      ...>           |> Bayesic.train(tri.("jurassic"), "old")
      ...>           |> Bayesic.train(tri.("modern"), "new")
      ...>           |> Bayesic.train(tri.("hipster"), "new")
      ...>           |> Bayesic.finalize()
      iex> Bayesic.classify(matcher, tri.("moder"))
      %{"new" => 1.0}
      iex> Bayesic.classify(matcher, tri.("jrassic"))
      %{"old" => 1.0}
  """

  @doc """
  Take a list of tokens and provide a map of which classifications it might match along with a propbability of each classification.

  ## Examples

      iex> matcher = Bayesic.Trainer.new()
      ...>           |> Bayesic.train(["once","upon","a","time"], "story")
      ...>           |> Bayesic.train(["tonight","on","the","news"], "news")
      ...>           |> Bayesic.finalize()
      iex> Bayesic.classify(matcher, ["once","upon"])
      %{"story" => 1.0}
      iex> Bayesic.classify(matcher, ["tonight"])
      %{"news" => 1.0}
  """
  @spec classify(%Bayesic.Matcher{}, [String.t]) :: %{String.t => float()}
  def classify(%Bayesic.Matcher{}=matcher, tokens) do
    tokens = Enum.filter(tokens, fn(token) -> Map.has_key?(matcher.by_token, token) end)
    Enum.reduce(tokens, %{}, fn(token, probabilities) ->
      Enum.reduce(matcher.by_token[token][:classifications], probabilities, fn(classification, probabilities) ->
        p_klass = probabilities[classification] || matcher.prior
        p_not_klass = 1.0 - p_klass
        p_token_given_klass = 1.0
        p_token_given_not_klass = (matcher.by_token[token][:count] - 1.0) / matcher.class_count
        Map.put(probabilities, classification, (p_token_given_klass * p_klass) / ((p_token_given_klass * p_klass) + (p_token_given_not_klass * p_not_klass)))
      end)
    end)
  end

  @doc """
  Compile the trained data into a Matcher for classification.

  After you have loaded up your trainer with example data, this function will run
  some calculations and turn it into a `%Bayesic.Matcher{}`.
  We also do some data pruning at this stage to remove tokens that appear frequently.
  You can customize how much pruning you want to do by passing in the :pruning_threshold option.
  Tokens that appear in more than the :pruning_percentage of classifications will be removed.
  This can speed things up quite a bit and it usually doesn't hur your accuracy we are already
  weighting the tokens by how uniqe they are (see [Bayes Theorem](https://en.wikipedia.org/wiki/Bayes%27_theorem#Statement_of_theorem)).

      iex> Bayesic.Trainer.new()
      ...> |> Bayesic.train([1, 2, 3], "small numbers")
      ...> |> Bayesic.finalize(pruning_threshold: 0.1)
      #Bayesic.Matcher<>
  """
  @spec finalize(%Bayesic.Trainer{}, keyword()) :: %Bayesic.Matcher{}
  def finalize(%Bayesic.Trainer{}=trainer, opts \\ []) do
    threshold_percent = Keyword.get(opts, :pruning_threshold, 0.5)
    class_count = Enum.count(trainer.classifications)
    pruning_threshold = round(threshold_percent * class_count)
    by_token = Enum.reduce(trainer.classifications_by_token, %{}, fn({token, classifications}, map) ->
      count = Enum.count(classifications)
      if count > pruning_threshold do
        map
      else
        Map.put(map, token, %{classifications: classifications, count: count})
      end
    end)
    %Bayesic.Matcher{class_count: class_count, by_token: by_token, prior: 1.0 / class_count}
  end

  @doc """
  Feed some example data to your trainer.

  The classification can be an arbitrary term. You can put maps, strings, ecto structs etc.
  The tokens should be a list of items you saw in the original data.
  For example if you are trying to match user input to a list of movie titles you might
  break up the movie titles into words (`"Jurassic Park" => ["jurassic", "park"]`).
  Later when the user is typing in a name you can take the string the user has typed and break
  it into the tokens the same way to check for a high confidence match.

  ## Examples

      iex> Bayesic.Trainer.new() |> Bayesic.train(["once","upon","a","time"], "story")
      #Bayesic.Trainer<>

  """
  @spec train(%Bayesic.Trainer{}, [String.t], term()) :: %Bayesic.Trainer{}
  def train(%Bayesic.Trainer{}=trainer, tokens, classification) do
    classifications = MapSet.put(trainer.classifications, classification)
    classifications_by_token = Enum.reduce(tokens, trainer.classifications_by_token, fn(token, classifications_by_token) ->
      set = Map.get_lazy(classifications_by_token, token, fn() -> MapSet.new() end)
      set = MapSet.put(set, classification)
      Map.put(classifications_by_token, token, set)
    end)
    %{trainer | classifications: classifications, classifications_by_token: classifications_by_token}
  end
end
