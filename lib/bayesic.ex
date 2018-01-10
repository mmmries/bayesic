defmodule Bayesic do
  defstruct [:port]

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
      iex> Bayesic.classify(matcher, ["once","upon"])
      %{"story" => 1.0}
      iex> Bayesic.classify(matcher, ["tonight"])
      %{"news" => 1.0}
  """
  def classify(%Bayesic{port: port}, tokens) do
    send_command_and_await_response(port, {:classify, tokens})
  end

  @doc """
  Sets up a new Bayesic matcher

  ## Examples

      iex> Bayesic.new()
      #Bayesic<>

  """
  def new do
    port = Port.open({:spawn, "priv/bayesic_port"}, [:binary, {:packet, 4}])
    %__MODULE__{port: port}
  end

  @doc """
  Train the matcher on a known set of tokens and what classification they are a part of

  ## Examples

      iex> Bayesic.train(Bayesic.new(), ["once","upon","a","time"], "story")
      #Bayesic<>

  """
  def train(%Bayesic{port: port}=matcher, tokens, classification) do
    :ok = send_command_and_await_response(port, {:train, tokens, classification})
    matcher
  end

  defp send_command_and_await_response(port, command) do
    true = Port.command(port, :erlang.term_to_binary(command))
    receive do
      {^port, {:data, binary}} ->
        :erlang.binary_to_term(binary)
      after 5_000 ->
        {:error, "timed out waiting for port response"}
    end
  end
end

defimpl Inspect, for: Bayesic do
  import Inspect.Algebra

  def inspect(_bayesic, _opts) do
    concat(["#Bayesic<>"])
  end
end
