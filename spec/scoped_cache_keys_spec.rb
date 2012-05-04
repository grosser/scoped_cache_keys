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
  end

  describe "#touch_if_necessary" do
    context "with a model that has updated_at" do
      let(:model) do
        user = User.create!
        user.update_attribute(:updated_at, 1.month.ago)
        user
      end

      it  "increments updated_at" do
        expect{
          model.touch_if_necessary
        }.to change{ model.reload.updated_at.to_i }
      end

      it  "does not update updated_at if it thinks the model is fresh" do
        model.touch_if_necessary
        expect{
          model.class.update(model.id, :updated_at => 1.month.ago)
          model.touch_if_necessary
        }.to change{ model.reload.updated_at.to_i }
      end
    end

    context "with a model that does not have updated_at" do
      let(:model){ Product.create! }

      it "raises" do
        expect{
          model.touch_if_necessary
        }.to raise_error
      end
    end
  end
end
