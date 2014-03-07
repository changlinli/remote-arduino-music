all:
	cabal configure
	cabal build
	cabal install remote_arduino_music.cabal
