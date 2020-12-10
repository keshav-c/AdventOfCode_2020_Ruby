class CustomsQueryProcessor
  attr_reader :group_data
  
  def initialize(raw_form_data)
    groups = parse_forms_data(raw_form_data)
    @group_data = groups.map.with_index do |group, i|
      {
        id: i + 1,
        passenger_answers: group
      }
    end
    compute_num_any_yes_answers_per_group
    compute_num_all_yes_answers_per_group
  end

  def get_sum_of_unique_answers
    group_data.sum { |group| group[:num_unique_affirmative_answers] }
  end

  def get_sum_of_common_answers
    group_data.sum { |group| group[:num_common_affirmative_answers] }
  end

  private
  
  def compute_num_any_yes_answers_per_group
    group_data.each do |group|
      unique_answers_list = group[:passenger_answers].map(&:chars).inject(:union)
      group[:num_unique_affirmative_answers] = unique_answers_list.length
    end
  end

  def compute_num_all_yes_answers_per_group
    group_data.each do |group|
      common_answers_list = group[:passenger_answers].map(&:chars).inject(:&)
      group[:num_common_affirmative_answers] = common_answers_list.length
    end
  end

  def parse_forms_data(raw_data)
    groups = []
    passengers = []
    raw_data.each do |line|
      if line.empty?
        groups << passengers
        passengers = []
      else
        passengers << line
      end
    end
    groups << passengers
  end
end

customs_forms_data = File.new('day6_input.txt').readlines.map(&:chomp)
query_processor = CustomsQueryProcessor.new(customs_forms_data)
puts "The sum of unique affirmative answers is #{query_processor.get_sum_of_unique_answers}"
puts "The sum of common affirmative answers is #{query_processor.get_sum_of_common_answers}"