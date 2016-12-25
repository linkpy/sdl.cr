require "./texture"

module SDL
  alias BlendMode = LibSDL::BlendMode

  class Renderer
    struct Info
      delegate flags, max_texture_width, max_texture_height, to: @info

      def initialize(@info : LibSDL::RendererInfo)
      end

      def name
        String.new(@info.name)
      end

      # TODO: Renderer::Info#texture_formats
      #def texture_formats
      #end
    end

    alias Flags = LibSDL::RendererFlags

    def initialize(window : Window, flags : Flags = Flags::ACCELERATED)
      @renderer = LibSDL.create_renderer(window, -1, flags)
      raise Error.new("SDL_CreateRenderer") unless @renderer
    end

    def finalize
      LibSDL.destroy_renderer(self)
    end

    def info
      ret = LibSDL.get_renderer_info(self, out info)
      raise Error.new("SDL_GetRendererInfo") unless ret == 0
      Info.new(info.value)
    end

    def output_size
      ret = LibSDL.get_renderer_output_size(self, out w, out h)
      raise Error.new("SDL_GetRendererOutputSize") unless ret == 0
      {w, h}
    end

    def target_supported?
      ret = LibSDL.render_target_supported(self, texture)
      raise Error.new("SDL_RenderTargetSupported") unless ret == 0
    end

    def target=(texture = nil)
      ret = LibSDL.set_render_target(self, texture)
      raise Error.new("SDL_SetRenderTarget") unless ret == 0
    end

    def target
      texture = LibSDL.get_render_target(self)
      raise Error.new("SDL_SetRenderTarget") unless ret == 0
      texture ? Texture.new(texture) : nil
    end

    def logical_size=(xy)
      ret = LibSDL.render_set_logical_size(self, *xy)
      raise Error.new("SDL_RenderSetLogicalSize") unless ret == 0
      xy
    end

    def logical_size
      LibSDL.render_get_logical_size(self, out x, out y)
      {x, y}
    end

    def viewport=(rect)
      ret = LibSDL.render_set_viewport(self, Rect.from(rect))
      raise Error.new("SDL_RenderSetViewport") unless ret == 0
      rect
    end

    def viewport
      LibSDL.render_get_viewport(self, out rect)
      Rect.from(rect)
    end

    def clip_rect=(rect)
      ret = LibSDL.render_set_clip_rect(self, Rect.from(rect))
      raise Error.new("SDL_RenderSetClipRect") unless ret == 0
      rect
    end

    def clip_rect
      LibSDL.render_get_cli_rect(self, out rect)
      Rect.from(rect)
    end

    def scale=(xy)
      ret = LibSDL.render_set_scale(self, *xy)
      raise Error.new("SDL_RenderSetScale") unless ret == 0
      xy
    end

    def scale
      LibSDL.render_get_scale(self, out x, out y)
      {x, y}
    end

    # Set the color for drawing operations (lines, rectangles and clear).
    def draw_color=(rgba)
      ret = LibSDL.set_render_draw_color(self, *rgba)
      raise Error.new("SDL_SetRenderDrawColor") unless ret == 0
      rgba
    end

    # Get the current drawing color.
    def draw_color
      ret = LibSDL.get_render_draw_color(self, out r, out g, out b, out a)
      raise Error.new("SDL_GetRenderDrawColor") unless ret == 0
      {r.to_i, g.to_i, b.to_i, a.to_i}
    end

    # Set the blen mode for drawing operations (fill, lines).
    def draw_blend_mode=(blend_mode : BlendMode)
      ret = LibSDL.set_render_draw_blend_mode(self, blend_mode)
      raise Error.new("SDL_SetRenderDrawBlendMode") unless ret == 0
      blend_mode
    end

    # Get the current drawing blend mode.
    def draw_blend_mode
      ret = LibSDL.get_render_draw_blend_mode(self, out blend_mode)
      raise Error.new("SDL_GetRenderDrawBlendMode") unless ret == 0
      blend_mode
    end

    # Fills the target texture using the current `draw_color`.
    def clear
      LibSDL.render_clear(self)
    end

    # Draw a single `Point`.
    def draw_point(point)
      ret = LibSDL.render_draw_point(self, point.x, point.y)
      raise Error.new("SDL_RenderDrawPoint") unless ret == 0
    end

    def draw_point(x, y)
      ret = LibSDL.render_draw_point(self, x, y)
      raise Error.new("SDL_RenderDrawPoint") unless ret == 0
    end

    # Draw many `Point` at once.
    def draw_points(points)
      ret = LibSDL.render_draw_points(self, points, points.size)
      raise Error.new("SDL_RenderDrawPoints") unless ret == 0
    end

    # Draw a single line between two `Point`.
    def draw_line(a, b)
      ret = LibSDL.render_draw_line(self, a.x, a.y, b.x, b.y)
      raise Error.new("SDL_RenderDrawLine") unless ret == 0
    end

    # Draw a single line between two `Point`.
    def draw_line(x1, y1, x2, y2)
      ret = LibSDL.render_draw_line(self, x1, y2, x2, y2)
      raise Error.new("SDL_RenderDrawLine") unless ret == 0
    end

    # Draw a line between following a series of `Point`.
    def draw_lines(points)
      ret = LibSDL.render_draw_lines(self, points, points.size)
      raise Error.new("SDL_RenderDrawLines") unless ret == 0
    end

    # Draw a single `Rect`.
    def draw_rect(rect)
      ret = LibSDL.render_draw_rect(self, Rect.from(rect))
      raise Error.new("SDL_RenderDrawRect") unless ret == 0
    end

    # Draw a single `Rect`.
    def draw_rect(x, y, w, h)
      ret = LibSDL.render_draw_rect(self, Rect.new(x, y, w, h))
      raise Error.new("SDL_RenderDrawRect") unless ret == 0
    end

    # Draw many `Rect` at once.
    def draw_rects(rects)
      sdl_rects = rects.map { |r| Rect.from(r) }
      ret = LibSDL.render_draw_rects(self, sdl_rects, sdl_rects.size)
      raise Error.new("SDL_RenderDrawRects") unless ret == 0
    end

    # Fill a `Rect` with the current `draw_color` and `draw_blend_mode`.
    def fill_rect(rect)
      ret = LibSDL.render_fill_rect(self, Rect.from(rect))
      raise Error.new("SDL_RenderFillRect") unless ret == 0
    end

    # Fill a `Rect` with the current `draw_color` and `draw_blend_mode`.
    def fill_rect(x, y, w, h)
      ret = LibSDL.render_fill_rect(self, Rect.new(x, y, w, h))
      raise Error.new("SDL_RenderFillRect") unless ret == 0
    end

    # Fill many `Rect` at once with the current `draw_color` and `draw_blend_mode`.
    def fill_rects(rects)
      sdl_rects = rects.map { |r| Rect.from(r) }
      ret = LibSDL.render_fill_rects(self, sdl_rects, sdl_rects.size)
      raise Error.new("SDL_RenderFillRects") unless ret == 0
    end

    # Copy a texture to the renderer's target texture.
    def copy(texture, srcrect = nil, dstrect = nil)
      LibSDL.render_copy(self, texture, Rect.from(srcrect), Rect.from(dstrect))
    end

    #def read_pixels
    #end

    # Render the target texture to the screen.
    def present
      LibSDL.render_present(self)
    end

    def to_unsafe
      @renderer
    end
  end
end