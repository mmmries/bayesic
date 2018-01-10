defmodule Bayesic do
  defstruct [:classifications, :classifications_by_token, :tokens_by_classification, :stats]

  @moduledoc """
  A string matcher that uses Bayes' Theorem to calculate the probability of a given match.
  To use this you will need to break your strings into a list of tokens.
  Common approaches include breaking the string on word boundaries, breaking the string into trigrams etc.
  """

  @doc """
  Take a list of tokens and provide a map of which classifications it might match along with a propbability of each classification..

  ## Examples

      iex> matcher = Bayesic.new()
      iex> matcher = Bayesic.train(matcher, ["once","upon","a","time"], "story")
      iex> matcher = Bayesic.train(matcher, ["tonight","on","the","news"], "news")
      iex> matcher = Bayesic.finalize(matcher)
      iex> Bayesic.classify(matcher, ["once","upon"])
      %{"story" => 1.0}
      iex> Bayesic.classify(matcher, ["tonight"])
      %{"news" => 1.0}
  """
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

  def finalize(%Bayesic{}=bayesic) do
    class_count = Enum.count(bayesic.classifications)
    by_token = Enum.reduce(bayesic.classifications_by_token, %{}, fn({token, classifications}, map) ->
      Map.put(map, token, %{classifications: classifications, count: Enum.count(classifications)})
    end)
    #by_class = Enum.reduce(bayesic.tokens_by_classification, %{}, fn({class, tokens}, map) ->
    #  Map.put(map, class, %{tokens: tokens, count: count})
    #end)
    #%Bayesic.Matcher{class_count: class_count, by_token: by_token, by_class: by_class, prior: 1.0 / class_count}
    %Bayesic.Matcher{class_count: class_count, by_token: by_token, prior: 1.0 / class_count}
  end

  @doc """
  Sets up a new Bayesic matcher

  ## Examples

      iex> Bayesic.new()
      #Bayesic<>

  """
  def new do
    %__MODULE__{classifications: MapSet.new(), classifications_by_token: %{}, tokens_by_classification: %{}}
  end

  @doc """
  Train the matcher on a known set of tokens and what classification they are a part of

  ## Examples

      iex> Bayesic.train(Bayesic.new(), ["once","upon","a","time"], "story")
      #Bayesic<>

  """
  def train(%Bayesic{}=matcher, tokens, classification) do
    classifications = MapSet.put(matcher.classifications, classification)
    #tokens_for_classification = Map.get_lazy(matcher.tokens_by_classification, classification, fn() -> MapSet.new() end)
    #tokens_for_classification = Enum.reduce(tokens, tokens_for_classification, fn(token, tokens_for_classification) ->
    #  MapSet.put(tokens_for_classification, token)
    #end)
    #tokens_by_classification = Map.put(matcher.tokens_by_classification, classification, tokens_for_classification)
    classifications_by_token = Enum.reduce(tokens, matcher.classifications_by_token, fn(token, classifications_by_token) ->
      set = Map.get_lazy(classifications_by_token, token, fn() -> MapSet.new() end)
      set = MapSet.put(set, classification)
      Map.put(classifications_by_token, token, set)
    end)
    #%{matcher | classifications: classifications, tokens_by_classification: tokens_by_classification, classifications_by_token: classifications_by_token}
    %{matcher | classifications: classifications, classifications_by_token: classifications_by_token}
  end
end

defimpl Inspect, for: Bayesic do
  import Inspect.Algebra

  def inspect(_bayesic, _opts) do
    concat(["#Bayesic<>"])
  end
end
