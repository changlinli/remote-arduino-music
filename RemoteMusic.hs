import System.Hardware.Arduino as Ard
import Control.Monad.Trans (liftIO)
import Control.Monad (forever)
import qualified Config

playPauseToggle :: IO ()
playPauseToggle = writeFile Config.pianobarFIFO "p"

resetStation :: IO ()
resetStation = writeFile Config.pianobarFIFO "s3\n"

senseInputPlayPauseToggle :: Bool -> Ard.Arduino ()
senseInputPlayPauseToggle True = liftIO playPauseToggle
senseInputPlayPauseToggle False = return ()

senseInputResetStation :: Bool -> Ard.Arduino ()
senseInputResetStation True = liftIO resetStation
senseInputResetStation False = return ()

main :: IO ()
main = withArduino False Config.arduinoDevicePath $ do
        setPinMode Config.switchPin INPUT
        setPinMode Config.resetPin INPUT
        forever $ do
                x <- digitalRead Config.switchPin
                y <- digitalRead Config.resetPin
                senseInputPlayPauseToggle x
                senseInputResetStation y
                Ard.delay 500
