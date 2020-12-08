class ProgramRunner
  attr_accessor :accumulator
  attr_reader :program

  def initialize(raw_program)
    @program = raw_program.map { |loc| parse_line(loc) }
    @accumulator = 0
  end

  def run_and_reset
    program_end_state = run
    program_end_state[:acc_val] = accumulator
    self.accumulator = 0
    return program_end_state
  end

  def fix_single_jmp_nop_swap_error
    program.each_index do |line_number|
      swap_jmp_nop(line_number)
      end_state = run_and_reset
      swap_jmp_nop(line_number)
      if end_state[:terminates]
        end_state[:fixed_line] = line_number
        return end_state
      end
    end
    return {
      error: 'Cannot be fixed with a single jmp/nop swap!'
    }
  end

  def run
    already_ran = Array.new(program.length, false)
    status = {}
    current_instruction = 0
    while current_instruction < program.length
      if already_ran[current_instruction]
        status[:terminates] = false
        return status
      else
        already_ran[current_instruction] = true
      end

      status[:last_instruction] = current_instruction
      current_instruction = execute_instruction_and_get_next(current_instruction)
    end
    status[:terminates] = true
    return status
  end

  private

  def parse_line(line)
    instruction = line.match(/(?<operation>(\w+)) (?<argument>(\+|-)\d+)/)
    {
      operation: instruction[:operation],
      argument: instruction[:argument].to_i
    }
  end

  def execute_instruction_and_get_next(line_number)
    if program[line_number][:operation].match? /acc/
      self.accumulator += program[line_number][:argument]
      return line_number + 1
    elsif program[line_number][:operation].match? /jmp/
      return line_number + program[line_number][:argument]
    elsif program[line_number][:operation].match? /nop/
      return line_number + 1
    end
  end

  def swap_jmp_nop(line_number)
    instruction = program[line_number]
    if instruction[:operation].match? /jmp/
      instruction[:operation] = 'nop'
    elsif instruction[:operation].match? /nop/
      instruction[:operation] = 'jmp'
    end
  end
end

program = File.new('day8_input.txt').readlines.map(&:chomp)
computer = ProgramRunner.new(program)
puts computer.run_and_reset
puts computer.fix_single_jmp_nop_swap_error
