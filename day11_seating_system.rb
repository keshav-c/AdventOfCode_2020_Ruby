class Seat
  attr_reader :row, :col
  def initialize(row, col)
  end
end

class SeatingSimulator
  attr_accessor :grid
  attr_reader :n_rows, :n_cols
  
  def initialize(data_file)
    @grid = data_file.readlines.map(&:chomp).map(&:chars)
    @n_rows = @grid.length
    @n_cols = @grid[0].length
  end

  def seat_until_stabilisation(rule_set:)
    while true
      new_grid = grid_after_one_round_of_seating(rule_set: rule_set)
      break if new_grid == grid
      self.grid = new_grid
    end
    self
  end

  def get_num_occupied_seats
    grid
      .map { |row| row.count('#') }
      .reduce(:+)
  end

  def print_grid
    grid.each { |row| puts "| #{row.join(' ')} |" }
  end

  private

  def grid_after_one_round_of_seating(rule_set:)
    rule_sets = {
      1 => :apply_rules1,
      2 => :apply_rules2
    }
    apply = self.method(rule_sets[rule_set])
    new_grid = Array.new(n_rows)
    new_grid.map! { |x| Array.new(n_cols) }
    (0...n_rows).each do |row|
      (0...n_cols).each do |col|
        seat = { row: row, col: col }
        new_grid[row][col] = apply.call(seat)
      end
    end
    new_grid
  end

  def apply_rules1(row:, col:)
    seat = { row: row, col: col }
    if is_seat?(seat)
      num_adjacent_occupied = count_adjacent_occupied(seat)
      if is_occupied?(seat)
        num_adjacent_occupied >= 4 ? 'L' : '#'
      else
        num_adjacent_occupied == 0 ? '#' : 'L'
      end
    else
      '.'
    end
  end

  def apply_rules2(row:, col:)
    seat = { row: row, col: col }
    if is_seat?(seat)
      num_visible_occupied = count_visible_occupied(seat)
      if is_occupied?(seat)
        num_visible_occupied >= 5 ? 'L' : '#'
      else
        num_visible_occupied == 0 ? '#' : 'L'
      end
    else
      '.'
    end
  end

  def is_seat?(row:, col:)
    grid[row][col] != '.'
  end

  def count_adjacent_occupied(row:, col:)
    adjacent_seats(row: row, col: col).count { |seat| is_occupied?(seat) }
  end

  def count_visible_occupied(row:, col:)
    seat = { row: row, col: col }
    get_deltas.count { |delta| visible_occupied_in_direction?(seat, delta) }
  end

  def visible_occupied_in_direction?(seat, delta)
    next_seat = get_next_seat_in_direction(seat, delta)
    while next_seat
      if is_seat?(next_seat)
        return is_occupied?(next_seat)
      else
        next_seat = get_next_seat_in_direction(next_seat, delta)
      end
    end
    false
  end

  def get_next_seat_in_direction(seat, delta)
    row_delta, col_delta = delta
    next_seat = { row: seat[:row] + row_delta, col: seat[:col] + col_delta }
    is_seat_within_grid?(next_seat) ? next_seat : nil
  end

  def is_occupied?(row:, col:)
    grid[row][col] == '#'
  end

  def adjacent_seats(row:, col:)
    seats = []
    deltas = get_deltas
    deltas.each do |row_delta, col_delta|
      seat = { row: row + row_delta, col: col + col_delta }
      seats << seat if is_seat_within_grid?(seat) && is_seat?(seat)
    end
    seats
  end

  def get_deltas
    delta_values = [1, -1, 0]
    deltas = delta_values.repeated_permutation(2).to_a
    deltas.delete([0, 0])
    deltas
  end

  def is_seat_within_grid?(row:, col:)
    return false if row < 0 || row >= n_rows
    return false if col < 0 || col >= n_cols
    true
  end
end

(1..2).each do |rule_set|
  seating_data_file = File.new('day11_input.txt')
  simulator = SeatingSimulator.new(seating_data_file)
  num_occupied = simulator.seat_until_stabilisation(rule_set: rule_set).get_num_occupied_seats
  puts "#{num_occupied} seats are left occupied when using rule set #{rule_set}"
end