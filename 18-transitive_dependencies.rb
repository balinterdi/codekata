require 'test/unit'

class Dependencies

  def initialize
    @deps = Hash.new([])
  end

  def add_direct(klass, dep_klasses)
    @deps[klass] = dep_klasses
  end

  def direct_dependencies_for(klass)
    @deps[klass]
  end

  def dependencies_for(klass)
    dependencies_for_with_acc(klass, direct_dependencies_for(klass), direct_dependencies_for(klass)).sort
  end

  def dependencies_for_with_acc(klass, klasses_to_check, all_deps)
    # puts "klasses to check: #{klasses_to_check.inspect} all_deps: #{all_deps.inspect}"
    return all_deps if klasses_to_check.empty?
    indirect_deps = klasses_to_check.map do |dep_klass|
      direct_dependencies_for(dep_klass)
    end.flatten.sort.uniq
    indirect_deps_without_klass = indirect_deps.reject { |dep_klass| all_deps.include?(dep_klass) }
    dependencies_for_with_acc(klass, indirect_deps_without_klass, all_deps + indirect_deps_without_klass)
  end
end

if __FILE__ == $0
  class TestDependencies < Test::Unit::TestCase
    def test_basic
      dep = Dependencies.new
      dep.add_direct('A', %w{ B C } )
      dep.add_direct('B', %w{ C E } )
      dep.add_direct('C', %w{ G   } )
      dep.add_direct('D', %w{ A F } )
      dep.add_direct('E', %w{ F   } )
      dep.add_direct('F', %w{ H   } )

      assert_equal( %w{ B C E F G H },   dep.dependencies_for('A'))
      assert_equal( %w{ C E F G H },     dep.dependencies_for('B'))
      assert_equal( %w{ G },             dep.dependencies_for('C'))
      assert_equal( %w{ A B C E F G H }, dep.dependencies_for('D'))
      assert_equal( %w{ F H },           dep.dependencies_for('E'))
      assert_equal( %w{ H },             dep.dependencies_for('F'))
    end
  end
end

