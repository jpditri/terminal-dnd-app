# frozen_string_literal: true

class GlobalSearchService
  attr_reader :query, :user

  def initialize(query: Query.new, user: User.new)
    @query = query
    @user = user
  end


  def search
    # TODO: Implement
  end

  def self
    # TODO: Implement
  end
end