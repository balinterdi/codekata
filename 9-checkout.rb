# see http://codekata.pragprog.com/2007/01/kata_nine_back_.html
# The challenge description doesn’t mention the format of the pricing rules. How can these be specified in such a way that the checkout doesn’t know about particular items and their pricing strategies? How can we make the design flexible enough so that we can add new styles of pricing rule in the future?

# The above meaning, not only "3 for 130" type of pricing rules, but also "buy 2, get one for free"

require 'test/unit'

# SKU: Stock Keeping Unit

class SKUPricing

  def initialize(rules)
    @rules = rules
  end

  def unit_price
    @rules.detect { |pair_price| pair_price[0] == 1 }[1]
  end

  def get_bundle_price(num_items)
    # returns the price of num_of_sku_items of sku_id type of sku-s
    @rules.sort.reverse.inject(0) do |bundle_price, rule|
      items_in_pack, price = rule
      num_of_packs, num_items = num_items.divmod(items_in_pack)
      if num_of_packs.zero?
        bundle_price
      else
        if price == :free
          # buy-2-get-1-for-free
          bundle_price + ( unit_price * (items_in_pack - 1) )
        else
          # 3 for 50
          bundle_price + ( num_of_packs * price )
        end
      end
    end
  end

end

class CheckoutPricing
  def initialize(rules)
    # rules is a Hash that tells how many items of each
    # stock keeping units (SKUs) cost how much
    @rules = Hash.new
    rules.each do |sku_id, sku_rules|
      @rules[sku_id] = SKUPricing.new(sku_rules)
    end
  end

  def total_price(items)
    items.inject(0) do |total, sku_item|
      sku_id = sku_item[0]
      num_items = sku_item[1]
      total + @rules[sku_item[0]].get_bundle_price(sku_item[1])
    end
  end
end

class CheckOut

  def initialize(rules)
    @items = Hash.new
    @pricer = CheckoutPricing.new(rules)
  end

  def scan(item)
    @items[item] ||= 0
    @items[item] += 1
  end

  def total
    # items: { A => 3, B => 8, C => 1 }
    # rules: { A => { 2 => 50, 1 => 30 }, B => { 5 => 100, 3 => 65, 1 => 25 }, C => { 3 => 100, 1 => 40 } }
    @pricer.total_price(@items)
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
    #   sku_a = SKU.new("A", 50, { 3 => 130 })
    #   sku_a.class.price()
    #   # each third is for free
    #   sku_b = SKU.new("B", 30, { 3 => :free })
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