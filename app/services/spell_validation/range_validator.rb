# frozen_string_literal: true

module SpellValidation
  # RangeValidator - Validates spell range and area of effect
  # Implements D&D 5e spell targeting rules
  #
  # Range Types:
  # - Self: Affects only the caster
  # - Touch: Must be within 5 feet
  # - Ranged: Specified distance (30 ft, 60 ft, 120 ft, etc.)
  # - Sight: Must be visible to caster
  # - Unlimited: No range restriction
  #
  # Area of Effect Shapes:
  # - Cone: Directional area emanating from caster
  # - Cube: Square area
  # - Cylinder: Circular area with height
  # - Line: Straight line from caster
  # - Sphere: Circular area around a point
  class RangeValidator
    attr_reader :spell, :caster_position, :target_position

    def initialize(spell, caster_position, target_position = nil)
      @spell = spell
      @caster_position = caster_position
      @target_position = target_position
    end

    # Validate spell range
    # Returns { valid: true/false, errors: [], warnings: [] }
    def validate_range
      errors = []
      warnings = []

      # Parse spell range
      range_info = parse_spell_range

      case range_info[:type]
      when :self
        # Self spells don't need target validation
        if target_position && target_position != caster_position
          warnings << "This spell only affects you (Self range)."
        end

      when :touch
        # Touch spells require target within 5 feet
        if target_position
          distance = calculate_distance(caster_position, target_position)
          if distance > 5
            errors << "Target is too far away. Touch spells require the target to be within 5 feet (currently #{distance} ft)."
          end
        else
          warnings << "Touch spell requires a target within 5 feet."
        end

      when :ranged
        # Ranged spells have specific distance limits
        if target_position
          distance = calculate_distance(caster_position, target_position)
          max_range = range_info[:distance]

          if distance > max_range
            errors << "Target is out of range. This spell has a maximum range of #{max_range} feet (target is #{distance} ft away)."
          end

          # Warn if at long range (if spell has disadvantage)
          if range_info[:long_range] && distance > range_info[:long_range]
            warnings << "Target is at long range (#{distance} ft). Attack rolls may have disadvantage."
          end
        else
          warnings << "Ranged spell requires a target within #{range_info[:distance]} feet."
        end

      when :sight
        # Sight spells require line of sight
        if target_position
          unless has_line_of_sight?(caster_position, target_position)
            errors << "You cannot see the target. This spell requires line of sight."
          end
        else
          warnings << "This spell requires a visible target."
        end

      when :unlimited
        # Unlimited range - no restrictions
        warnings << "This spell has unlimited range."
      end

      {
        valid: errors.empty?,
        errors: errors,
        warnings: warnings
      }
    end

    # Validate area of effect positioning
    # Returns { valid: true/false, errors: [], warnings: [], affected_positions: [] }
    def validate_aoe_positioning(all_positions = {})
      errors = []
      warnings = []
      affected_positions = []

      aoe_info = parse_aoe_info

      return { valid: true, errors: [], warnings: ['Not an AoE spell'], affected_positions: [] } unless aoe_info

      # Calculate affected positions based on AoE shape
      case aoe_info[:shape]
      when :cone
        affected_positions = calculate_cone_affected(caster_position, target_position, aoe_info[:size], all_positions)
      when :cube
        affected_positions = calculate_cube_affected(target_position, aoe_info[:size], all_positions)
      when :cylinder
        affected_positions = calculate_cylinder_affected(target_position, aoe_info[:radius], aoe_info[:height], all_positions)
      when :line
        affected_positions = calculate_line_affected(caster_position, target_position, aoe_info[:width], aoe_info[:length], all_positions)
      when :sphere
        affected_positions = calculate_sphere_affected(target_position, aoe_info[:radius], all_positions)
      end

      # Check for friendly fire
      friendly_positions = all_positions.select { |pos, data| data[:friendly] }.keys
      friendly_affected = affected_positions & friendly_positions

      if friendly_affected.any?
        warnings << "Warning: #{friendly_affected.size} friendly creature(s) will be affected by this spell!"
      end

      {
        valid: errors.empty?,
        errors: errors,
        warnings: warnings,
        affected_positions: affected_positions
      }
    end

    # Calculate all positions affected by an AoE spell
    def calculate_aoe_targets(center_position, all_positions)
      aoe_info = parse_aoe_info
      return [] unless aoe_info

      case aoe_info[:shape]
      when :sphere
        calculate_sphere_affected(center_position, aoe_info[:radius], all_positions)
      when :cube
        calculate_cube_affected(center_position, aoe_info[:size], all_positions)
      when :cone
        calculate_cone_affected(caster_position, center_position, aoe_info[:size], all_positions)
      when :line
        calculate_line_affected(caster_position, center_position, aoe_info[:width], aoe_info[:length], all_positions)
      when :cylinder
        calculate_cylinder_affected(center_position, aoe_info[:radius], aoe_info[:height], all_positions)
      else
        []
      end
    end

    private

    # Parse spell range from spell object
    def parse_spell_range
      return { type: :self, distance: 0 } unless spell.respond_to?(:range)

      range_str = spell.range.to_s.downcase

      case range_str
      when 'self'
        { type: :self, distance: 0 }
      when 'touch'
        { type: :touch, distance: 5 }
      when 'sight'
        { type: :sight, distance: Float::INFINITY }
      when 'unlimited'
        { type: :unlimited, distance: Float::INFINITY }
      else
        # Parse distance (e.g., "60 feet", "120 ft", "30'")
        if range_str.match(/(\d+)\s*(?:feet|ft|')/)
          distance = range_str.match(/(\d+)/)[1].to_i
          { type: :ranged, distance: distance }
        else
          { type: :self, distance: 0 }
        end
      end
    end

    # Parse area of effect information
    def parse_aoe_info
      return nil unless spell.respond_to?(:area_of_effect)
      return nil unless spell.area_of_effect

      aoe_str = spell.area_of_effect.to_s.downcase

      # Examples: "15-foot cone", "20-foot radius sphere", "5 by 30 ft line"
      if aoe_str.include?('cone')
        size = aoe_str.match(/(\d+)/)[1].to_i
        { shape: :cone, size: size }
      elsif aoe_str.include?('sphere') || aoe_str.include?('radius')
        radius = aoe_str.match(/(\d+)/)[1].to_i
        { shape: :sphere, radius: radius }
      elsif aoe_str.include?('cube')
        size = aoe_str.match(/(\d+)/)[1].to_i
        { shape: :cube, size: size }
      elsif aoe_str.include?('line')
        # Parse "5 by 30 ft" or "30-foot line"
        matches = aoe_str.scan(/(\d+)/)
        if matches.size >= 2
          width = matches[0][0].to_i
          length = matches[1][0].to_i
        else
          width = 5
          length = matches[0][0].to_i
        end
        { shape: :line, width: width, length: length }
      elsif aoe_str.include?('cylinder')
        # Parse "10-foot radius, 40-foot high cylinder"
        matches = aoe_str.scan(/(\d+)/)
        radius = matches[0][0].to_i
        height = matches[1] ? matches[1][0].to_i : 10
        { shape: :cylinder, radius: radius, height: height }
      else
        nil
      end
    end

    # Calculate distance between two positions (Euclidean distance)
    def calculate_distance(pos1, pos2)
      return 0 if pos1 == pos2

      # Assume positions are hashes with :x, :y coordinates
      # If positions are strings/identifiers, return estimated distance
      return 30 unless pos1.is_a?(Hash) && pos2.is_a?(Hash)

      x1 = pos1[:x] || 0
      y1 = pos1[:y] || 0
      x2 = pos2[:x] || 0
      y2 = pos2[:y] || 0

      # D&D uses 5-foot grid squares, so calculate grid distance
      dx = (x2 - x1).abs
      dy = (y2 - y1).abs

      # Diagonal movement: max(dx, dy) * 5 (simplified)
      [dx, dy].max * 5
    end

    # Check line of sight between two positions
    def has_line_of_sight?(pos1, pos2)
      # Simplified line of sight check
      # In full implementation, would check for obstacles, walls, etc.
      # For now, assume line of sight if within reasonable distance
      distance = calculate_distance(pos1, pos2)
      distance < 120 # Assume no obstacles within 120 feet
    end

    # Calculate positions affected by sphere AoE
    def calculate_sphere_affected(center, radius, all_positions)
      return [] unless all_positions.is_a?(Hash)

      all_positions.select do |pos, _data|
        calculate_distance(center, pos) <= radius
      end.keys
    end

    # Calculate positions affected by cube AoE
    def calculate_cube_affected(center, size, all_positions)
      return [] unless all_positions.is_a?(Hash)

      half_size = size / 2

      all_positions.select do |pos, _data|
        next false unless pos.is_a?(Hash)

        dx = ((pos[:x] || 0) - (center[:x] || 0)).abs
        dy = ((pos[:y] || 0) - (center[:y] || 0)).abs

        dx <= half_size && dy <= half_size
      end.keys
    end

    # Calculate positions affected by cone AoE
    def calculate_cone_affected(origin, direction_point, size, all_positions)
      return [] unless all_positions.is_a?(Hash)

      all_positions.select do |pos, _data|
        distance = calculate_distance(origin, pos)
        next false if distance > size

        # Simplified cone check: within 90-degree arc
        # In full implementation, would calculate angle properly
        distance <= size
      end.keys
    end

    # Calculate positions affected by line AoE
    def calculate_line_affected(origin, end_point, width, length, all_positions)
      return [] unless all_positions.is_a?(Hash)

      all_positions.select do |pos, _data|
        distance = calculate_distance(origin, pos)
        next false if distance > length

        # Simplified line check
        # In full implementation, would check perpendicular distance from line
        distance <= length
      end.keys
    end

    # Calculate positions affected by cylinder AoE
    def calculate_cylinder_affected(center, radius, height, all_positions)
      # Simplified: treat as sphere for 2D grid
      calculate_sphere_affected(center, radius, all_positions)
    end
  end
end
