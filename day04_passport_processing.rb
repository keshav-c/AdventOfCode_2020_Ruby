class Passport
  attr_reader :details

  def initialize(details)
    @details = details
  end

  def has_all_mandatory_fields
    mandatory_fields = ['byr', 'iyr', 'eyr', 'hgt', 'hcl', 'ecl', 'pid']
    mandatory_fields.all? { |field| !details[field].nil? }
  end

  def valid_byr
    return false unless details['byr'].match? /^\d{4}$/

    details['byr'].to_i >= 1920 && details['byr'].to_i <= 2002
  end

  def valid_iyr
    return false unless details['iyr'].match? /^\d{4}$/

    details['iyr'].to_i >= 2010 && details['iyr'].to_i <= 2020
  end

  def valid_eyr
    return false unless details['eyr'].match? /^\d{4}$/

    details['eyr'].to_i >= 2020 && details['eyr'].to_i <= 2030
  end

  def valid_hgt
    return false unless details['hgt'].match? /^\d+(cm|in)$/

    if details['hgt'].match? /cm$/
      height = details['hgt'].match(/^(?<value>\d+)cm$/)
      height = height[:value].to_i
      return height >= 150 && height <= 193
    end
    if details['hgt'].match? /in$/
      height = details['hgt'].match(/^(?<value>\d+)in$/)
      height = height[:value].to_i
      return height >= 59 && height <= 76
    end
  end

  def valid_hcl
    details['hcl'].match? /^#[0-9a-f]{6}$/
  end

  def valid_ecl
    details['ecl'].match? /^(amb|blu|brn|gry|grn|hzl|oth)$/
  end

  def valid_pid
    details['pid'].match? /^\d{9}$/
  end
end

class PassportProcessor
  attr_reader :passports_list
  
  def initialize(batch_data)
    passports_as_strings = get_passport_data_string_list(batch_data)
    @passports_list = get_passports(passports_as_strings)
  end

  def count_passports_with_mandatory_fields
    passports_list.count(&:has_all_mandatory_fields)
  end

  def count_valid_passports
    passports_list.count do |passport|
      passport.has_all_mandatory_fields &&
        passport.valid_byr &&
        passport.valid_iyr &&
        passport.valid_eyr &&
        passport.valid_hgt &&
        passport.valid_hcl &&
        passport.valid_ecl &&
        passport.valid_pid
    end
  end

  private

  def get_passport_data_string_list(batch_data)
    passport_data = []
    passport = []
    batch_data.each do |line|
      if line.empty?
        passport_data << passport.join(' ')
        passport = []
      else
        passport << line
      end
    end
    passport_data << passport.join(' ')
  end

  def get_passports(passports_as_strings)
    passports_as_strings.map do |info_space_separated|
      passport_information = {}
      info_list = info_space_separated.split
      info_list.each do |info|
        passport_field = info.match(/(?<field_name>\w+):(?<field_value>#?\w+)/)
        passport_information[passport_field[:field_name]] = passport_field[:field_value]
      end
      Passport.new(passport_information)
    end
  end
end

batch_data = File.new('day4_input.txt').readlines.map(&:chomp)
processor = PassportProcessor.new(batch_data)
num_passports_with_correct_fields = processor.count_passports_with_mandatory_fields
puts num_passports_with_correct_fields
num_valid_passports = processor.count_valid_passports
puts num_valid_passports