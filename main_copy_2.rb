require 'rubygems'
require 'gosu'
require './album_functions.rb'

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(255, 189, 89)
SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
X_LOCATION = 460		# x-location to display track's name
@albums = read_albums()
@album_id = @albums.id
module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

class ArtWork
	attr_accessor :bmp
	def initialize(file)
		@bmp = Gosu::Image.new(file)
		
	end
end


#----------------------- Each album page ------------------------------------
class Albumplay < Gosu::Window 
	def initialize
		super SCREEN_WIDTH, SCREEN_HEIGHT
		self.caption = "Album page"
		@background = BOTTOM_COLOR
		@track_font = Gosu::Font.new(25)
		@turn_off = false
		@albums = read_albums()
	    @track_playing = -1
		@x_loc = 0
		@tick = Gosu.milliseconds
	end
	def draw_albums(albums)
		@album_image = ArtWork.new("images/harry.jpg")
		case @album_id
		when 0
		@album_image = ArtWork.new("images/harry.jpg")
		when 1
		@album_image = ArtWork.new("images/rising.jpg")
		when 2
		@album_image = ArtWork.new("images/mood.jpg")
		when 3
		@album_image = ArtWork.new("images/sun.jpg")
		when 4 
		@album_image = ArtWork.new("images/gracie.jpg")
		end
		@album_image.bmp.draw(100,50,2,0.5,0.5)
	end

	def draw_each_album()
		@album_name = "Album:  " + @albums[@album_id].title.chomp + "\nArtist: " + @albums[@album_id].artist.chomp
		@track_font.draw_text(@album_name, 100, 380, ZOrder::UI,0.9, 0.9, Gosu::Color::BLACK)
	end

	def draw_tracks(album)
		@track_font.draw_text('Track List:', X_LOCATION, 35, ZOrder::UI, 1.3, 1.3, Gosu::Color::BLACK)
		album.tracks.each do |track|
		display_track(track)
	end
	end
	#----------Draw other buttons----------------
	def draw_buttons()
		@control_buttons = ArtWork.new("images/backward.png")
		@control_buttons.bmp.draw(20, 200, 2, 0.25, 0.25)
		@control_buttons = ArtWork.new("images/forward.png")
		@control_buttons.bmp.draw(720, 200, 2, 0.25, 0.25)
		@control_buttons = ArtWork.new("images/random.png")
		@control_buttons.bmp.draw(30, 450, 2, 0.25, 0.25)
		@control_buttons = ArtWork.new("images/play.png")
		@control_buttons.bmp.draw(190, 450, 2, 0.25, 0.25)
		@control_buttons = ArtWork.new("images/pause.png")
		@control_buttons.bmp.draw(260, 450, 2, 0.25, 0.25)
		@control_buttons = ArtWork.new("images/backward.png")
		@control_buttons.bmp.draw(120, 450, 2, 0.25, 0.25)
		@control_buttons = ArtWork.new("images/forward.png")
		@control_buttons.bmp.draw(330, 450, 2, 0.25, 0.25)
		@control_buttons = ArtWork.new("images/home.png")
		@control_buttons.bmp.draw(10, 10, 2, 0.25, 0.25)
	end

	def randomize_song()
    	@album_id = rand(0..3)
    	@track_playing = rand(0..@albums[@album_id].tracks.length-1)
		playTrack(@track_playing, @albums[@album_id])
	end


	#--------Draw line to show how long the track is----------
	def draw_control()
		x_loc = @x_loc
		Gosu.draw_rect(100, 550, 600, 10, Gosu::Color::WHITE, ZOrder::PLAYER)
		Gosu.draw_rect(100, 550, @x_loc, 10, Gosu::Color::CYAN, ZOrder::UI)
	end


	def draw_current_playing(indicator, album)
		draw_rect(album.tracks[indicator].dim.leftX - 10, album.tracks[indicator].dim.topY, 250, @track_font.height(), Gosu::Color::CYAN, z = ZOrder::BACKGROUND)
		
	end

	def area_clicked(leftX, topY, rightX, bottomY)
		if mouse_x > leftX && mouse_x < rightX && mouse_y > topY && mouse_y < bottomY
			return true
		end
		return false
	end

	def display_track(track)
		@track_font.draw_text(track.name, X_LOCATION, track.dim.topY, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
	end


	# Takes a track index and aan Album and plays the Track from the Album
	def playTrack(track, album)
		@song = Gosu::Song.new(album.tracks[track].location)
		@duration = album.tracks[track].duration
		@song.play(false)
	end

	# Draw a coloured background using TOP_COLOR and BOTTOM_COLOR
	def draw_background()
		Gosu.draw_rect(0, 0, 800, 600, @background, ZOrder::BACKGROUND, mode=:default)
	end

	def update
		if Gosu::Song.current_song == nil
			@track_playing = (@track_playing + 1) % @albums[@album_id].tracks.length()
			@tick = Gosu.milliseconds
			playTrack(@track_playing, @albums[@album_id])
		end
		if (@song.playing? == false)
			@tick = Gosu.milliseconds - @count_up
		else 
			@count_up = (Gosu.milliseconds - @tick)
			@x_loc = @count_up * 600 / @duration
		end
	end

	def draw
		draw_background()
		draw_albums(@albums)
		draw_buttons()
		draw_each_album()
		draw_control()
		draw_tracks(@albums[@album_id])
		draw_current_playing(@track_playing, @albums[@album_id])
	end
	def needs_cursor?; true; end


	def button_down(id)
		case id
	    when Gosu::MsLeft
			# --- Tracks tracker ---
			for i in 0..@albums[@album_id].tracks.length() - 1
				if area_clicked(@albums[@album_id].tracks[i].dim.leftX, @albums[@album_id].tracks[i].dim.topY, @albums[@album_id].tracks[i].dim.rightX, @albums[@album_id].tracks[i].dim.bottomY)
					playTrack(i, @albums[@album_id])
					@track_playing = i
					@tick = Gosu.milliseconds
					break
				end
			end
			#----Buttons clicked--------
			if area_clicked(10, 10, 80, 80) #-----Home button------
				close
				@song.stop
				@turn_off = true
				Homepage.new.show if __FILE__ == $0
			end
			if area_clicked(190, 450, 260, 520) #-----play button------
				@song.play
				@turn_off = false
			end
			if area_clicked(260, 450, 330, 520) #-----pause button------
				@song.pause
			end
			if area_clicked(330, 450, 400, 520) #-----forward track button------
				if @track_playing < @albums[@album_id].tracks.length-1
					@track_playing +=1
					@tick = Gosu.milliseconds
					playTrack(@track_playing, @albums[@album_id])
				end
			end
			if area_clicked(120, 450, 190, 520) #-----backward track button------
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
			if area_clicked(30, 450, 100, 520)#-----random button------
				randomize_song()
			end
		end
	end
end

# Albumplay.new.show if __FILE__ == $0
#----------------------- Main home page ------------------------------------
class Homepage < Gosu::Window
    def initialize
        super SCREEN_WIDTH, SCREEN_HEIGHT
		@background = BOTTOM_COLOR
		self.caption = "Homepage"
		@track_font = Gosu::Font.new(15)
		@album= read_albums()
		@page = 0
    end
	
	#-------Draw albums---------
	def draw_pages()

	end
	def draw_albums(albums)
		case @page
		when 0
			@album_image = ArtWork.new("images/harry.jpg")
			@album_image.bmp.draw(100,50,2,0.32,0.32)
			@album_image = ArtWork.new("images/rising.jpg")
			@album_image.bmp.draw(450,50,2,0.32,0.32)
			@album_image = ArtWork.new("images/mood.jpg")
			@album_image.bmp.draw(100,300,2,0.32,0.32)
			@album_image = ArtWork.new("images/sun.jpg")
			@album_image.bmp.draw(450,300,2,0.32,0.32)
		when 1
			@album_image = ArtWork.new("images/gracie.jpg")
			@album_image.bmp.draw(100,50,2,0.32,0.32)
		end
	end
	#-------Draw playlist button ---------
	def draw_playlist_button()
		@control_buttons = ArtWork.new("images/backward.png")
		@control_buttons.bmp.draw(20, 250, 2, 0.25, 0.25)
		@control_buttons = ArtWork.new("images/forward.png")
		@control_buttons.bmp.draw(720, 250, 2, 0.25, 0.25)
		
	  end
	#-------Draw albums name---------
	def draw_album_name()
		case @page 
		when 0
			@name = @album[0].title
			@track_font.draw_text(@name, 160, 257, ZOrder::UI, 1.5, 1.5, Gosu::Color::BLACK)
			@name = @album[1].title
			@track_font.draw_text(@name, 525, 257, ZOrder::UI, 1.5, 1.5, Gosu::Color::BLACK) 
			@name = @album[2].title
			@track_font.draw_text(@name, 95, 510, ZOrder::UI, 1.5, 1.5, Gosu::Color::BLACK) 
			@name = @album[3].title
			@track_font.draw_text(@name, 450, 510, ZOrder::UI, 1.5, 1.5, Gosu::Color::BLACK) 
		when 1
			@name = @album[4].title
			@track_font.draw_text(@name, 95, 257, ZOrder::UI, 1.5, 1.5, Gosu::Color::BLACK)
		end
	  end

	#-------Draw background---------
	def draw_background()
		Gosu.draw_rect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, @background, ZOrder::BACKGROUND, mode=:default)
	end

	def area_clicked(leftX, topY, rightX, bottomY)
		if mouse_x > leftX && mouse_x < rightX && mouse_y > topY && mouse_y < bottomY
			return true
		end
		return false
	end

	# def update()
	# 	if @album == 0 or @album == 2 or @album == 4
	# 		@x_pos = 100
	# 	else
	# 		@x_pos = 450
	# 	end
	# 	if @album == 0  or @album == 1 or  @album == 4
	# 		@y_pos = 50
	# 	else
	# 		@y_pos = 300
	# 	end
	# end


	def draw()
		draw_background()
		draw_albums(@albums)
		draw_playlist_button()
		draw_album_name()
	end


	def needs_cursor?; true; end


	def button_down(id)
		case id	
	    when Gosu::MsLeft
			# --- select album ---
			if @page == 0
				if area_clicked(100, 50, 300, 250)
					# @album_id = 0
					close
					Albumplay.new.show if __FILE__ == $0
				end
				if area_clicked(450, 50, 650, 250)
					@album_id = 1
					close
					Albumplay.new.show if __FILE__ == $0
				end
				if area_clicked(100, 300, 300, 500) 
					# @album_id = 2
					close
					Albumplay.new.show if __FILE__ == $0
				end
				if area_clicked(450, 300, 650, 500) 
					# @album_id = 3
					close
					Albumplay.new.show if __FILE__ == $0
				end
			end
			if @page == 1
				if area_clicked(100, 50, 300, 250)
					# @album_id = 4
					close
					Albumplay.new.show if __FILE__ == $0
				end
			end
			if area_clicked(720, 250, 790, 320)
				if @page < 2
					@page +=1
				end
			end
			if area_clicked(20, 250, 90, 320)
				if @page > -1
					@page -=1
				end
			end
	    end
	end
end
Homepage.new.show 