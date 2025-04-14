defmodule ChipRato.Application do
  use Application

  def start(_type, _args) do
    children = [
      # Add the GenServer here to be part of the supervision tree
      {ChipRato, nil},  # Start the ChipRato GenServer
      # You can add other workers/supervisors here
    ]

    # Supervisor specification
    opts = [strategy: :one_for_one, name: ChipRato.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
