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
    return all_deps.reject { |dep| dep == klass } if klasses_to_check.empty?
    indirect_deps = klasses_to_check.map do |dep_klass|
      direct_dependencies_for(dep_klass)
    end.flatten.sort.uniq
    indirect_deps_but_already_checked = indirect_deps.reject { |dep_klass| all_deps.include?(dep_klass) }
    dependencies_for_with_acc(klass, indirect_deps_but_already_checked, all_deps + indirect_deps_but_already_checked)
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

    def test_circular
      dep = Dependencies.new
      dep.add_direct('A', %w{ B } )
      dep.add_direct('B', %w{ C } )
      dep.add_direct('C', %w{ A } )

      assert_equal( %w{ B C },   dep.dependencies_for('A'))
      assert_equal( %w{ A C },   dep.dependencies_for('B'))
      assert_equal( %w{ A B },   dep.dependencies_for('C'))
    end

  end
end

