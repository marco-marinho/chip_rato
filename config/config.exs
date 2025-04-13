import Config

# CHIP-8 dimensions
chip8_width = 64
chip8_height = 32
# How much to scale each CHIP-8 pixel
pixel_scale = 30

# Calculated window size
window_width = chip8_width * pixel_scale
window_height = chip8_height * pixel_scale

config :scenic, :assets, module: ChipRato.Assets

config :chip_rato, :viewport,
  name: :main_viewport,
  size: {window_width, window_height},
  default_scene: ChipRato.Scene.Screen,
  drivers: [
    [
      module: Scenic.Driver.Local,
      name: :local,
      window: [resizeable: false, title: "ratin"],
      on_close: :stop_system
    ]
  ]
