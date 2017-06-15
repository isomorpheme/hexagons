module Main where

import Prelude

import Color (black)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Unsafe (unsafePerformEff)
import Data.Foldable (class Foldable, foldMap)
import Data.Int (toNumber)
import Data.List (List, (..))
import Data.Maybe (isJust)
import Data.Monoid (class Monoid, mempty)
import Data.Tuple (Tuple(..))
import Graphics.Drawing (Drawing, Shape)
import Graphics.Drawing (closed) as Shape
import Graphics.Drawing (scale, translate) as Drawing
import Graphics.Canvas (CANVAS)
import Math (cos, pi, sin)

import DOM (DOM)
import Flare (UI, intSlider, numberSlider)
import Flare.Drawing (runFlareDrawing)
import Signal.Channel (CHANNEL)

import Drawing
import Generate
import Grid
import Hexagon

main :: Eff (console :: CONSOLE, dom :: DOM, channel :: CHANNEL, canvas :: CANVAS) Unit
main = runFlareDrawing "controls" "drawing" $ ui

ui :: forall e. UI e Drawing
ui = drawing
  <$> intSlider "Width" 0 20 10
  <*> intSlider "Height" 0 20 10
  <*> numberSlider "X Offset" (-10.0) 10.0 0.1 0.0
  <*> numberSlider "Y Offset" (-10.0) 10.0 0.1 0.0
  <*> numberSlider "Scale" 1.0 20.0 0.1 1.0

drawing :: Int -> Int -> Number -> Number -> Number -> Drawing
drawing w h x y s = Drawing.scale s s
  $ Drawing.translate x y
  $ drawGrid drawHex drawBool
  -- FIXME: Don't do this!!!
  $ unsafePerformEff $ runRandom $ noise shape
  where
    drawHex = const $ draw (lineColor black <> lineWidth 0.1) $ hex 0.0 0.0 1.0
    drawBool = if _ then draw (fillColor black) $ hex 0.0 0.0 0.5 else mempty
    shape = fromCoordinates (const unit) $ square Even { width: w, height: h }


drawGrid :: forall a. (Hex Int -> Drawing) -> (a -> Drawing) -> Grid a -> Drawing
drawGrid drawHex drawContents grid =
  foldMap drawItem $ (toUnfoldable grid :: List _)
  where
    drawItem (Tuple h x) =
      let coords = pixelCoords $ map toNumber h
      in Drawing.translate coords.x coords.y
        $ drawHex h <> drawContents x
