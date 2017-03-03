require 'minitest/autorun'
require_relative '../src/RedmineIntegrator'

describe "RedmineIntegratorTest" do
    describe "truncate tests" do
        it "should return the input string when the length is larger than the string itself" do
            sentence = 'I am so small!'
            assert_equal sentence, truncate(sentence, 500)
        end
    end
end