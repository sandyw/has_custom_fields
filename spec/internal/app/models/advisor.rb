class Advisor < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :name
end