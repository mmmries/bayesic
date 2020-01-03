defmodule Bayesic.Nif do
  use Rustler, otp_app: :bayesic, crate: "bayesic_nif"

  # When your NIF is loaded, it will override this function.
  #def add(_a, _b), do: :erlang.nif_error(:nif_not_loaded)

  def init, do: :erlang.nif_error(:nif_not_loaded )

  def train(_bayesic, _class, _tokens) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def classify(_baysic, _tokens) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def prune(_bayesic, _threshold) do
    :erlang.nif_error(:nif_not_loaded)
  end
end
