defmodule Bayesic.Trainer do
  defstruct [:classifications, :classifications_by_token]

  @doc """
  Sets up a new a trainer so you can load in your matching data
  """
  def new do
    %__MODULE__{classifications: MapSet.new(), classifications_by_token: %{}}
  end
end

defimpl Inspect, for: Bayesic.Trainer do
  import Inspect.Algebra

  def inspect(_bayesic, _opts) do
    concat(["#Bayesic.Trainer<>"])
  end
end
