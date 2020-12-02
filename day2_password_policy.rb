def old_valid_password?(password:, policy:)
  char, min_count, max_count = policy[:char], policy[:num1], policy[:num2]
  mandatory_char_count = password.count(char)
  mandatory_char_count >= min_count && mandatory_char_count <= max_count
end

def new_valid_password?(password:, policy:)
  char, position1, position2 = policy[:char], policy[:num1] - 1, policy[:num2] - 1
  (password[position1] == char) ^ (password[position2] == char)
end

input = File.new('day2_input.txt')
policy_format = /(?<num1>\d+)-(?<num2>\d+) (?<char>.): (?<password>\w+)/
password_database = input.readlines.map do |line|
  parsed_results = line.match(policy_format)
  {
    :policy => { 
      :num1 => parsed_results[:num1].to_i, 
      :num2 => parsed_results[:num2].to_i,
      :char => parsed_results[:char],
    },
    :password => parsed_results[:password] 
  }
end

puts password_database.size

num_valid_passwords = password_database.count { |record| old_valid_password? record }
puts num_valid_passwords
num_valid_passwords = password_database.count { |record| new_valid_password? record }
puts num_valid_passwords