class FilmsController < ApplicationController
  before_action :authenticate_user!, only: [:create_fav, :destroy_fav, :fav_films]
  before_action :find_fav, only: [:destroy_fav]

  def index
  end
  
  def search
    params[:page] = Integer(params[:page]) rescue 1
    films = search_film_by_title(params[:title], params[:page])
    @pages = (films["totalResults"].to_f / 10).ceil rescue 0
    
    if films.nil?
      redirect_to root_path
    end
  
    @film_list = films
  end

  def fav_films
    user_imdb_array = current_user.favs.pluck(:imdb_id)
    @fav_films = search_film_by_imdb(user_imdb_array)
  end

  def create_fav
    if already_fav?
      back_redirection
    else
      current_user.favs.create(user_id: current_user.id, imdb_id: params[:imdb])
    end

    back_redirection
  end

  def destroy_fav
    if not already_fav?
      back_redirection
    else
      @fav.destroy
    end

    back_redirection
  end
  
  
  private
    def request_api(url)
      response = Excon.get(url)
      parsed_response = JSON.parse(response.body)
      
      if parsed_response['Response'] != 'True'
        return nil
      else
        parsed_response
      end
      
    end
    
    def search_film_by_title(title, page = 1)
      request_api("http://www.omdbapi.com/?apikey=#{ENV["OMDB_API_KEY"]}&type=movie&s=#{URI.encode_www_form_component(title)}&page=#{page}")
    end

    def search_film_by_imdb(imdb)
      l = []
      if imdb.count > 0
        imdb.each do |f|
          l.append(request_api("http://www.omdbapi.com/?apikey=#{ENV["OMDB_API_KEY"]}&i=#{f}"))
        end

        return l
      end
    end

    def already_fav?
      Fav.where(user_id: current_user.id, imdb_id: params[:imdb]).exists?
    end

    def find_fav
      @fav = current_user.favs.find_by_imdb_id(params[:imdb])
    end

    def back_redirection
      redirect_back(fallback_location: root_path)
    end
end
