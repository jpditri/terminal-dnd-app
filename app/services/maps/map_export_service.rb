# frozen_string_literal: true

module Maps
  # Exports dungeon maps in various formats
  class MapExportService
    attr_reader :dungeon_map

    def initialize(dungeon_map)
      @dungeon_map = dungeon_map
    end

    # Export as JSON
    def export_json
      dungeon_map.to_export_hash.to_json
    end

    # Export as ASCII text
    def export_ascii(options = {})
      include_legend = options.fetch(:include_legend, true)
      include_metadata = options.fetch(:include_metadata, true)
      fog_mode = options.fetch(:fog_mode, 'none')

      renderer = AsciiMapRenderer.new(dungeon_map)
      output = []

      # Header
      if include_metadata
        output << "# #{dungeon_map.name}"
        output << "# Size: #{dungeon_map.width}x#{dungeon_map.height}"
        output << "# Rooms: #{dungeon_map.map_rooms.count}"
        output << "# Generated: #{dungeon_map.created_at&.strftime('%Y-%m-%d %H:%M')}"
        output << ""
      end

      # Map
      output << renderer.render(nil, fog_mode)

      # Legend
      if include_legend
        output << ""
        output << "Legend:"
        output << "  @ = Party        # = Wall          . = Floor"
        output << "  + = Door         / = Open door     X = Locked"
        output << "  < = Stairs up    > = Stairs down   ^ = Trap"
        output << "  $ = Treasure     N = NPC           E = Enemy"
        output << "  B = Boss         ~ = Water         O = Pit"
      end

      output.join("\n")
    end

    # Export as SVG
    def export_svg(options = {})
      tile_size = options.fetch(:tile_size, 20)
      fog_mode = options.fetch(:fog_mode, 'none')
      show_grid = options.fetch(:show_grid, false)

      width = dungeon_map.width * tile_size
      height = dungeon_map.height * tile_size

      svg = []
      svg << %{<?xml version="1.0" encoding="UTF-8"?>}
      svg << %{<svg xmlns="http://www.w3.org/2000/svg" width="#{width}" height="#{height}" viewBox="0 0 #{width} #{height}">}
      svg << %{  <style>}
      svg << %{    .wall { fill: #333; }}
      svg << %{    .floor { fill: #ccc; }}
      svg << %{    .door { fill: #8B4513; }}
      svg << %{    .door_open { fill: #D2691E; }}
      svg << %{    .door_locked { fill: #4a0000; }}
      svg << %{    .stairs { fill: #666; }}
      svg << %{    .trap { fill: #ff4444; }}
      svg << %{    .chest { fill: #FFD700; }}
      svg << %{    .water { fill: #4169E1; }}
      svg << %{    .player { fill: #00ff00; }}
      svg << %{    .enemy { fill: #ff0000; }}
      svg << %{    .npc { fill: #0066ff; }}
      svg << %{    .fog { fill: #000; opacity: 0.7; }}
      svg << %{    .revealed { fill: #000; opacity: 0.3; }}
      svg << %{  </style>}

      # Background
      svg << %{  <rect width="100%" height="100%" fill="#000"/>}

      # Grid lines
      if show_grid
        svg << %{  <g stroke="#444" stroke-width="0.5">}
        (0..dungeon_map.width).each do |x|
          svg << %{    <line x1="#{x * tile_size}" y1="0" x2="#{x * tile_size}" y2="#{height}"/>}
        end
        (0..dungeon_map.height).each do |y|
          svg << %{    <line x1="0" y1="#{y * tile_size}" x2="#{width}" y2="#{y * tile_size}"/>}
        end
        svg << %{  </g>}
      end

      # Tiles
      svg << %{  <g>}
      dungeon_map.tile_data.each do |tile|
        x = tile['x'] * tile_size
        y = tile['y'] * tile_size
        tile_class = svg_tile_class(tile['type'])

        # Determine visibility
        visible = case fog_mode
                  when 'none'
                    true
                  when 'partial'
                    tile['revealed'] || tile['visited']
                  when 'full'
                    tile['visited']
                  else
                    true
                  end

        if visible
          svg << %{    <rect x="#{x}" y="#{y}" width="#{tile_size}" height="#{tile_size}" class="#{tile_class}"/>}

          # Add fog overlay for revealed but not visited
          if fog_mode == 'partial' && tile['revealed'] && !tile['visited']
            svg << %{    <rect x="#{x}" y="#{y}" width="#{tile_size}" height="#{tile_size}" class="revealed"/>}
          end
        end
      end
      svg << %{  </g>}

      # Party position
      if dungeon_map.party_position
        px = dungeon_map.party_position.x * tile_size + tile_size / 2
        py = dungeon_map.party_position.y * tile_size + tile_size / 2
        radius = tile_size / 3

        svg << %{  <circle cx="#{px}" cy="#{py}" r="#{radius}" class="player"/>}
      end

      # Room labels (optional)
      if options[:show_room_labels]
        dungeon_map.map_rooms.each do |room|
          cx = room.center_x * tile_size + tile_size / 2
          cy = room.center_y * tile_size + tile_size / 2

          svg << %{  <text x="#{cx}" y="#{cy}" text-anchor="middle" fill="#fff" font-size="8">}
          svg << %{    #{room.room_type.humanize}}
          svg << %{  </text>}
        end
      end

      svg << %{</svg>}
      svg.join("\n")
    end

    # Export as PNG (requires ImageMagick or similar)
    def export_png(options = {})
      scale = options.fetch(:scale, 2)
      tile_size = options.fetch(:tile_size, 20) * scale

      # Generate SVG first
      svg_content = export_svg(options.merge(tile_size: tile_size))

      # Create temp files
      svg_path = Rails.root.join('tmp', "map_#{dungeon_map.id}_#{Time.current.to_i}.svg")
      png_path = Rails.root.join('tmp', "map_#{dungeon_map.id}_#{Time.current.to_i}.png")

      # Write SVG
      File.write(svg_path, svg_content)

      # Convert to PNG using ImageMagick (if available)
      if system('which convert > /dev/null 2>&1')
        system("convert #{svg_path} #{png_path}")

        if File.exist?(png_path)
          png_content = File.binread(png_path)

          # Cleanup
          File.delete(svg_path) if File.exist?(svg_path)
          File.delete(png_path) if File.exist?(png_path)

          return png_content
        end
      end

      # Fallback: return SVG if ImageMagick not available
      File.delete(svg_path) if File.exist?(svg_path)
      Result.failure(:imagemagick_not_available, fallback: svg_content)
    end

    # Create export record and store file
    def create_export(format, user, options = {})
      content = case format
                when 'json'
                  export_json
                when 'ascii'
                  export_ascii(options)
                when 'svg'
                  export_svg(options)
                when 'png'
                  export_png(options)
                else
                  return Result.failure(:invalid_format)
                end

      # Handle PNG failure fallback
      if content.is_a?(Result) && content.failure?
        content = content.error[:fallback]
        format = 'svg'
      end

      # Generate filename
      timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
      filename = "#{dungeon_map.name.parameterize}_#{timestamp}.#{format}"

      # Store file
      file_path = store_file(filename, content, format)

      # Create export record
      export = MapExport.create!(
        dungeon_map: dungeon_map,
        user: user,
        export_format: format,
        filename: filename,
        file_path: file_path,
        file_size: content.bytesize,
        options: options,
        expires_at: 7.days.from_now
      )

      Result.success(export: export, filename: filename, file_path: file_path)
    end

    # Generate download URL for export
    def generate_download_url(export)
      # In production, this would generate a signed URL
      # For now, return local path
      "/exports/maps/#{export.filename}"
    end

    private

    def svg_tile_class(tile_type)
      case tile_type
      when 'wall'
        'wall'
      when 'floor'
        'floor'
      when 'door', 'door_closed'
        'door'
      when 'door_open'
        'door_open'
      when 'door_locked'
        'door_locked'
      when 'stairs_up', 'stairs_down'
        'stairs'
      when 'trap'
        'trap'
      when 'chest', 'chest_open'
        'chest'
      when 'water'
        'water'
      else
        'floor'
      end
    end

    def store_file(filename, content, format)
      # In production, this would upload to S3 or similar
      # For now, store locally
      exports_dir = Rails.root.join('public', 'exports', 'maps')
      FileUtils.mkdir_p(exports_dir)

      file_path = exports_dir.join(filename)

      if format == 'png'
        File.binwrite(file_path, content)
      else
        File.write(file_path, content)
      end

      file_path.to_s
    end
  end
end
