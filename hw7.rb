# University of Washington, Programming Languages, Homework 7, hw7.rb 
# (See also ML code)

# a little language for 2D geometry objects

# each subclass of GeometryExpression, including subclasses of GeometryValue,
#  needs to respond to messages preprocess_prog and eval_prog
#
# each subclass of GeometryValue additionally needs:
#   * shift
#   * intersect, which uses the double-dispatch pattern
#   * intersectPoint, intersectLine, and intersectVerticalLine for 
#       for being called by intersect of appropriate clases and doing
#       the correct intersection calculuation
#   * (We would need intersectNoPoints and intersectLineSegment, but these
#      are provided by GeometryValue and should not be overridden.)
#   *  intersectWithSegmentAsLineResult, which is used by 
#      intersectLineSegment as described in the assignment
#
# you can define other helper methods, but will not find much need to

# Note: geometry objects should be immutable: assign to fields only during
#       object construction

# Note: For eval_prog, represent environments as arrays of 2-element arrays
# as described in the assignment

class GeometryExpression  
  # do *not* change this class definition
  Epsilon = 0.00001
end

class GeometryValue 
  # do *not* change methods in this class definition
  # you can add methods if you wish

  private
  # some helper methods that may be generally useful
  def real_close(r1,r2) 
      (r1 - r2).abs < GeometryExpression::Epsilon
  end
  def real_close_point(x1,y1,x2,y2) 
      real_close(x1,x2) && real_close(y1,y2)
  end
  # two_points_to_line could return a Line or a VerticalLine
  def two_points_to_line(x1,y1,x2,y2) 
      if real_close(x1,x2)
        VerticalLine.new x1
      else
        m = (y2 - y1).to_f / (x2 - x1)
        b = y1 - m * x1
        Line.new(m,b)
      end
  end

  public
  # we put this in this class so all subclasses can inherit it:
  # the intersection of self with a NoPoints is a NoPoints object
  def intersectNoPoints np
    np # could also have NoPoints.new here instead
  end

  # we put this in this class so all subclasses can inhert it:
  # the intersection of self with a LineSegment is computed by
  # first intersecting with the line containing the segment and then
  # calling the result's intersectWithSegmentAsLineResult with the segment
  def intersectLineSegment seg
    line_result = intersect(two_points_to_line(seg.x1,seg.y1,seg.x2,seg.y2))
    line_result.intersectWithSegmentAsLineResult seg
  end
end

class NoPoints < GeometryValue
  # do *not* change this class definition: everything is done for you
  # (although this is the easiest class, it shows what methods every subclass
  # of geometry values needs)

  # Note: no initialize method only because there is nothing it needs to do
  def eval_prog env 
    self # all values evaluate to self
  end
  def preprocess_prog
    self # no pre-processing to do here
  end
  def shift(dx,dy)
    self # shifting no-points is no-points
  end
  def intersect other
    other.intersectNoPoints self # will be NoPoints but follow double-dispatch
  end
  def intersectPoint p
    self # intersection with point and no-points is no-points
  end
  def intersectLine line
    self # intersection with line and no-points is no-points
  end
  def intersectVerticalLine vline
    self # intersection with line and no-points is no-points
  end
  # if self is the intersection of (1) some shape s and (2) 
  # the line containing seg, then we return the intersection of the 
  # shape s and the seg.  seg is an instance of LineSegment
  def intersectWithSegmentAsLineResult seg
    self
  end
end


class Point < GeometryValue
  attr_reader :x, :y
  def initialize(x,y)
    @x = x
    @y = y
  end

  def eval_prog env
	self
  end

  def preprocess_prog
	self
  end

  def shift(dx,dy)
	Point.new(x+dx,y+dy)
  end

  def intersect other
	other.intersectPoint self
  end

  def intersectPoint point
  	if real_close_point(x,y,point.x,point.y)
	  self
	else
	  NoPoints.new
	end
  end

  def intersectLine line
  	if real_close(y,line.m*x+line.b)
	  self
	else
	  NoPoints.new
	end
  end

  def intersectVerticalLine vline
  	if real_close(x,vline.x)
	  self
	else
	  NoPoints.new
	end
  end
  
  def intersectWithSegmentAsLineResult seg
  	if real_close_point(x,y,seg.x1,seg.y1) or real_close_point(x,y,seg.x2,seg.y2)
		self
	end

	seg_ = seg.preprocess_prog
	if real_close(seg_.x1,seg_.x2)
	  if y>= seg_.y1 and y<=seg_.y2
		self
	  else
		NoPoints.new
	  end
	else
	  if x>= seg_.x1 and x<=seg_.x2
		self
	  else
		NoPoints.new
	  end
	end

  end

end


