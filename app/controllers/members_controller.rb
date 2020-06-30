class MembersController < ApplicationController
  def add_friend
    member = Member.find(params[:id])
    member.friends << Member.find(params[:friend_id]) unless member.friends.where(id: params[:friend_id]).exists?

    redirect_to member
  end

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

  def discover
    @member = Member.find(params[:id])

    if params[:topic].present?
      member_topics = Member.joins(:topics)
        .where.not(id: @member.id)
        .where.not(id: @member.relationships.select(:to_id))
        .where("topics.name_vector @@ plainto_tsquery('english', ?)", params[:topic])
        .group(:id)
        .pluck(:id, 'array_agg(topics.name)')
        .to_h

      if member_topics.length > 0
        discovery_query = <<-SQL
          with recursive member_discovery
          as
          (
            select to_id as from_id, from_id as to_id, ARRAY[#{@member.id}, from_id] as path
            from relationships
            where to_id = #{@member.id}
            union
            select nxt.from_id, nxt.to_id, array_append(prv.path, nxt.to_id) as path
            from relationships nxt
              join member_discovery prv on nxt.from_id = prv.to_id and nxt.to_id != ALL(prv.path)
          )
          select distinct on (to_id) to_id, path
          from member_discovery
          where to_id in (#{member_topics.keys.join(',')})
          order by to_id, array_length(path, 1)
        SQL

        members = Member.joins("inner join (#{discovery_query}) as d on members.id = any(d.path)").select('members.*, d.path').group_by(&:path)

        @results = members.map do |path, members|
          ordered_members = members.sort_by { |member| path.index(member.id) }
          { members: ordered_members, topics: member_topics[ordered_members.last.id] }
        end
      else
        @results = []
      end
    end
  end

  def index
    @members = Member.left_outer_joins(:friends).select('members.*, count(relationships.*) as friends_count').group(:id)
  end

  def search_new_friends
    members = Member.where('members.name ilike ?', "%#{params[:search_terms]}%")
      .where.not(id: params[:id])
      .where.not(id: Relationship.where(from_id: params[:id]).select(:to_id))

    render json: members.to_json(only: [:id, :name])
  end

  def show
    @member = Member.find(params[:id])
  end

  private

  def scrape_topics
    page = MetaInspector.new(@member.website_url)
    @member.topics = (page.h1 + page.h2 + page.h3).map { |heading| Topic.new(name: heading) }
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

    @member.update!(short_url: response.body['link']) if response.success?
  end
end
