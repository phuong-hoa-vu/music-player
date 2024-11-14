require 'rubygems'
require 'gosu'
require './album_functions.rb'

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(255, 189, 89)
SCREEN_WIDTH = 1000
SCREEN_HEIGHT = 800
X_LOCATION = 650		# x-location to display track's name

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

class ArtWork
	attr_accessor :bmp
	def initialize(file)
		@bmp = Gosu::Image.new(file)
		
	end
end

class MusicPlayerMain < Gosu::Window

	def initialize
	    super SCREEN_WIDTH, SCREEN_HEIGHT
	    self.caption = "Music Player"
	    @track_font = Gosu::Font.new(30)
	    @albums = read_albums()
	    @album_playing = -1
	    @track_playing = -1
		@background = BOTTOM_COLOR
		@tick = Gosu.milliseconds
		@x_loc = 0
	end
	# Draw albums' artworks
	def draw_albums(albums)
		@album_image = ArtWork.new("images/harry.jpg")
		@album_image.bmp.draw(70,50,2,0.35,0.35)
		@album_image = ArtWork.new("images/rising.jpg")
		@album_image.bmp.draw(310,50,2,0.35,0.35)
		@album_image = ArtWork.new("images/mood.jpg")
		@album_image.bmp.draw(70,300,2,0.35,0.35)
		@album_image = ArtWork.new("images/sun.jpg")
		@album_image.bmp.draw(310,300,2,0.35,0.35)
	end

	# Draw tracks' titles of a given album
	def draw_each_album()
		 	@album_name = "Playing " + "\nAlbum:  " + @albums[@album_playing].title.chomp + "\nArtist: " + @albums[@album_playing].artist.chomp
			@track_font.draw_text(@album_name, 50, 460, ZOrder::UI, 1.1, 1.1, Gosu::Color::BLACK)
	end

	def draw_tracks(album)
		@track_font.draw_text('Track List:', X_LOCATION, 35, ZOrder::UI, 1.2, 1.2, Gosu::Color::BLACK)
		album.tracks.each do |track|
			display_track(track)
		end
	end

	# Draw indicator of the current playing song
	def draw_current_playing(indicator, album)
		draw_rect(album.tracks[indicator].dim.leftX - 10, album.tracks[indicator].dim.topY, 300, @track_font.height(), Gosu::Color::CYAN, z = ZOrder::BACKGROUND)
	end

	# Detects if a 'mouse sensitive' area has been clicked on
	# i.e either an album or a track. returns true or false
	def area_clicked(leftX, topY, rightX, bottomY)
		if mouse_x > leftX && mouse_x < rightX && mouse_y > topY && mouse_y < bottomY
			return true
		end
		return false
	end

	# Takes a String title and an Integer ypos
	# You may want to use the following:
	def display_track(track)
		@track_font.draw_text(track.name, X_LOCATION, track.dim.topY, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
	end


	# Takes a track index and aan Album and plays the Track from the Album
	def playTrack(track, album)
		@song = Gosu::Song.new(album.tracks[track].location)
		@song.play(false)
	end

	# Draw a coloured background using TOP_COLOR and BOTTOM_COLOR
	def draw_background()
		Gosu.draw_rect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, @background, ZOrder::BACKGROUND, mode=:default)
	end
	def draw_buttons()
		@control_buttons = ArtWork.new("images/backward.png")
		@control_buttons.bmp.draw(5, 250, 2, 0.25, 0.25)
		@control_buttons = ArtWork.new("images/forward.png")
		@control_buttons.bmp.draw(550, 250, 2, 0.25, 0.25)
		@control_buttons = ArtWork.new("images/random.png")
		@control_buttons.bmp.draw(30, 600, 2, 0.25, 0.25)
		@control_buttons = ArtWork.new("images/play.png")
		@control_buttons.bmp.draw(190, 600, 2, 0.25, 0.25)
		@control_buttons = ArtWork.new("images/pause.png")
		@control_buttons.bmp.draw(260, 600, 2, 0.25, 0.25)
		@control_buttons = ArtWork.new("images/backward.png")
		@control_buttons.bmp.draw(120, 600, 2, 0.25, 0.25)
		@control_buttons = ArtWork.new("images/forward.png")
		@control_buttons.bmp.draw(330, 600, 2, 0.25, 0.25)
		
	end

	# Not used? Everything depends on mouse actions.
	def update
		# If a new album has just been seleted, and no album was selected before -> start the first song of that album
		if @album_playing >= 0 && @song == nil
			@track_playing = 0
			playTrack(0, @albums[@album_playing])
		end
		
		# If an album has been selecting, play all songs in turn
		if @album_playing >= 0 && @song != nil && (not @song.playing?)
			@track_playing = (@track_playing + 1) % @albums[@album_playing].tracks.length()
			playTrack(@track_playing, @albums[@album_playing])
		end

		# if (@song.playing? == false)
		# 	@tick = Gosu.milliseconds - @count_up
		# else 
		# 	@count_up = (Gosu.milliseconds - @tick)
		# 	@x_loc = @count_up * 800 / @duration
		# end
	end
	def randomize_song()
    	@album_id = rand(0..3)
    	@track_playing = rand(0..@albums[@album_id].tracks.length-1)
		playTrack(@track_playing, @albums[@album_id])
	end


	#--------Draw line to show how long the track is----------
	def draw_control()
		x_loc = @x_loc
		Gosu.draw_rect(100, 725, 800, 15, Gosu::Color::WHITE, ZOrder::PLAYER)
		Gosu.draw_rect(100, 725, @x_loc, 15, Gosu::Color::CYAN, ZOrder::UI)
	end
	# Draws the album images and the track list for the selected album
	def draw
		draw_background()
		draw_albums(@albums)
		draw_buttons()
		draw_control()
		# If an album is selected => display its tracks
		if @album_playing >= 0
			draw_each_album()
			draw_tracks(@albums[@album_playing])
			draw_current_playing(@track_playing, @albums[@album_playing])
		end
	end

 	def needs_cursor?; true; end


	def button_down(id)
		case id
	    when Gosu::MsLeft

	    	# If an album has been selected
	    	if @album_playing >= 0
		    	# --- Tracks tracker ---
		    	for i in 0..@albums[@album_playing].tracks.length() - 1
			    	if area_clicked(@albums[@album_playing].tracks[i].dim.leftX, @albums[@album_playing].tracks[i].dim.topY, @albums[@album_playing].tracks[i].dim.rightX, @albums[@album_playing].tracks[i].dim.bottomY)
			    		playTrack(i, @albums[@album_playing])
			    		@track_playing = i
			    		break
			    	end
			    end
			end

			# --- Albums clicker ---
			for i in 0..@albums.length() - 1
				if area_clicked(70, 50, 290, 270) 
					@album_playing = i
					@album_id = @album_playing
					@song = nil
					break
				end
				if area_clicked(310, 50, 530, 270) 
					@album_playing = i + 1
					@album_id = @album_playing
					@song = nil
					break
				end
				if area_clicked(70, 300, 290, 520) 
					@album_playing = i + 2
					@album_id = @album_playing
					@song = nil
					break
				end
				if area_clicked(310, 300, 530, 520) 
					@album_playing = i + 3
					@album_id = @album_playing
					@song = nil
					break
				end
				if area_clicked(190, 600, 260, 670) #-----play button------
					@song.play
					@turn_off = false
				end
				if area_clicked(260, 600, 330, 670) #-----pause button------
					@song.pause
				end
				if area_clicked(330, 600, 400, 670) #-----forward track button------
					if @track_playing < @albums[@album_id].tracks.length-1
						@track_playing +=1
						@tick = Gosu.milliseconds
						playTrack(@track_playing, @albums[@album_id])
					end
				end
				if area_clicked(120, 600, 190, 670) #-----backward track button------
					if @track_playing > 0
						@track_playing -=1
						playTrack(@track_playing, @albums[@album_id])
						@tick = Gosu.milliseconds
					end
				end
				if area_clicked(720, 200, 790, 270) #-----forward album button------
					if @album_id < @albums.length-1
						@song.stop
						@tick = Gosu.milliseconds
						@album_id +=1
						@track_playing = 0
						playTrack(@track_playing, @albums[@album_id])
					end
				end
				if area_clicked(20, 200, 90, 270) #-----backward album button------
					if @album_id >0
						@song.stop
						@tick = Gosu.milliseconds
						@album_id -= 1
						@track_playing = 0
						playTrack(@track_playing, @albums[@album_id])
					end
				end
				if area_clicked(30, 600, 100, 520)#-----random button------
					randomize_song()
				end
			end
	    end
	end

end

# Show is a method that loops through update and draw
MusicPlayerMain.new.show if __FILE__ == $0