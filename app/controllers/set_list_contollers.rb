#index
get '/set_lists' do
  @set_lists = SetList.all.order("performance_date")
  erb :"set_lists/index"
end

#new 1 of 2
get '/set_lists/new' do
  @set_list = SetList.new
  @venues = Venue.where.not(id: 1)
  erb :"set_lists/new"
end

#new 2 of 2
get '/set_lists/new/:id' do
  @sets = params['sets'].to_i
  @songs = Song.where.not(id: 1).order('title')
  @venue = Venue.find_by_id(params['venue_id'])
  @set_list = SetList.find_by_id(params['id'])
  erb :"set_lists/new_list"
end

#create set list object record
post '/set_lists/new' do
  @sets = params['sets'].to_i
  @venues = Venue.where.not(id: 1)
  date_parts = params['date'].split("-")
  @date = Date.new(date_parts[0].to_i,date_parts[1].to_i,date_parts[2].to_i)
  @set_list = SetList.new(name: params['name'],
                          performance_date: @date,
                          venue_id: params['venue_id'],
                          number_of_sets: @sets)
  if @set_list.save
    redirect to("/set_lists/new/#{@set_list.id}?sets=#{@sets}")
  else
    erb :"set_lists/new"
  end
end

#Handle AJAX calls to delete and rewrite the set items associated with each set in a set_list
post '/set_lists/new/sets' do
  @set_list = SetList.find_by_id(params['set_list_id'])
  @set_list.update_sets(params)
end

#show
get '/set_lists/:id' do
  @set_list = SetList.find_by_id(params['id'])
  @set_items = SetItem.where(set_list_id: params['id'])
  erb :"set_lists/show"
end

#edit
get '/set_lists/:id/edit' do
  @set_list = SetList.find_by_id(params['id'])
  @set_items = SetItem.where(set_list_id: params['id'])
  @songs = @set_list.available_songs(@set_items)
  erb :"set_lists/edit"
end

#delete
delete '/set_lists/:id/delete' do
  @set_list = SetList.find_by_id(params['id'])
  @set_items = SetItem.where(set_list_id: @set_list.id)
  @set_list.prepare_destruction(@set_items)
  @set_list.destroy
  redirect to("/set_lists")
end
