require 'rpg_rules/core_ext'
require 'rpg_rules/models'

class GameRulebook < Ruleby::Rulebook
  def rules
    rule :Dead,
      [:is_a?, Creature, :creature, m.hp <= 0] do |v|
        creature = v[:creature]
        puts "#{creature.name} dies!!"
        retract creature
        assert Death.new creature
    end

    rule :Action_Attack,
      [:is_a?, Creature, :defender, m.action.not== :attack, m.hp >= 0],
      [:is_a?, Creature, :attacker, m.action == :attack] do |v|
        attacker = Attacker.new v[:attacker]
        defender = Defender.new v[:defender]
        assert attacker
        assert defender
        assert Attack.new(attacker, defender)
    end

    rule :Attack_Hit,
      [:exists, Attack, :attack],
      [Defender, :defender, {m.defend_roll => :defence}],
      [Attacker, :attacker, m.attack_roll >= b(:defence)] do |v|
        attack = v[:attack]
        attacker = v[:attacker].creature
        defender = v[:defender].creature
        puts "#{attacker.name} attacks #{defender.name} and hits"
        defender.hurt(attacker.attack_roll)
        attack.reset!

        retract attack
        modify defender
    end

    rule :Experience_from_kill,
      [:exists, Death, :death, {m.creature => :dead}],
      [Defender, :defender, m.creature == b(:dead)],
      [Attacker, :attacker] do |v|
        death = v[:death]
        defender = v[:defender].creature
        attacker = v[:attacker].creature
        attacker.experience defender.xp_value
        modify attacker
        retract death 
    end

    rule :Rise_level,
      [:is_a?, Creature, :creature, m.xp >= 10, m.level == 0] do |v|
        creature = v[:creature]
        creature.rise_lv!
        modify creature
    end

    rule :Attack_Miss,
      [:exists, Attack, :attack],
      [Defender, :defender, {m.defend_roll => :defence}],
      [Attacker, :attacker, m.attack_roll <= b(:defence)] do |v|
        attack = v[:attack]
        attacker = v[:attacker].creature
        defender = v[:defender].creature
        puts "#{attacker.name} misses #{defender.name}"
        attack.reset!
        retract attack

        modify attacker
    end
  end
end
