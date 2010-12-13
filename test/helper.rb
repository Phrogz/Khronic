require 'minitest/autorun'
MT = MiniTest::Unit::TestCase
docs  = File.join(File.dirname(__FILE__),'docs')
L1DOC = File.join(docs,'cmajor_l1.yaml')
SIMPLE = File.join(docs,'simple.yaml')
require_relative '../lib/khronic'