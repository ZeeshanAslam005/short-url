# frozen_string_literal: true

class Url < ApplicationRecord
  validates_presence_of :original_url
  validates :original_url, format: URI::regexp(%w[http https])
  validates_uniqueness_of :short_url

  has_many :clicks, dependent: :destroy

  # before_validation :generate_short_url
  #
  # def self.generate_short_url
  #   self.short_url = SecureRandom.send(:choose, [*'A'..'Z'], 5)
  #   true
  # end

  def short
    Rails.application.routes.url_helpers.short_url(slug: self.short_url)
  end

  def self.shorten(original_url)
    # return short when URL with that slug was created before
    url = Url.where(original_url: original_url).first
    return url.short_url if url

    # create a new
    link = Url.new(original_url: original_url, short_url: SecureRandom.send(:choose, [*'A'..'Z'], 5))
    return link.short_url if link.save

    # if slug is taken, try to add random characters
    Url.shorten(original_url)
  end
end
