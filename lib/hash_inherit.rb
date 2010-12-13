module HashInherit
	attr_accessor :inherit_from
	def inherit_from(a=nil)
		@inherit_from = a
		self.default_proc = lambda{ |h,k| @inherit_from && @inherit_from[k] }
	end
	def self.from(parent,child)
		child.extend self
		child.inherit_from parent
	end
end