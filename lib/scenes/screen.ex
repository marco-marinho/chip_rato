defmodule ChipRato.Scene.Screen do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  alias Scenic.Primitives
  # import Scenic.Components

  @note """
    This is a very simple starter application.

    If you want a more full-on example, please start from:

    mix scenic.new.example
  """

  @text_size 24
  @chip8_width 64
  @chip8_height 32
  # Must match the scale in config.exs
  @pixel_scale 30
  @off_color :black
  # Or :write
  @on_color :lime

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(scene, _param, _opts) do
    initial_pixels =
      for x <- 0..(@chip8_width - 1), y <- 0..(@chip8_height - 1), into: %{} do
        # Start with all pixels off
        {{x, y}, false}
      end

    graph = build_graph(initial_pixels)

    scene = push_graph(scene, graph)

    {:ok, scene}
  end

  def handle_input(event, _context, scene) do
    Logger.info("Received event: #{inspect(event)}")
    {:noreply, scene}
  end

  defp build_graph(pixels) do
    pixel_size = {@pixel_scale, @pixel_scale}
    # Iterate through the CHIP-8 grid and draw rectangles for "on" pixels
    graph = Enum.reduce(pixels, Graph.build(), fn {{cx, cy}, state}, current_graph ->
      # Pixels is on
      if state do
        screen_x = cx * @pixel_scale
        screen_y = cy * @pixel_scale
        current_graph
        |> Primitives.rect(
          pixel_size,
          translate: {screen_x, screen_y},
          fill: @on_color
        )
      else
        # Pixel is off, just return the graph accumulator unchanged
        current_graph
      end
    end)
    # Return the completed graph
    graph
  end
end
