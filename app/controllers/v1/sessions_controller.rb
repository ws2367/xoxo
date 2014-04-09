class V1::SessionsController < ApplicationController

  skip_before_filter :authenticate_user!, :only => :create

  # POST users/sign_in
  def create 
    fb_access_token = params[:fb_access_token]
    app_id = ENV['FB_APP_ID']
    app_secret = ENV['FB_APP_SECRET']

    if fb_access_token.nil?
      render :status=>400,
             :json=>{:message=>"The request must contain the FB access token."}
      return
    end

    oauth = Koala::Facebook::OAuth.new(app_id, app_secret)
    app_access_token = oauth.get_app_access_token
    app_graph = Koala::Facebook::API.new(app_access_token)

    # check if the access token is valid and issued from our app 
    debug_info = app_graph.debug_token(fb_access_token)
    if debug_info["data"]["is_valid"] == false 
      render :status=>400,
             :json=>{:message=>"The FB access token is invalid"}
      return
    elsif debug_info["data"]["app_id"] != app_id.to_s
      render :status=>400,
             :json=>{:message=>"The FB access token is issued from other apps"}
      return
    end

    @graph = Koala::Facebook::API.new(fb_access_token)

    profile = @graph.get_object("me")

    fb_user_id = profile["id"].to_i
    location   = profile["location"]["name"]

    puts fb_user_id.to_s + ", " + location

    @user = User.find_by_fb_user_id(fb_user_id)
    
    if @user.nil?
      logger.info("User #{fb_user_id} failed signin. The user was then created.")
      @user = User.create(:fb_user_id=>fb_user_id, :fb_access_token=>fb_access_token)
      
      if @user.valid?
        #TODO: move the work to background
        puts "Requesting FB friends"
        friends = @graph.get_connections("me", "friends?fields=id")
        puts "Finished requesting FB friends"
        count = @user.cache_fb_friends_ids friends
        puts "Number of friendships created for User %s: %s" % [count, @user.id]
      else
        render :status=>500, 
               :json=>{:message=>"User cannot be found or created"} 
      end
    end

    # http://rdoc.info/github/plataformatec/devise/master/Devise/Models/TokenAuthenticatable
    @user.ensure_authentication_token!

    render :status=>200, :json=>{:token=>@user.authentication_token, 
                                 :bucket_name=>Moose::Application::PHOTO_BUCKET_NAME}
  end


  def destroy #mapped to DELETE users/sign_out 
    @user=User.find_by_authentication_token(params[:authentication_token])
    if @user.nil?
      logger.info("Token not found.")
      render :status=>404, :json=>{:message=>"Invalid token."}
    else
      @user.reset_authentication_token!
      render :status=>200, :json=>{}
    end
  end

end