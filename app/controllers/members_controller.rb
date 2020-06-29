class MembersController < ApplicationController
  def create
    @member = Member.new(params.permit(:name, :website_url))

    if @member.save
      scrape_topics
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
end
