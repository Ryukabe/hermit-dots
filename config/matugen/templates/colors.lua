local M = {}

M.bg0    = "rgb({{colors.surface.default.hex_stripped}})"
M.bg1    = "rgb({{colors.surface_variant.default.hex_stripped}})"
M.bg2    = "rgb({{colors.secondary_container.default.hex_stripped}})"
M.bg3    = "rgb({{colors.surface_container.default.hex_stripped}})"
M.bg4    = "rgb({{colors.surface_container_high.default.hex_stripped}})"

M.fg     = "rgb({{colors.on_surface.default.hex_stripped}})"
M.accent = "rgb({{colors.primary.default.hex_stripped}})"

M.red    = "rgb({{colors.error.default.hex_stripped}})"
M.orange = "rgb({{colors.tertiary.default.hex_stripped}})"
M.yellow = "rgb({{colors.tertiary.default.hex_stripped}})"
M.green  = "rgb({{colors.secondary.default.hex_stripped}})"
M.aqua   = "rgb({{colors.tertiary_container.default.hex_stripped}})"
M.blue   = "rgb({{colors.primary.default.hex_stripped}})"
M.purple = "rgb({{colors.primary_container.default.hex_stripped}})"

M.grey0  = "rgb({{colors.outline_variant.default.hex_stripped}})"
M.grey1  = "rgb({{colors.outline.default.hex_stripped}})"
M.grey2  = "rgb({{colors.on_surface_variant.default.hex_stripped}})"

return M
