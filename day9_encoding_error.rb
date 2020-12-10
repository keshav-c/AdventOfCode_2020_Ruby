class XMASDecoder
  attr_reader :input_sequence, :preamble_length
  
  def initialize(sequence, preamble_length:)
    @input_sequence = sequence
    @preamble_length = preamble_length
  end

  def get_first_error
    preamble = input_sequence[0...preamble_length]
    data = input_sequence[preamble_length..-1]
    data.each.with_index do |sample, offset_index|
      if valid_sample? sample, preamble
        preamble.shift 
        preamble << sample
      else
        return {
          value: sample, 
          index: preamble_length + offset_index
        }
      end
    end
  end

  def get_weakness
    target, target_index = get_first_error.values_at(:value, :index)
    subarray = get_subarray_summing_to_val(val: target, search_limit: target_index)
    return subarray.max + subarray.min
  end

  def valid_sample? sample, preamble
    preamble.combination(2).any? do |preamble_sample1, preamble_sample2|
      preamble_sample1 + preamble_sample2 == sample
    end
  end

  def get_subarray_summing_to_val(val:, search_limit:)
    (0...search_limit).each do |subarray_start|
      sum = 0
      (subarray_start...search_limit).each do |subarray_end|
        sum += input_sequence[subarray_end]
        return input_sequence[subarray_start..subarray_end] if sum == val
      end
    end
  end
end

sequence = File.new('day9_input.txt').readlines.map(&:to_i)
decoder = XMASDecoder.new(sequence, preamble_length: 25)
puts decoder.get_first_error
puts decoder.get_weakness
