defmodule Bayesic do
  def init, do: Bayesic.Nif.init()

  def classify(bayesic, tokens) do
    Bayesic.Nif.classify(bayesic, tokens)
  end

  def finalize(bayesic, opts \\ []) do
    threshold_percent = Keyword.get(opts, :pruning_threshold, 0.5)
    Bayesic.Nif.prune(bayesic, threshold_percent)
    bayesic
  end

  def train(bayesic, tokens, classification) do
    Bayesic.Nif.train(bayesic, classification, tokens)
    bayesic
  end
end
