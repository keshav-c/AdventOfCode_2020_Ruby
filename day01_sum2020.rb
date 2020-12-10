def find_2sum(nums, sum)
  nums[0..-2].each_index do |i|
    num1 = nums[i]
    num2 = sum - num1
    num2_index = nums[(i + 1)..-1].find_index(num2)
    return [num1, num2] unless num2_index.nil?
  end
  nil
end

def find_3sum_2020(nums)
  nums.each.with_index do |num1, i|
    remaining = nums.clone
    remaining.delete_at(i)
    balance = 2020 - num1
    balance_search_result = find_2sum(remaining, balance)
    next if balance_search_result.nil?
    num2, num3 = balance_search_result
    return [num1, num2, num3]
  end
  nil
end


input = File.new('sum2020_input.txt')
numbers = input.readlines.map { |line| line.to_i }
num1, num2 = find_2sum(numbers, 2020)
product_2sum_2020 = num1 * num2
puts product_2sum_2020
num1, num2, num3 = find_3sum_2020(numbers)
product_3sum_2020 = num1 * num2 * num3
puts product_3sum_2020