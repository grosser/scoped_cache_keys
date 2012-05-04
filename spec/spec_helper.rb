$LOAD_PATH.unshift 'lib'
require 'scoped_cache_keys'

require 'active_record'
require 'timecop'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)

module Rails
  def self.cache
    @cache ||= ActiveSupport::Cache::MemoryStore.new
  end
end

RSpec.configure do |config|
  config.before do
    Timecop.return
  end
end
