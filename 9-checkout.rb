# see http://codekata.pragprog.com/2007/01/kata_nine_back_.html
# The challenge description doesn’t mention the format of the pricing rules. How can these be specified in such a way that the checkout doesn’t know about particular items and their pricing strategies? How can we make the design flexible enough so that we can add new styles of pricing rule in the future? 

# The above meaning, not only "3 for 130" type of pricing rules, but also "buy 2, get one for free"

require 'test/unit'

class SKU
	
end

class CheckOut
  
	def self.process_rules(rules)
		rules
	end
	
	def initialize(rules)
		@items = Hash.new
		# rules is a Hash that tells how many items of each
		# stock keeping units (SKUs) cost how much
		@rules = self.class.process_rules(rules)		
	end

	def scan(item)
		@items[item] ||= 0
		@items[item] += 1
	end
	
	def price_for_sku(sku_id, num_of_sku_items)
		# returns the price of num_of_sku_items of sku_id type of sku-s
		price = 0
		rem_items = num_of_sku_items
		# sorting and reversing so that packages of more items come first (e.g 5, 3, 1)
		rules_for_sku = @rules[sku_id].sort.reverse
		until rem_items.zero? do
			rules_for_sku.each do |sku_quantity, sku_price|
				num_of_pack_items, mod_rem_items = rem_items.divmod(sku_quantity)
				# two pricing schemes are supported: 3 for 50 and buy-2-get-1-for-free
				# TODO: still, the Checkout knows how to handle these schemes, so the coupling is strong
				unless num_of_pack_items.zero?
					if sku_price == :free
						individual_price = rules_for_sku.detect { |price_pair| price_pair[0] == 1 }[1]
						price += individual_price * (sku_quantity - 1)
					else
						price += num_of_pack_items * sku_price
					end
					rem_items = mod_rem_items
				end
			end				
		end
		price
	end
	
	def total
		# items: { A => 3, B => 8, C => 1 }
		# rules: { A => { 2 => 50, 1 => 30 }, B => { 5 => 100, 3 => 65, 1 => 25 }, C => { 3 => 100, 1 => 40 } }
		@items.inject(0) { |total, sku_item| total + price_for_sku(sku_item[0], sku_item[1]) }
	end
	
end

if __FILE__ == $0
  class TestPrice < Test::Unit::TestCase

		# Item   Unit      Special
		#          Price     Price
		#   --------------------------
		#     A     50       3 for 130
		#     B     30       2 for 45
		#     C     20
		#     D     15

		RULES = { "A" => { 1 => 50, 3 => 130 }, "B" => { 1 => 30, 2 => 45 }, "C" => { 1 => 20 }, "D" => { 1 => 15 }, "E" => { 3 => :free, 1 => 10 } }
    def price(goods)
      co = CheckOut.new(RULES)
      goods.split(//).each { |item| co.scan(item) }
      co.total
    end

		# def test_sku_pricing
		# 	sku_a = SKU.new("A", 50, { 3 => 130 })
		# 	sku_a.class.price()
		# 	# each third is for free
		# 	sku_b = SKU.new("B", 30, { 3 => :free })
		# end

    def test_totals
      assert_equal(  0, price(""))
      assert_equal( 50, price("A"))
      assert_equal( 80, price("AB"))
      assert_equal(115, price("CDBA"))

      assert_equal(100, price("AA"))
      assert_equal(130, price("AAA"))
      assert_equal(180, price("AAAA"))
      assert_equal(230, price("AAAAA"))
      assert_equal(260, price("AAAAAA"))

      assert_equal(160, price("AAAB"))
      assert_equal(175, price("AAABB"))
      assert_equal(190, price("AAABBD"))
      assert_equal(190, price("DABABA"))

			assert_equal(20, price("EE"))
			assert_equal(20, price("EEE"))
			assert_equal(40, price("EEEEE"))
			assert_equal(115, price("EEEBAB"))
    end

    def test_incremental
      co = CheckOut.new(RULES)
      assert_equal(  0, co.total)
      co.scan("A");  assert_equal( 50, co.total)
      co.scan("B");  assert_equal( 80, co.total)
      co.scan("A");  assert_equal(130, co.total)
      co.scan("A");  assert_equal(160, co.total)
      co.scan("B");  assert_equal(175, co.total)
    end
  end
end