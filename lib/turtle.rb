class Canvas
  attr_reader :size

  VISITED = 'X'
  UNVISITED = '.'
  
  def initialize(size)
    @size = size
    
    @canvas = Array.new(@size).map! { Array.new(@size, UNVISITED) }
  end
  
  def to_s
    result = @canvas.map { |row|
      row.map { |cell|
        cell.to_s
      }.join " "
    }.join "\n"
    
    "#{result}\n"
  end
  
  def visit(x, y)
    @canvas[y][x] = VISITED
  end
  
end

class Turtle
  attr_reader :degrees
  
  def initialize(canvas)
    @canvas = canvas
    
    @x = @y = @canvas.size/2
    @canvas.visit @x, @y
    
    @degrees = 0
  end
  
  def forward(steps)
    offset_x, offset_y = degrees_to_offset @degrees
    
    steps.times {
      @x += offset_x
      @y += offset_y
      
      @canvas.visit @x, @y
    }    
  end
  
  def backward(steps)
    offset_x, offset_y = degrees_to_offset @degrees
    
    steps.times {
      @x -= offset_x
      @y -= offset_y
      
      @canvas.visit @x, @y
    }
  end
  
  def left(degrees)
    @degrees = (@degrees + degrees) % 360
  end
  
  def right(degrees)
    @degrees = (@degrees - degrees) % 360    
  end
  
  private
  def degrees_to_offset(degrees)
    if degrees > 180
      x, y = degrees_to_offset(360 - degrees)
      return [-x, y]
    end
    
    case degrees
    when 0 
      [0, -1]
    when 45 
      [-1, -1]
    when 90 
      [-1, 0]
    when 135 
      [-1, 1]
    when 180 
      [0, 1]
    end
  end
end

class Parser
  def initialize
    
  end
  
  class << self
    attr_accessor :command_classes
    
    def register_command(name, command_class)
      @command_classes ||= {}
      @command_classes[name] = command_class
    end
    
    def parse(description, args = {})
      canvas_class = args.delete(:canvas_class) || Canvas
      turtle_class = args.delete(:turtle_class) || Turtle

      p = Parser.new
      description.gsub! /s+/, ' '
      commands = description.split.reverse
      size = commands.pop.to_i
      
      canvas = canvas_class.new size      
      turtle = turtle_class.new canvas
      
      operations = []
      until commands.empty?
        next_command = commands.pop
        operations << (@command_classes[next_command].create commands, @command_classes)
      end

      operations.each { |operation| operation.run turtle }
      
      canvas.to_s
    end
  end
end

class RepeatOperation
  class << self
    def create(commands, command_classes)
      number_of_repeats = commands.pop.to_i
      commands.pop
      operations = []
      
      until (next_command = commands.pop) == ']'
        operations << (command_classes[next_command].create commands, command_classes)        
      end
      
      RepeatOperation.new number_of_repeats, operations
    end
  end
  
  def initialize(number_of_repeats, operations)
    @number_of_repeats = number_of_repeats
    @operations = operations
  end
  
  def run(turtle)
    @number_of_repeats.times {
      @operations.each { |operation| operation.run turtle }
    }
  end
end

Parser.register_command "REPEAT", RepeatOperation

class MoveOperation  
  class << self
    def create(commands, command_classes)
      steps = commands.pop.to_i
      self.new steps
    end
  end
  
  def initialize(steps)
    @steps = steps
  end
  
  def run(turtle)
    turtle.send(self.class.move, @steps) 
  end
end

def create_move_operation(direction)
  class_name = "#{direction.to_s.capitalize}Operation"
  klass = Object.const_set(class_name, Class.new(MoveOperation))
  
  module_name = "#{direction.to_s.capitalize}Module"
  module_object = Object.const_set(module_name, Module.new)
  
  module_object.class_exec do
    define_method(:move) do
      direction
    end
  end
  
  klass.extend module_object

  klass
end

Parser.register_command "FD", (create_move_operation :forward)
Parser.register_command "BK", (create_move_operation :backward)
Parser.register_command "LT", (create_move_operation :left)
Parser.register_command "RT", (create_move_operation :right)
