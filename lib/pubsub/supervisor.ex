defmodule ChipRato.PubSub.Supervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    [
      # add your data publishers here
    ]
    |> Supervisor.init(strategy: :one_for_one)
  end
end
