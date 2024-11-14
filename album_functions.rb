require 'gosu'
require 'rubygems'

class Album
	attr_accessor :title, :artist, :artwork, :tracks
	def initialize (title, artist, artwork, tracks)
		@title = title
		@artist = artist
		@artwork = artwork
		@tracks = tracks
	end
end

class Track
	attr_accessor :name, :location, :duration, :dim
	def initialize(name, location, duration, dim)
		@name = name
		@location = location
		@duration = duration
		@dim = dim
	end
end

class Dimension
	attr_accessor :leftX, :topY, :rightX, :bottomY
	def initialize(leftX, topY, rightX, bottomY)
		@leftX = leftX
		@topY = topY
		@rightX = rightX
		@bottomY = bottomY
	end
end

def read_track(song_file, indicator)
	track_name = song_file.gets.chomp
	track_location = song_file.gets.chomp
	track_duration = song_file.gets.chomp.to_f
	# --- Dimension of the track's title ---
	leftX = X_LOCATION
	topY = 50 * indicator + 80
	rightX = leftX + @track_font.text_width(track_name)
	bottomY = topY + @track_font.height()
	dim = Dimension.new(leftX, topY, rightX, bottomY)
	# --- Create a track object ---
	track = Track.new(track_name, track_location, track_duration, dim)
	return track
end

# Read all tracks of an album
def read_tracks(song_file)
	count = song_file.gets.chomp.to_i
	tracks = Array.new()
	# --- Read each track and add it into the arry ---
	i = 0
	while i < count
		track = read_track(song_file, i)
		tracks << track
		i += 1
	end
	# --- Return the tracks array ---
	return tracks
end

# Read a single album
def read_album(song_file)
	title = song_file.gets.chomp
	artist = song_file.gets.chomp
	artwork = ArtWork.new(song_file.gets.chomp)
	tracks = read_tracks(song_file)
	album = Album.new(title, artist, artwork, tracks)
	return album
end

# Read all albums
def read_albums()
	song_file = File.new("songs.txt", "r")
	count = song_file.gets.chomp.to_i
	albums = Array.new()

	i = 0
	while i < count
		album = read_album(song_file)
		albums << album
		i += 1
	  end

	song_file.close()
	return albums
end
