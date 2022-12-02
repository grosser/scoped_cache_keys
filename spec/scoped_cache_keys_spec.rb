require 'spec_helper'

# create tables
ActiveRecord::Schema.define(:version => 1) do
  create_table :users do |t|
    t.timestamp :updated_at
  end

  create_table :products do |t|
  end
end

# setup models
class User < ActiveRecord::Base
  include ScopedCacheKeys
end

class Product < ActiveRecord::Base
  include ScopedCacheKeys
end

describe ScopedCacheKeys do
  let(:user){ User.create! }

  before do
    Rails.cache.clear
  end

  it "has a VERSION" do
    ScopedCacheKeys::VERSION.should =~ /^[\.\da-z]+$/
  end

  describe "#scoped_cache_key" do
    it "is scoped by id" do
      Timecop.freeze "2011-01-01"
      user.scoped_cache_key(:foo).should_not == User.create!.scoped_cache_key(:foo)
    end

    it "stays the same" do
      user.scoped_cache_key(:foo).should == user.scoped_cache_key(:foo)
    end

    it "does not depend on updated_at" do
      expect{
        user.updated_at = 1.week.ago
      }.to_not change{ user.scoped_cache_key(:foo) }
    end

    it "accepts cache options such as expired_in" do
      key = user.scoped_cache_key(:foo, expires_in: 10.seconds)
      Timecop.travel(11.seconds.from_now)
      user.scoped_cache_key(:foo).should_not == key
    end
  end

  describe "#expire_scoped_cache_key" do
    it "expires a specific scope" do
      expect{
        user.expire_scoped_cache_key :foo
      }.to change{ user.scoped_cache_key(:foo) }
    end

    it "does not expire other keys" do
      expect{
        user.expire_scoped_cache_key :bar
      }.to_not change{ user.scoped_cache_key(:foo) }
    end

    it "expires a specific scope after a specified delay" do
      key = user.scoped_cache_key :foo
      user.expire_scoped_cache_key :foo, delay: 5.seconds
      Timecop.travel(4.seconds.from_now)
      user.scoped_cache_key(:foo).should == key
      Timecop.travel(2.seconds.from_now)
      user.scoped_cache_key(:foo).should_not == key
    end

    it "expires a specific scope after a specified global delay" do
      ScopedCacheKeys.expire_scoped_cache_key_delay = 10.seconds
      key = user.scoped_cache_key :foo
      user.expire_scoped_cache_key :foo
      Timecop.travel(9.seconds.from_now)
      user.scoped_cache_key(:foo).should == key
      Timecop.travel(2.seconds.from_now)
      user.scoped_cache_key(:foo).should_not == key
      ScopedCacheKeys.expire_scoped_cache_key_delay = nil
    end
  end
end
