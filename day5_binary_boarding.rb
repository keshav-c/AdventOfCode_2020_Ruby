class BoardingPass
  include Comparable
  attr_reader :pass_code, :row_number, :col_number, :id

  def initialize(pass_code)
    @pass_code = pass_code
    @row_number = convert_pass_code_to_decimal(pass_code[0..6], char_0: 'F', char_1: 'B')
    @col_number = convert_pass_code_to_decimal(pass_code[7..9], char_0: 'L', char_1: 'R')
    @id = @row_number * 8 + @col_number
  end

  def <=>(another_pass)
    id <=> another_pass.id
  end

  private

  def convert_pass_code_to_decimal(*args)
    binary_pass_code = text_to_binary_array(*args)
    binary_pass_code.each_with_index.inject(0) do |decimal_value, (binary_zone, index)|
      decimal_value + binary_zone * (2 ** index)
    end
  end

  def text_to_binary_array(text_representation, char_0:, char_1:)
    text_representation.gsub!(char_0, '0')
    text_representation.gsub!(char_1, '1')
    text_representation.chars.reverse.map(&:to_i)
  end
end

class BoardingPassManager
  attr_reader :passes

  def initialize(pass_codes)
    @passes = pass_codes.map { |code| BoardingPass.new(code) }
    @passes.sort!
  end

  def get_max_id
    passes[-1].id
  end

  def get_min_id
    passes[0].id
  end

  def get_missing_id
    searchable_list = map_passes_by_id
    (get_min_id..get_max_id).each do |id|
      return id if searchable_list[id].nil?
    end
  end

  private

  def map_passes_by_id
    searchable_list = {}
    passes.each { |pass| searchable_list[pass.id] = pass }
    searchable_list
  end
end

boarding_pass_codes = File.new('day5_input.txt').readlines.map(&:chomp) 
pass_manager = BoardingPassManager.new(boarding_pass_codes)

max_id = pass_manager.get_max_id
puts "The max id found is #{max_id}"

missing_id = pass_manager.get_missing_id
puts "The missing id from the list of passes is #{missing_id}"
