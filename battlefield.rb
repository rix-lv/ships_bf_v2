class Field

  attr_accessor :size, :ships


  # side_size - size of the square
  def initialize(side_size = 10)
    @size = side_size
    @ships_to_place = { 4 => 1, 3 => 2, 2 => 3, 1 => 4 } # hash
    @ships = []
  end

  # clear all ships
  def reset!
    @ships = []
  end

  # places all ships on the field
  def place_ships!
    @ships = []
    @ships_to_place.each do |key, count|
      count.times do
        ship = Ship.new(key, self)

        ship.place!

        @ships << ship
      end
    end
  end

  # displays all ships from the field
  def print
    @ships.each do |ship|
      ship.show
    end
  end

  # displays battlefield with ships
  # ships_to_show - if provided, can show ships from a param
  def show_field(ships_to_show = @ships)
    field  = Array.new(10).map!{Array.new(10) {'*'}}


    ships_to_show.each do |ship|
      next unless ship.head_x
      ship.palubs.each do |pal|
        x = pal[:x]
        y = pal[:y]
        field[x][y] = ship.size.to_s
      end
    end

    last_char = ('A'.codepoints.first + size - 1).chr

    puts (["  "] + ('A'..last_char).to_a).join(" ")

    field.each_with_index do |line, i|

      first_number = format("%2d", (i+1))


      puts(([first_number] + line).join(" "))

    end
    return nil
  end
end

class Ship
  attr_accessor :size, :vertical, :head_x, :head_y, :field, :correct

  def initialize(size, field)
    @size = size
    @vertical = rand(2) == 1
    @field = field
  end

  # displays information about the ship
  def show
    p "⛵️x#{size} [#{head_x}, #{head_y}]"
  end

  # returns an array of Hashes with coordinates of each palaba
  def palubs
    pals = []
    size.times do |n|
      if vertical
        x = head_x
        y = head_y + n
      else
        x = head_x + n
        y = head_y
      end
      pals << {x: x, y: y}
    end
    pals
  end

  # returns array of Hashes with coordinates around one paluba
  # includes paluba coordinates too
  def around_paluba(x, y)
    places = []

    (-1..1).to_a.each do |x_i|
      (-1..1).to_a.each do |y_i|
        places << {x: x + x_i, y: y + y_i}
      end
    end
    places
  end

  # returns array of Hashes with coordinates of every field position around ship
  # also includes palubas
  def outside_area
    around = []
    palubs.each do |pal|
      around += around_paluba(pal[:x], pal[:y])
    end
    around.uniq
  end

  # check if this ship intercepts with ship from param
  def intercepts?(ship)
    return false if self == ship
    outside_values = outside_area.map{ |d| [d[:x], d[:y]] }
    palubs_value = ship.palubs.map{ |d| [d[:x], d[:y]] }
    res = outside_values & palubs_value
    res.count > 0
  end

  # checks if the ship is places within a field
  def within_field?

    return false unless head_x

    result = true
    palubs.each do |pal|
      result &&= pal[:x] < field.size && pal[:y] < field.size
    end
    result
  end

  # check if the position of the ship is correct
  def correct_position?
    return false unless head_x
    result = true
    field.ships.each do |ship|
      result &&= !intercepts?(ship)
    end
    result
  end


  # places ship on the field on an available position
  def place!
    until within_field? && correct_position?
      @head_x = rand(field.size)
      @head_y = rand(field.size)
    end
  end

end


f = Field.new
f.place_ships!
f.show_field
