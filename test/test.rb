require 'rubygems'
gem 'minitest'

require 'minitest/autorun'
require 'mocha'

require 'lib/turtle'

require 'pry'

class TestCanvas < MiniTest::Unit::TestCase
  def test_canvas_size
    c = Canvas.new 3
    assert_equal c.size, 3, "Canvas should be of given size"
  end

  def test_canvas_to_s
    c = Canvas.new 3
    assert_equal c.to_s, ". . .\n. . .\n. . .\n", "Canvas should be visualized correctly"
  end
  
  def test_visit
    c = Canvas.new 3
    c.visit 1, 1
    assert_equal c.to_s, ". . .\n. X .\n. . .\n", "Visiting the cavas should yield correct output"
    c.visit 0, 2  
    assert_equal c.to_s, ". . .\n. X .\nX . .\n", "Visiting the cavas should yield correct output and retain old visitations"
  end
end

class TestTurtle < MiniTest::Unit::TestCase
  def setup
    @canvas_mock = mock()

    @canvas_mock.stubs(:size).returns(7)
    @canvas_mock.stubs(:visit).with(3, 3)
  end
  
  def test_initialize
    @canvas_mock.expects(:visit).with(3, 3).once
    
    t = Turtle.new @canvas_mock
  end
  
  def test_forward_once
    @canvas_mock.expects(:visit).with(3, 2).once

    t = Turtle.new @canvas_mock
    t.forward 1
  end
  
  def test_forward_twice
    @canvas_mock.expects(:visit).with(3, 2).once
    @canvas_mock.expects(:visit).with(3, 1).once

    t = Turtle.new @canvas_mock
    t.forward 2
    
  end
  
  def test_backward_once
    @canvas_mock.expects(:visit).with(3, 4).once
    
    t = Turtle.new @canvas_mock
    t.backward 1
  end
  
  def test_backward_twice
    @canvas_mock.expects(:visit).with(3, 4).once
    @canvas_mock.expects(:visit).with(3, 5).once

    t = Turtle.new @canvas_mock
    t.backward 2
  end
  
  def test_left_once_move_once
    @canvas_mock.expects(:visit).with(2, 2).once
    
    t = Turtle.new @canvas_mock
    t.left 45
    t.forward 1
  end
  
  def test_left_once_move_twice
    @canvas_mock.expects(:visit).with(2, 2).once
    @canvas_mock.expects(:visit).with(1, 1).once
    
    t = Turtle.new @canvas_mock
    t.left 45
    t.forward 2
  end
  
  def test_left_twice_move_once
    @canvas_mock.expects(:visit).with(2, 3).once
    
    t = Turtle.new @canvas_mock
    t.left 45
    t.left 45
    t.forward 1
  end
  
  def test_right_once_move_once
    @canvas_mock.expects(:visit).with(4, 3).once
    
    t = Turtle.new @canvas_mock
    t.right 90
    t.forward 1
  end
  
  def test_right_once_move_twice
    @canvas_mock.expects(:visit).with(4, 2).once
    @canvas_mock.expects(:visit).with(5, 1).once
    
    t = Turtle.new @canvas_mock
    t.right 45
    t.forward 2
  end
  
  def test_right_twice_move_once
    @canvas_mock.expects(:visit).with(4, 3).once
    
    t = Turtle.new @canvas_mock
    t.right 45
    t.right 45
    t.forward 1
  end
  
  def test_left_right_move
      @canvas_mock.expects(:visit).with(3, 2).once
      
      t = Turtle.new @canvas_mock
      t.left 90
      t.right 45
      t.right 45
      t.forward 1
  end
  
  def test_left_over_half
    @canvas_mock.expects(:visit).with(4, 4).once
    
    t = Turtle.new @canvas_mock
    t.left 225
    t.forward 1
  end
  
  def test_right_over_half
    @canvas_mock.expects(:visit).with(2, 3).once
    
    t = Turtle.new @canvas_mock
    t.right 270
    t.forward 1
  end
end

