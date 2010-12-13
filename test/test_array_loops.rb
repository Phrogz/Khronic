require_relative 'helper'

class TestArrayLoops < MT
	def test_evens
		@digits = *0..9
		@digits.extend ArrayLoops

		assert_equal [0,1,2,3], @digits.loop(         for:4 )
		assert_equal [0,1,2,3], @digits.loop( from:0, for:4 )
		assert_equal [3,4,5,6], @digits.loop( from:3, for:4 )
		assert_equal [8,9],     @digits.loop( from:8, for:2 )
		assert_equal [9,0],     @digits.loop( from:9, for:2 )

		wrap1 = [8,9] + @digits + [0,1,2]
		assert_equal wrap1, @digits.loop( from:8, for:15 )
		wrap2 = [8,9] + @digits + @digits + [0,1,2]
		assert_equal wrap2, @digits.loop( from:8, for:25 )
	end
	
	def test_odds
		@odds   = [1,3,5,7,9]
		@odds.extend ArrayLoops
		
		assert_equal [1,3,5,7,9], @odds.loop(         for:5 )
		assert_equal [7,9],       @odds.loop( from:3, for:2 )
		assert_equal [9,1],       @odds.loop( from:4, for:2 )
		
		wrap1 = [7,9] + @odds + [1,3]
		assert_equal wrap1, @odds.loop( from:3, for:9 )

		wrap2 = [7,9] + @odds + @odds + [1,3]
		assert_equal wrap2, @odds.loop( from:3, for:14 )
	end
	
	def test_bounds
		@a = (0..9).to_a
		@a.extend ArrayLoops
		
		assert_equal [0,1,2], @a.loop( from:0,   for:3 )
		assert_equal [0,1,2], @a.loop( from:10,  for:3 )
		assert_equal [0,1,2], @a.loop( from:100, for:3 )
	end
end