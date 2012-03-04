# This file is part of the Ruleby project (http://ruleby.org)
#
# This application is free software; you can redistribute it and/or
# modify it under the terms of the Ruby license defined in the
# LICENSE.txt file.
# 
# Copyright (c) 2007 Joe Kutner and Matt Smith. All rights reserved.
#
# * Authors: Joe Kutner, Matt Smith
#

require 'ruleby'
require 'rspec'
require 'rpg_rules'

include Ruleby

describe 'Attack' do
  before :all do
    engine :engine do |e|  
      GameRulebook.new e do |r|
        r.rules
      end

      @fred = Character.new('Fred', 'human', 10, 10)
      @orc = Monster.new('orc', 5, 6)
      @fred.act(:attack, @orc)

      e.assert @fred
      e.assert @orc
  
      e.match
    end
  end
  
  it 'should kill the orc' do
    @orc.hp.should <= 0
  end

  it 'should advance the character Fred one level' do
    @fred.level.should == 1
  end
end
