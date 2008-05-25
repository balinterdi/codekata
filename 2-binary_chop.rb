require 'test/unit'

def chop_iter(elt, array)
  return -1 if array.empty?
  low_signpost_idx = 0
  high_signpost_idx = array.length - 1
  while low_signpost_idx != high_signpost_idx
    if array[low_signpost_idx] > elt || array[high_signpost_idx] < elt
      return -1
    end        
    signpost_idx = (high_signpost_idx + low_signpost_idx) / 2
    signpost = array[signpost_idx]
    return signpost_idx if signpost == elt
    if signpost > elt
      high_signpost_idx = signpost_idx - 1
    else
      low_signpost_idx = signpost_idx + 1
    end
  end
  return low_signpost_idx if array[low_signpost_idx] == elt
  return -1
end

def chop_rec(elt, array)
  return -1 if array.empty?
  if array.length == 1
    if array.first == elt
      return 0
    else
      return -1
    end
  end
  signpost_idx = array.length / 2
  signpost = array[signpost_idx]
  return signpost_idx if signpost == elt
  if signpost > elt
    idx = chop_rec(elt, array[0...signpost_idx])
    if idx != -1
      return idx
    else
      return -1
    end
  else
    idx = chop_rec(elt, array[(signpost_idx+1)...array.length])
    if idx != -1
      return (signpost_idx + 1) + idx
    else
      return -1
    end
  end
end

def chop(elt, array)
  chop_iter(elt, array)
  #chop_rec(elt, array)
end

if __FILE__ == $0
  class ModuleTester < Test::Unit::TestCase
    def test_chop
      assert_equal(-1, chop(3, []))
      assert_equal(-1, chop(3, [1]))
      assert_equal(0,  chop(1, [1]))
      #
      assert_equal(0,  chop(1, [1, 3, 5]))
      assert_equal(1,  chop(3, [1, 3, 5]))
      assert_equal(2,  chop(5, [1, 3, 5]))
      assert_equal(-1, chop(0, [1, 3, 5]))
      assert_equal(-1, chop(2, [1, 3, 5]))
      assert_equal(-1, chop(4, [1, 3, 5]))
      assert_equal(-1, chop(6, [1, 3, 5]))
      #
      assert_equal(0,  chop(1, [1, 3, 5, 7]))
      assert_equal(1,  chop(3, [1, 3, 5, 7]))
      assert_equal(2,  chop(5, [1, 3, 5, 7]))
      assert_equal(3,  chop(7, [1, 3, 5, 7]))
      assert_equal(-1, chop(0, [1, 3, 5, 7]))
      assert_equal(-1, chop(2, [1, 3, 5, 7]))
      assert_equal(-1, chop(4, [1, 3, 5, 7]))
      assert_equal(-1, chop(6, [1, 3, 5, 7]))
      assert_equal(-1, chop(8, [1, 3, 5, 7]))
    end
  end
end