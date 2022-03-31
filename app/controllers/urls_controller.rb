# frozen_string_literal: true

class UrlsController < ApplicationController
  def index
    # recent 10 short urls
    @url = Url.new
    @urls = Url.last(10)
  end

  def create
    if url_exist?(permit_params[:original_url])
      if Url.shorten(permit_params[:original_url])
        flash[:success] = "Saved url successfully"
      else
        flash[:notice] = "Could not save this url"
      end
    else
      flash[:error] = "Url is Invalid"
    end

    redirect_back(fallback_location: root_path)
  end

  def show
    @url = Url.find_by_short_url(params[:url])
    # @url = Url.new(short_url: 'ABCDE', original_url: 'http://google.com', created_at: Time.now)
    # implement queries

    if @url.clicks.present?
      @daily_clicks = @url.clicks.from_this_month
      @browsers_clicks = @url.clicks.browsers
      @platform_clicks = @url.clicks.platfroms
    end
  end

  def visit
    @link = Url.find_by_short_url(params[:short_url])
    if @link.nil?
      not_found
    else
      @link.clicks.create(platform: browser.platform.name, browser: browser.name)
      @link.update_attribute(:clicks_count, @link.clicks_count + 1)
      redirect_to @link.original_url
    end
  end

  private

  def permit_params
    params.require(:url).permit(:original_url)
  end

  require "net/http"
  def url_exist?(url_string)
    url = URI.parse(url_string)
    req = Net::HTTP.new(url.host, url.port)
    req.use_ssl = (url.scheme == 'https')
    path = url.path if url.path.present?
    res = req.request_head(path || '/')
    res.code != "404" # false if returns 404 - not found
  rescue Errno::ENOENT
    false # false if can't find the server
  end

end
