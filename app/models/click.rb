# frozen_string_literal: true

class Click < ApplicationRecord
  belongs_to :url

  scope :from_this_month, -> { where("created_at > ? AND created_at < ?", Time.now.beginning_of_month, Time.now.end_of_month).group('Date(created_at)').count.map{|key, value| [key.strftime("%d"),value]} }
  scope :platfroms, -> { group('platform').count.map{|key, value| [key,value]} }
  scope :browsers, -> { group('browser').count.map{|key, value| [key,value]} }
end
