import XMonad 

import XMonad.Layout.Spacing

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks

import qualified XMonad.StackSet as W

import XMonad.Actions.Volume

import XMonad.Util.Run
import XMonad.Util.EZConfig

import Control.Monad

main = do
    myStatusBar <- spawnPipe "xmobar"
    spawn "setxkbmap -layout jp"
    spawn "feh --bg-scale /home/yuki/img/totori/totori_arch_B.jpg"
    spawn "xmodmap /home/yuki/.Xmodmap"
    xmonad $ defaultConfig 
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

myTerminal = "urxvt"

myWorkspaces = unique ++ map (("work" ++) . show) [1 .. 9 - length unique]
    where
      unique = ["term","web","miku"]

myLayoutHook = spacing 5 $ avoidStruts $ Full ||| myTile
    where
      myTile = Tall 1 (3/100) (1/2)

myManageHook = composeAll
                [ className =? "Urxvt" --> viewShift "term"
                , className =? "Opera" --> viewShift "web"
                , className =? "Vivaldi-preview" --> viewShift "web"
                , className =? "Mikutter.rb" --> viewShift "miku"
                , className =? "libreoffice-startcenter" --> viewShift "work"
                ]
                    where viewShift = doF . liftM2 (.) W.view W.shift

myLogHook h = 
    dynamicLogWithPP xmobarPP {
                   ppOutput = hPutStrLn h
                }

myAddKeys  = [ ((myModMask, xK_o), spawn "opera")
             , ((myModMask, xK_v), spawn "vivaldi-preview")
             , ((myModMask, xK_m), spawn "mikutter")
             , ((myModMask, xK_h), sendMessage Shrink)
             , ((myModMask, xK_l), sendMessage Expand)
             ]

myAddKeysP = [ ( "<XF86KbdBrightnessDown>"   , spawn "xbacklight -dec 1")
             , ( "<XF86KbdBrightnessUp>"     , spawn "xbacklight -inc 1")
             , ( "<XF86AudioMute>"           , toggleMute    >> return() )
             , ( "<XF86AudioLowerVolume>"    , lowerVolume 3 >> return() )
             , ( "<XF86AudioRaiseVolume>"    , raiseVolume 3 >> return() )
             , ("M-S-r", do
                       screenWorkspace 0 >>= flip whenJust (windows.W.view)
                       (windows . W.greedyView) "term"
                       screenWorkspace 1 >>= flip whenJust (windows.W.view)
                       (windows . W.greedyView) "work")
             , ("M-h", sendMessage Shrink)
             , ("M-l", sendMessage Expand)
             ]