class Line < GeometryValue
  attr_reader :m, :b 
  def initialize(m,b)
    @m = m
    @b = b
  end

  def eval_prog env
	self
  end

  def preprocess_prog
	self
  end

  def shift(dx,dy)
  	Line.new(m,b+dy-m*dx)
  end

  def intersect other
	other.intersectLine self
  end
 
  def intersectPoint point
  	point.intersectLine self
  end

  def intersectLine line
  	if real_close(m,line.m)
	  if real_close(b,line.b)
		self
	  else
		NoPoints.new
	  end
	else
	  x = -(b-line.b)/(m-line.m)
	  y = m*x+b
	  Point.new(x,y)
	end
  end
  
  def intersectVerticalLine vline
	Point.new(vline.x,m*vline.x+b)
  end
   
   
  def intersectWithSegmentAsLineResult seg
    seg
  end
 
end

class VerticalLine < GeometryValue
  attr_reader :x
  def initialize x
    @x = x
  end
  def eval_prog env
	self
  end

  def preprocess_prog
	self
  end

  def shift(dx,dy)
  	VerticalLine.new(x+dx)
  end

  def intersect other
	other.intersectVerticalLine self
  end
  
  def intersectPoint point
  	point.intersectVerticalLine self
  end

  def intersectLine line
	line.intersectVerticalLine self
  end

  def intersectVerticalLine vline
	if real_close(x,vline.x)
	  self
	else
	  NoPoints.new
	end
  end
   
  def intersectWithSegmentAsLineResult seg
	seg
  end
 
end

class LineSegment < GeometryValue
  attr_reader :x1, :y1, :x2, :y2
  public

  def initialize (x1,y1,x2,y2)
    @x1 = x1
    @y1 = y1
    @x2 = x2
    @y2 = y2
  end
  def eval_prog env
	self
  end

  private


  def intersectInterval(i1,i2)
	left = [i1[0],i2[0]].max
	right = [i1[1],i2[1]].min
	if right>left
		[left,right]
	else
		nil
	end
  end


  def cmp(x1,y1,x2,y2)
	if not real_close(x1,x2) 
	  x1<x2
	else
	  if not real_close(y1,y2)
	    y1<y2
	  else
		false
	  end
    end
  end

  public

  def preprocess_prog
  	if real_close_point(x1,y1,x2,y2)
		Point.new(x1,y1)
	else
		if cmp(x1,y1,x2,y2)
			self
		else
			LineSegment.new(x2,y2,x1,y1)
		end
	end
  end

  def shift(dx,dy)
	LineSegment.new(x1+dx,y1+dy,x2+dx,y2+dy)
  end

  def intersect other
	other.intersectLineSegment self
  end

  def intersectPoint point
  	point.intersectLineSegment self
  end

  def intersectLine line
	line.intersectLineSegment self
  end

  def intersectVerticalLine vline
	vline.intersectLineSegment self
  end
   
  def intersectWithSegmentAsLineResult seg
	#the segment lies on the same line (hard case)
	seg1 = self.preprocess_prog
	seg2 = seg.preprocess_prog
	vert = false

	if real_close(seg1.x1,seg1.x2)
		vert = false
	end
	#reduce segment into intervals
	if vert
		p1 = [seg1.y1,seg1.y2]
		p2 = [seg2.y1,seg2.y2]
	else
		p1 = [seg1.x1,seg1.x2]
		p2 = [seg2.x1,seg2.x2]
	end
	ic = intersectInterval(p1,p2)
	if ic.nil?
		NoPoints.new()
	else
		if vert
		  LineSegment.new(seg1.x1,ic[0],seg1.x1,ic[1]).preprocess_prog
		else
		  line = two_points_to_line(seg1.x1,seg1.y1,seg1.x2,seg1.y2)
		  LineSegment.new(ic[0],line.m*ic[0]+line.b,ic[1],line.m*ic[1]+line.b).preprocess_prog
		end
	end
  end
end


# Note: there is no need for getter methods for the non-value classes

class Intersect < GeometryExpression
  def initialize(e1,e2)
    @e1 = e1
    @e2 = e2
  end

  def eval_prog env
  	v1 = @e1.eval_prog(env)
	v2 = @e2.eval_prog(env)
	v1.intersect(v2)
  end
  
  def preprocess_prog
  	Intersect.new(@e1.preprocess_prog(),@e2.preprocess_prog())
  end
end

class Let < GeometryExpression
  def initialize(s,e1,e2)
    @s = s
    @e1 = e1
    @e2 = e2
  end

  def eval_prog env
	v1 = @e1.eval_prog env
	new_env = [[@s,v1]] + env
  	@e2.eval_prog new_env
  end
  
  def preprocess_prog
	Let.new(@s,@e1.preprocess_prog(),@e2.preprocess_prog())
  end
end

class Var < GeometryExpression
  def initialize s
    @s = s
  end
  def eval_prog env # remember: do not change this method
    pr = env.assoc @s
    raise "undefined variable" if pr.nil?
    pr[1]
  end

  def preprocess_prog
	self
  end
end

class Shift < GeometryExpression
  def initialize(dx,dy,e)
    @dx = dx
    @dy = dy
    @e = e
  end

  def preprocess_prog
	Shift.new(@dx,@dy,@e.preprocess_prog)
  end

  def eval_prog env
	v = @e.eval_prog env 
	v.shift(@dx,@dy)
  end
end
