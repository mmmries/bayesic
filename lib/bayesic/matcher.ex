defmodule Bayesic.Matcher do
  defstruct [:prior, :class_count, :by_token, :by_class]
end

defimpl Inspect, for: Bayesic.Matcher do
  import Inspect.Algebra

  def inspect(_bayesic, _opts) do
    concat(["#Bayesic.Matcher<>"])
  end
end
