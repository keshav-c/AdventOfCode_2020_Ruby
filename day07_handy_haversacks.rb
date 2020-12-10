class RulesParser
  attr_reader :rules

  def initialize(rules_list)
    @rules = {}
    rules_list.each { |rule| parse_and_add(rule) }
  end

  def has_inner?(outer:, target_type:)
    return false if rules[outer].nil?
    return true if rules[outer].has_key? target_type

    inner_bags = rules[outer]
    inner_bags.each_key do |bag|
      return true if has_inner?(outer: bag, target_type: target_type)
    end
    false
  end

  def num_bags_containing_target(target_type:)
    count = 0
    rules.each_key do |bag_type|
      count += 1 if has_inner?(outer: bag_type, target_type: target_type)
    end
    count
  end

  def num_bags_inside_type(outer_type:, outer_most: true)
    return (outer_most ? 0 : 1) if rules[outer_type].nil?

    num_inner = 0
    inner_bags = rules[outer_type]
    inner_bags.each_pair do |bag_type, num_bags|
      num_bags_in_inner = num_bags_inside_type(outer_type: bag_type, outer_most: false)
      num_inner += num_bags * num_bags_in_inner
    end
    num_inner + (outer_most ? 0 : 1)
  end

  private

  def parse_and_add(rule)
    bag = rule.match(/^(?<outer>\w+ \w+) bags contain (?<inner>.+).$/)
    if bag[:inner] == 'no other bags'
      rules[bag[:outer]] = nil
    else
      rules[bag[:outer]] = {}
      bag[:inner].scan(/(\d+) (\w+ \w+) bags?/) do |num, type|
        rules[bag[:outer]][type] = num.to_i
      end
    end
  end
end

rules_list = File.new('day7_input.txt').readlines.map(&:chomp)
parser = RulesParser.new(rules_list)
num_bags_containing_shiny_gold = parser.num_bags_containing_target(target_type: 'shiny gold')
puts "#{num_bags_containing_shiny_gold} bag types eventually contain atleast one shiny gold bag"
nums_bags_in_shiny_gold = parser.num_bags_inside_type(outer_type: 'shiny gold')
puts "A single shiny gold bag contains #{nums_bags_in_shiny_gold} bags"