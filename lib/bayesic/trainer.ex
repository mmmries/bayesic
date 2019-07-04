defmodule Bayesic.Trainer do
  defstruct [:table]

  @doc """
  Sets up a new a trainer so you can load in your matching data
  """
  @spec new() :: %Bayesic.Trainer{}
  def new do
    %__MODULE__{table: :ets.new(:bayesic_trainer, [:ordered_set])}
  end
end

defimpl Inspect, for: Bayesic.Trainer do
  import Inspect.Algebra

  def inspect(_bayesic, _opts) do
    concat(["#Bayesic.Trainer<>"])
  end
end
