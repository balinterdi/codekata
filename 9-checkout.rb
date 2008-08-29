# see http://codekata.pragprog.com/2007/01/kata_nine_back_.html
require 'test/unit'

class CheckOut
  
	attr_reader :items
	
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
	
	def total
		# items: { A => 3, B => 8, C => 1 }
		# rules: { A => { 2 => 50, 1 => 30 }, B => { 5 => 100, 3 => 65, 1 => 25 }, C => { 3 => 100, 1 => 40 } }
		total_price = 0
		@items.each_pair do |sku, num_items|
			total_price_for_sku = 0
			rem_items = num_items
			rules_for_sku = @rules[sku].sort.reverse
			while rem_items > 0 do
				rules_for_sku.each do |sku_quantity, sku_price|
					# puts "rem items of #{sku}: #{rem_items}"
					num_of_pack_items, mod_rem_items = rem_items.divmod(sku_quantity)
					unless num_of_pack_items.zero?
						total_price_for_sku += num_of_pack_items * sku_price
						rem_items = mod_rem_items
					end
				end				
			end
			total_price += total_price_for_sku
		end
		total_price
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

		RULES = { "A" => { 1 => 50, 3 => 130 }, "B" => { 1 => 30, 2 => 45 }, "C" => { 1 => 20 }, "D" => { 1 => 15 } }
    def price(goods)
      co = CheckOut.new(RULES)
      goods.split(//).each { |item| co.scan(item) }
      co.total
    end

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