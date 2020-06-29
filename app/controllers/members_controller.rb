class MembersController < ApplicationController
  def create
    @member = Member.new(params.permit(:name, :website_url))

    if @member.save
      scrape_topics
      shorten_url
      redirect_to @member
    else
      render layout: false, content_type: 'text/javascript'
    end
  end

  def index
    @members = Member.left_outer_joins(:friends).select('members.*, count(relationships.*) as friends_count').group(:id)
  end

  def show
    @member = Member.find(params[:id])
  end

  private

  def scrape_topics
    page = MetaInspector.new(@member.website_url)
    @member.update!(topics: page.h1 + page.h2 + page.h3)
  end

  def shorten_url
    conn = Faraday.new(url: 'https://api-ssl.bitly.com/v4/shorten') do |faraday|
      faraday.adapter Faraday.default_adapter
      faraday.response :json
    end

    response = conn.post do |req|
      req.headers['Authorization'] = 'Bearer 4be619fda1ae92273a4a82fa1300ae124db5d78a'
      req.headers['Content-Type'] = 'application/json'
      req.body = { long_url: @member.website_url }.to_json
    end

    puts response.body

    @member.update!(short_url: response.body['link']) if response.success?
  end
end