class TestParser < MiniTest::Unit::TestCase 
  def test_canvas_creation
    canvas_mock = mock()
    canvas_mock.stubs(:size).returns(7)
    canvas_mock.stubs(:visit)
    
    canvas_class_mock = mock()
    canvas_class_mock.expects(:new).with(7).returns(canvas_mock).once

    Parser.parse "7\n\n", :canvas_class => canvas_class_mock    
  end
  
  def test_turtle_forward_once
    turtle_mock = mock()
    turtle_mock.expects(:forward).with(1).once
    
    turtle_class_mock = mock()
    turtle_class_mock.expects(:new).returns(turtle_mock).once
    
    canvas = Parser.parse "7\n\nFD 1", :turtle_class => turtle_class_mock
  end
  
  def test_turtle_forward_twice
    turtle_mock = mock()
    turtle_mock.expects(:forward).with(2).once
    
    turtle_class_mock = mock()
    turtle_class_mock.expects(:new).returns(turtle_mock).once
    
    canvas = Parser.parse "7\n\nFD 2", :turtle_class => turtle_class_mock
  end
  
  def test_turtle_multiple_same_commands
    turtle_mock = mock()
    turtle_mock.expects(:forward).with(1).once
    turtle_mock.expects(:forward).with(2).once
    
    turtle_class_mock = mock()
    turtle_class_mock.expects(:new).returns(turtle_mock).once
    
    canvas = Parser.parse "7\n\nFD 1\nFD 2", :turtle_class => turtle_class_mock
  end
  
  def test_turtle_backward_once
    turtle_mock = mock()
    turtle_mock.expects(:backward).with(1).once
    
    turtle_class_mock = mock()
    turtle_class_mock.expects(:new).returns(turtle_mock).once
    
    canvas = Parser.parse "7\n\nBK 1", :turtle_class => turtle_class_mock
  end
  
  def test_turtle_forward_twice
    turtle_mock = mock()
    turtle_mock.expects(:backward).with(2).once
    
    turtle_class_mock = mock()
    turtle_class_mock.expects(:new).returns(turtle_mock).once
    
    canvas = Parser.parse "7\n\nBK 2", :turtle_class => turtle_class_mock
  end
  
  def test_turtle_multiple_different_commands
    turtle_mock = mock()
    turtle_mock.expects(:forward).with(2).once
    turtle_mock.expects(:backward).with(1).once
    
    turtle_class_mock = mock()
    turtle_class_mock.expects(:new).returns(turtle_mock).once
    
    canvas = Parser.parse "7\n\nFD 2\nBK 1", :turtle_class => turtle_class_mock
  end
  
  def test_turtle_turn_left
    turtle_mock = mock()
    turtle_mock.expects(:left).with(45).once

    turtle_class_mock = mock()
    turtle_class_mock.expects(:new).returns(turtle_mock).once

    canvas = Parser.parse "7\n\nLT 45", :turtle_class => turtle_class_mock
  end
  
  def test_turtle_turn_right
    turtle_mock = mock()
    turtle_mock.expects(:right).with(45).once

    turtle_class_mock = mock()
    turtle_class_mock.expects(:new).returns(turtle_mock).once

    canvas = Parser.parse "7\n\nRT 45", :turtle_class => turtle_class_mock
  end
  
  def test_repeat_one_command
    turtle_mock = mock()
    turtle_mock.expects(:forward).with(1).twice

    turtle_class_mock = mock()
    turtle_class_mock.expects(:new).returns(turtle_mock).once

    canvas = Parser.parse "7\n\nREPEAT 2 [ FD 1 ]", :turtle_class => turtle_class_mock
  end
  
  def test_repeat_multiple_command
    turtle_mock = mock()
    turtle_mock.expects(:forward).with(1).twice
    turtle_mock.expects(:backward).with(1).twice
    

    turtle_class_mock = mock()
    turtle_class_mock.expects(:new).returns(turtle_mock).once

    canvas = Parser.parse "7\n\nREPEAT 2 [ FD 1 BK 1 ]", :turtle_class => turtle_class_mock
  end
end

class IntegrationTest < MiniTest::Unit::TestCase
  def test_simple_logo
    logo_code = File.open("simple.logo").read
    expected_output = File.open("simple_out.txt").read
    output = Parser.parse logo_code
    
    assert_equal output, expected_output
  end
  
  def test_example
    logo_code = "11

      RT 90
      FD 5
      RT 135
      FD 5"
      
    expected_output = ". . . . . . . . . . .
. . . . . . . . . . .
. . . . . . . . . . .
. . . . . . . . . . .
. . . . . . . . . . .
. . . . . X X X X X X
. . . . . . . . . X .
. . . . . . . . X . .
. . . . . . . X . . .
. . . . . . X . . . .
. . . . . X . . . . .
"

    output = Parser.parse logo_code
    assert_equal output, expected_output
  end
end