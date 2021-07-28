require_relative '../environment'

class BuildAncestryTest < ActiveSupport::TestCase
  def test_build_ancestry_from_parent_ids
    AncestryTestDatabase.with_model :skip_ancestry => true, :extra_columns => {:parent_id => :integer} do |model|
      [model.create!].each do |parent1|
        (Array.new(5) { model.create! :parent_id => parent1.id }).each do |parent2|
          (Array.new(5) { model.create! :parent_id => parent2.id }).each do |parent3|
            (Array.new(5) { model.create! :parent_id => parent3.id })
          end
        end
      end

      # Assert all nodes where created
      assert_equal (0..3).map { |n| 5 ** n }.sum, model.count

      model.has_ancestry
      model.build_ancestry_from_parent_ids!

      # Assert ancestry integrity
      assert_nothing_raised do
        model.check_ancestry_integrity!
      end

      roots = model.roots.to_a
      # Assert single root node
      assert_equal 1, roots.size

      # Assert it has 5 children
      roots.each do |parent1|
        assert_equal 5, parent1.children.count
        parent1.children.each do |parent2|
          assert_equal 5, parent2.children.count
          parent2.children.each do |parent3|
            assert_equal 5, parent3.children.count
            parent3.children.each do |parent4|
              assert_equal 0, parent4.children.count
            end
          end
        end
      end
    end
  end
end
