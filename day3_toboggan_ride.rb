class TobogganNavigator
  attr_reader :terrain_pattern, :grid_rows, :grid_cols

  def initialize(terrain_pattern)
    @terrain_pattern = terrain_pattern
    @grid_rows = terrain_pattern.size
    @grid_cols = terrain_pattern[0].size
  end

  def num_trees_encountered_in_vector(delta_row:, delta_col:)
    current_row = 0
    current_col = 0
    trees_encountered = 0
    while true
      current_row += delta_row
      break if current_row >= grid_rows
      current_col = (current_col + delta_col) % grid_cols
      trees_encountered += terrain_pattern[current_row][current_col] == '#' ? 1 : 0
    end
    return trees_encountered
  end
end

vectors = [
  {
    delta_row: 1,
    delta_col: 1
  },
  {
    delta_row: 1,
    delta_col: 3
  },
  {
    delta_row: 1,
    delta_col: 5
  },
  {
    delta_row: 1,
    delta_col: 7
  },
  {
    delta_row: 2,
    delta_col: 1
  },
]

terrain_pattern = File.new('day3_input.txt').readlines.map(&:chomp)
navigator = TobogganNavigator.new(terrain_pattern)

product_of_trees_in_vectors = vectors
  .map { |v| navigator.num_trees_encountered_in_vector(v) }
  .reduce(1, :*)

puts product_of_trees_in_vectors