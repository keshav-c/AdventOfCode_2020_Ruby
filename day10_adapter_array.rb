class AdapterManager
  attr_reader :ratings
  
  def initialize(ratings)
    @ratings = ratings.clone
    source_rating = 0
    @ratings.unshift(source_rating)
    @ratings.sort!
    device_rating = @ratings[-1] + 3
    @ratings << device_rating
  end

  def get_product_1diff_3diff
    dist = get_joltage_difference_distribution
    diff1, diff3 = dist.values_at(1, 3)
    diff1 * diff3
  end

  def count_adapter_arrangements
    ratings.reverse!
    count = num_arrangements_till_index(0)
    ratings.reverse!
    return count
  end

  private

  def get_joltage_difference_distribution
    dist = {
      1 => 0,
      2 => 0,
      3 => 0
    }
    (1...(ratings.length)).each do |i|
      difference = (ratings[i] - ratings[i-1]).abs
      dist[difference] += 1
    end
    return dist
  end

  def num_arrangements_till_index(index, memo = [])
    return memo[index] unless memo[index].nil?
    val = ratings[index]
    return 1 if val <= 1

    memo[index] = (1..3)
      .map { |i| index + i }
      .filter { |i| i < ratings.length && (ratings[index] - ratings[i]).abs <= 3 }
      .map { |i| num_arrangements_till_index(i, memo) }
      .reduce(:+)
  end
end

adapter_ratings = File.new('day10_input.txt').readlines.map(&:to_i)
manager = AdapterManager.new(adapter_ratings)

puts manager.get_product_1diff_3diff
puts manager.count_adapter_arrangements
