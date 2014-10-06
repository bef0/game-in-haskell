{-# LANGUAGE PackageImports #-}
import "GLFW-b" Graphics.UI.GLFW as GLFW
import Graphics.Rendering.OpenGL hiding (Front)
import System.Exit ( exitSuccess )
import Control.Concurrent (threadDelay)
import Control.Monad (when, unless)

type Pos = Vector2 GLdouble
data Player = Player Pos

initialPlayer = Player (Vector2 200 200)

initGL width height = do
  clearColor $= Color4 1 1 1 1
  viewport $= (Position 0 0, Size (fromIntegral width) (fromIntegral height))
  ortho 0 (fromIntegral width) 0 (fromIntegral height) (-1) 1

main :: IO ()
main = do
    let width  = 640
        height = 480
    withWindow width height "Game-Demo" $ \win -> do
          initGL width height
          loop win initialPlayer
          exitSuccess
    where loop window state =  do
            threadDelay 20000
            pollEvents
            k <- keyIsPressed window Key'Escape
            l <- keyIsPressed window Key'Left
            r <- keyIsPressed window Key'Right
            u <- keyIsPressed window Key'Up
            d <- keyIsPressed window Key'Down
            let newState = movePlayer (l,r,u,d) state 10
            renderFrame newState window
            unless k $ loop window newState

movePlayer (True, _, _, _) (Player (Vector2 xpos ypos)) increment = Player (Vector2 (xpos - increment) ypos)
movePlayer (_, True, _, _) (Player (Vector2 xpos ypos)) increment = Player (Vector2 (xpos + increment) ypos)
movePlayer (_, _, True, _) (Player (Vector2 xpos ypos)) increment = Player (Vector2 xpos (ypos + increment))
movePlayer (_, _, _, True) (Player (Vector2 xpos ypos)) increment = Player (Vector2 xpos (ypos - increment))
movePlayer (False, False, False, False) (Player (Vector2 xpos ypos)) _ = Player (Vector2 xpos ypos)

renderFrame (Player (Vector2 xpos ypos)) window = do
   clear [ColorBuffer]
   color $ Color4 0 0 0 (1 :: GLfloat)
   let playerSize = 20 :: GLdouble
   renderPrimitive Quads $ do
        vertex $ Vertex2 (xpos - playerSize/2) (ypos - playerSize/2)
        vertex $ Vertex2 (xpos + playerSize/2) (ypos - playerSize/2)
        vertex $ Vertex2 (xpos + playerSize/2) (ypos + playerSize/2)
        vertex $ Vertex2 (xpos - playerSize/2) (ypos + playerSize/2)
   color $ Color4 1 1 1 (1 :: GLfloat)
   flush
   swapBuffers window

withWindow :: Int -> Int -> String -> (GLFW.Window -> IO ()) -> IO ()
withWindow width height title f = do
    GLFW.setErrorCallback $ Just simpleErrorCallback
    r <- GLFW.init
    when r $ do
        m <- GLFW.createWindow width height title Nothing Nothing
        case m of
          (Just win) -> do
              GLFW.makeContextCurrent m
              f win
              GLFW.setErrorCallback $ Just simpleErrorCallback
              GLFW.destroyWindow win
          Nothing -> return ()
        GLFW.terminate
  where
    simpleErrorCallback e s =
        putStrLn $ unwords [show e, show s]

keyIsPressed :: Window -> Key -> IO Bool
keyIsPressed win key = isPress `fmap` GLFW.getKey win key

isPress :: KeyState -> Bool
isPress KeyState'Pressed   = True
isPress KeyState'Repeating = True
isPress _                  = False
