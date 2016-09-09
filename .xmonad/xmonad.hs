import XMonad

import XMonad.Config.Desktop

import XMonad.Layout.Spacing
import XMonad.Layout.TwoPane

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks

import qualified XMonad.StackSet as W

--import XMonad.Actions.Volume

import XMonad.Util.EZConfig
import XMonad.Util.Run

import Control.Monad

main = do
    myStatusBar <- spawnPipe "xmobar"
    spawn "setxkbmap -layout jp"
    spawn "feh --bg-scale /home/yuki/img/wallpapers/eMorh0s.jpg"
    spawn "compton -b"
    spawn "xmodmap /home/yuki/.Xmodmap"
    xmonad $ desktopConfig
      { modMask       = myModMask
      , terminal      = myTerminal
      , workspaces    = myWorkspaces
      , layoutHook    = myLayoutHook
      , manageHook    = manageDocks <+> myManageHook <+> manageHook defaultConfig
      , logHook       = myLogHook myStatusBar
      , normalBorderColor = "#333333"
      , focusedBorderColor = "#cd8b00"
      } `additionalKeys`  myAddKeys
        `additionalKeysP` myAddKeysP

myModMask = mod4Mask

myTerminal = "termite"

myWorkspaces = map (uncurry (++)) $ zip (unique ++ replicate (9 - length unique) "work") (map (\n -> "(" ++ show n ++ ")") [1 .. 9])
  where
    unique = ["term","web","miku"]

myLayoutHook = spacing 5 $ avoidStruts $ Full ||| TwoPane (3/100) (1/2)  ||| myTall
  where
    myTall = Tall 1 (3/100) (1/2)

myManageHook = composeAll
                  [ className =? "Opera" --> viewShift "web(2)"
                  , className =? "vivaldi-snapshot" --> viewShift "web(2)"
                  , className =? "Mikutter.rb" --> viewShift "miku(3)"
                  ]
  where viewShift = doF . liftM2 (.) W.view W.shift

myLogHook h =
    dynamicLogWithPP xmobarPP {
      ppOutput = hPutStrLn h
    }

myAddKeys  = [ ((myModMask, xK_o), spawn "opera")
             , ((myModMask, xK_v), spawn "vivaldi-snapshot")
             , ((myModMask, xK_m), spawn "mikutter")
             , ((myModMask, xK_h), sendMessage Shrink)
             , ((myModMask, xK_l), sendMessage Expand)
             ]

myAddKeysP = [ ( "<XF86KbdBrightnessDown>"   , spawn "xbacklight -dec 1")
             , ( "<XF86KbdBrightnessUp>"     , spawn "xbacklight -inc 1")
             -- , ( "<XF86AudioMute>"           , toggleMute    >> return() )
             -- , ( "<XF86AudioLowerVolume>"    , lowerVolume 3 >> return() )
             -- , ( "<XF86AudioRaiseVolume>"    , raiseVolume 3 >> return() )
             , ( "<XF86AudioMute>"           , spawn "amixer set Master toggle" )
             , ( "<XF86AudioLowerVolume>"    , spawn "amixer set Master 2-" )
             , ( "<XF86AudioRaiseVolume>"    , spawn "amixer set Master 2+" )
             ]
