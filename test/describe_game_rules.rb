# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
#require 'describe_game_rules'

class DescribeGameRules < Test::Unit::TestCase
  def setup
    rules_factory = RulesFactory.new
    rules = [
        rules_factory.lonely,
        rules_factory.overcrowded,
        rules_factory.friendly_neigbourhood,
        rules_factory.resurect
      ]
    @rules_matcher = RuleMatcher.new rules
  end

  def test_should_die_when_live_in_lonely_neigbourhood
#    when
    next_generation  = @rules_matcher.select_and_apply(:live, 1)
#    then
    assert_equal(:dead, next_generation,"should die in lonely neigbourhood")
  end
  def test_should_die_when_live_in_overcrowded_neigbourhood
#    when
    next_generation  = @rules_matcher.select_and_apply(:live, 5)
#    then
    assert_equal(:dead, next_generation,"should die in overcrowded neigbourhood")
  end
  def test_should_stay_alive_when_live_in_friendly_neigbourhood
#    when
    next_generation  = @rules_matcher.select_and_apply(:live, 2) and  @rules_matcher.select_and_apply(:live, 2)
#    then
    assert_equal(:live, next_generation,"should stay alive in friendly neigbourhoodd")
  end
  def test_should_be_resurected_if_live_in_friendly_neighbourhood
#    when
    next_generation  = @rules_matcher.select_and_apply(:dead, 3)
#    then
    assert_equal(:live, next_generation,"should be resurected in friendly neighbourhood")
  end

  def test_should_instantinate_lonely_rule
    factory=RulesFactory.new
    rule = factory.lonely
    assert_equal "LonelyRule", rule.class.name
  end
  def test_should_instantinate_overcrowded_rule
    factory=RulesFactory.new
    rule = factory.overcrowded
    assert_equal "OvercrowdedRule", rule.class.name
  end
  def test_should_instantinate_lonely_rule
    factory=RulesFactory.new
    rule = factory.friendly_neigbourhood
    assert_equal "FriendlyNeigbourhoodRule", rule.class.name
  end
  def test_should_instantinate_overcrowded_rule
    factory=RulesFactory.new
    rule = factory.resurect
    assert_equal "ResurectRule", rule.class.name
  end
end


class RuleMatcher
  attr_reader :rules
  def initialize( rules )
    @rules_matcher = rules
  end
  def select_and_apply( is_alive, num_of_neighbours )
    rule  = select(is_alive, num_of_neighbours)
    rule.next_generation()
  end
  private
  def select( is_alive, num_of_neighbours )
    selected_rules = []
    @rules_matcher.each{ |rule|
      rule.can_be_applied(is_alive, num_of_neighbours) and selected_rules << rule }
    selected_rules.length != 1 and raise("Invalid number of rules which match to the conditions")
    selected_rules[0]
  end
end

class Rule
  attr_reader :next_generation
  def initialize( rule, next_generation)
    @rule = rule
    @next_generation = next_generation
  end
  def can_be_applied( is_alive, num_of_neighbours )
    @rule.call( is_alive, num_of_neighbours)
  end
end

class RulesFactory
  def lonely
    create_class("LonelyRule", lambda{ |is_alive,number_of_neighbours| is_alive.eql?(:live) and number_of_neighbours < 2 }, :dead)
  end
  def overcrowded
    create_class("OvercrowdedRule", lambda{ |is_alive,number_of_neighbours| is_alive.eql?(:live) and number_of_neighbours > 3 },:dead )
  end
  def friendly_neigbourhood
    create_class("FriendlyNeigbourhoodRule", lambda{ |is_alive,number_of_neighbours| is_alive.eql?(:live) and [2,3].include?(number_of_neighbours) },:live )
  end
  def resurect
    create_class("ResurectRule", lambda{ |is_alive,number_of_neighbours| is_alive.eql?(:dead) and number_of_neighbours == 3 }, :live)
  end
  private
  def create_class(class_name, rule_expression, next_generation)
      class_name[0,1].upcase!
      rule_klass= Object.const_set(class_name,Class.new(Rule))
      rule_klass.new rule_expression, next_generation
  end
end
