module CacheTree

	class Vec2 
    	EPSILON = 0.001

    	def initialize(vec) # constructor de copia
        	@x = vec.x
        	@y = vec.y
    	end

		def initialize(x, y)
			@x = x
			@y = y
		end

		def x
			@x
		end

		def y
			@y
		end

    	def == val
        	(@x == val.x) && (@y == val.y)
    	end

    	def between? (min, max) #min := Vec2; max := Vec2
        	(max.x >= @x) && (max.y >= @y) && (min.x <= @x) && (min.y <= @y)
    	end

    	def equ? val
        	((@x-val.x).abs / (@x.abs + val.x.abs) < EPSILON) && ((@y-val.y).abs / (@y.abs + val.y.abs) < EPSILON)
    	end

    	def x= val
        	@x = val
    	end

    	def y= val
        	@y = val
    	end
	end

	class Node 
        # @vec := Vec2
        # @left := Node
        # @right := Node
        # @exists := bool

        def initialize (vec, left = nil, right = nil)
            @vec = vec
            @left = left
            @right = right
            @exists = true
        end

        def exists?
            @exists
        end

        def delete
            @exists = false
        end

        def vec 
            @vec
        end

        def left
            @left
        end

        def right
            @right
        end

        def vec= val
            @vec = val
        end

        def left= val
            @left = val
        end

        def right= val
            @right = val
        end
    end

	class Tree
    	include Enumerable

    	# @root := Node
    	def initialize (array)
        	@root = build(0, array)
    	end

    	#@temp := Vec2[]
    	def to_a 
        	@temp = []
        	_each @root
        	@temp
    	end

    	def each #yields := Vec2
        	self.to_a.each { |v| yield v }
    	end

    	# @minP := Vec2
    	# @minDistance := float
    	def closest (vec) #vec := Vec2
        	@minP = @root.vec
        	@minDistance = distance(@minP, vec)
        	_closest(0, @root, vec)
        	@minP
    	end

    	def indexed? (vec) #vec := Vec2; returns := bool
        	closest(vec) == vec
    	end

    	def delete? (vec) #vec := Vec2; returns := bool
        	_delete?(0, @root, vec)
    	end

    	#@found := Vec2[]
    	def rangeSearch (min, max) #returns := Vec2[]; a := Vec2; b := Vec2
        	@found = []
        	_rangeSearch(0, @root, min, max)
        	@found
    	end

    	def add (vec) #vec := Vec2
        	_add(0, @root, vec)
    	end

		private

    	def _delete? (depth, subtree, vec) #depth := int; subtree := Node; vec := Vec2; returns := bool
        	if subtree.vec == vec
            	subtree.delete
            	return true;
        	end

        	if depth % 2 == 0
            	cmp, cmpVal = subtree.vec.x, vec.x
        	else
            	cmp, cmpVal = subtree.vec.y, vec.y
        	end

        	if cmp > cmpVal
            	prox = subtree.right
        	else
            	prox = subtree.left
        	end

        	return false if prox == nil
        	_delete?(depth+1, prox, vec)
    	end


    	def _rangeSearch (depth, subtree, min, max) #depth := int; subtree := Node; min := Vec2; max := Vec2
        	if depth % 2 == 0
            	cmp, cmpMin, cmpMax = subtree.vec.x, min.x, max.x
        	else
            	cmp, cmpMin, cmpMax = subtree.vec.y, min.y, max.y
        	end

        	if ((cmp > cmpMin) && (cmp > cmpMax))
            	_rangeSearch(depth+1, subtree.right, min, max) if subtree.right != nil
        	elsif ((cmp > cmpMin) && (cmp < cmpMax))
            	_rangeSearch(depth+1, subtree.right, min, max) if subtree.right != nil
            	_rangeSearch(depth+1, subtree.left, min, max) if subtree.left != nil
        	elsif ((cmp < cmpMin) && (cmp < cmpMax))
            	_rangeSearch(depth+1, subtree.left, min, max) if subtree.left != nil
        	end
            
        	@found << subtree.vec if subtree.vec.between?(min, max) && subtree.exists?
    	end

    	def _closest (depth, subtree, vec) #depth := int; subtree := Node; vec := Vec2
        	if vec.equ?(subtree.vec) && subtree.exists?
            	@minP = vec
            	@minDistance = 0
        	else
            	dist = distance(vec, subtree.vec)
            	@minDistance, @minP = dist, subtree.vec if (dist < @minDistance) && subtree.exists?

            	if depth % 2 == 0
                	cmp, cmpVal = subtree.vec.x, vec.x
            	else
                	cmp, cmpVal = subtree.vec.y, vec.y
            	end

            	if cmp > cmpVal
                	prox = subtree.right
            	else
                	prox = subtree.left
            	end

            	return if prox == nil

            	_closest(depth+1, prox, vec)
        	end
    	end
    
    	def distance (a, b) # a := Vec2; b := Vec2; returns := float
        	Math.sqrt( ((b.x-a.x)**2) + ((b.y-a.y)**2) )
    	end
    
    	def _add (depth, subtree, vec) #depth := int; subtree := Node; vec := Vec2
        	if depth % 2 == 0
            	cmp, cmpVal = subtree.vec.x, vec.x
        	else
            	cmp, cmpVal = subtree.vec.y, vec.y
        	end

        	if cmpVal < cmp
            	if subtree.right == nil
                	subtree.right = Node.new vec
                	return
            	else
                	prox = subtree.right
            	end
        	else
            	if subtree.left == nil
                	subtree.left = Node.new vec
                	return
            	else
                	prox = subtree.left
            	end
        	end
        	_add(depth+1, prox, vec)
    	end

    	def _each (sub) #yields := Vec2; sub := node
        	_each sub.right if sub.right != nil
        	_each sub.left if sub.left != nil
        	@temp << sub.vec if sub.exists?
    	end

    	def build (depth, array) #returns Node; array := Vec2; depth := int
        	return Node.new( array[0] ) if array.length == 1 #si es Leaf Node

        	if depth % 2 == 0
            	sortByX! array
        	else
            	sortByY! array
        	end

        	mid = array.length / 2

        	n = Node.new array[mid]

        	rights = array[ (0..(mid-1)) ]
        	lefts = array[ (mid+1)...(array.length) ]

        	n.right = build(depth+1, rights) if rights.length > 0
        	n.left = build(depth+1, lefts) if lefts.length > 0
        	n
    	end

    	def sortByX! (array) #array := Vec2; inplace quicksort
        	array.sort! { |a, b| a.x <=> b.x } 
    	end

    	def sortByY! (array) #array := Vec2; inplace quicksort
        	array.sort! {|a, b| a.y <=> b.y } 
    	end
	end
	
end