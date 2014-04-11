import System.Hardware.Arduino as Ard
import Control.Monad.Trans (liftIO)
import Control.Monad (forever)
import System.Cmd (system)
import qualified Config

playPauseToggle :: IO ()
playPauseToggle = writeFile Config.pianobarFIFO "p"

resetStation :: IO ()
resetStation = writeFile Config.pianobarFIFO ("s" ++ show Config.stationReset ++ "\n")

senseInputPlayPauseToggle :: Bool -> Ard.Arduino ()
senseInputPlayPauseToggle True = liftIO playPauseToggle
senseInputPlayPauseToggle False = return ()

senseInputResetStation :: Bool -> Ard.Arduino ()
senseInputResetStation True = liftIO resetStation
senseInputResetStation False = return ()

senseInputPlayPauseCmus :: Bool -> Ard.Arduino ()
senseInputPlayPauseCmus True = liftIO (system "cmus-remote -u" >>= (\x -> return ()))
senseInputPlayPauseCmus False = return ()

senseInputSkipSong :: Bool -> Ard.Arduino ()
senseInputSkipSong True = liftIO (system "cmus-remote -n" >>= (\x -> return ()))
senseInputSkipSong False = return ()

playPandora :: IO ()
playPandora = withArduino False Config.arduinoDevicePath $ do
        setPinMode Config.switchPin INPUT
        setPinMode Config.resetPin INPUT
        forever $ do
                x <- digitalRead Config.switchPin
                y <- digitalRead Config.resetPin
                senseInputPlayPauseToggle x
                senseInputResetStation y
                Ard.delay 500

playCmus :: IO ()
playCmus = withArduino False Config.arduinoDevicePath $ do
        setPinMode Config.switchPin INPUT
        setPinMode Config.resetPin INPUT
        forever $ do
                x <- digitalRead Config.switchPin
                y <- digitalRead Config.resetPin
                senseInputPlayPauseCmus x
                senseInputSkipSong y
                Ard.delay 500

main :: IO ()
main = playCmus
