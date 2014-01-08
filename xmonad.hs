import Data.Ratio ((%))
import XMonad
import XMonad.Config.Kde
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.IM
import XMonad.Layout.Grid
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Layout.Spacing
import XMonad.Util.EZConfig
import XMonad.Util.Run

main :: IO ()
main = do
  xmobarleft <- spawnPipe "xmobar -x 0 /home/spooky/.xmobarrc"
  xmobarright <- spawnPipe "xmobar -x 1 /home/spooky/.xmobarrightrc"
  xmonad $ withUrgencyHook NoUrgencyHook $ kde4Config
  -- xmonad $ gnomeConfig
   { terminal   = "urxvtc"
   , modMask    = mod4Mask
   , workspaces = myWorkspaces
   , manageHook = myManageHook <+> manageHook kde4Config
   , layoutHook = smartBorders $ avoidStruts $ myLayout ||| layoutHook kde4Config
   , focusFollowsMouse = False
   , logHook = dynamicLogWithPP (myPP xmobarleft) >> myLogHook >> logHook kde4Config
   }
   `additionalKeysP`
   [ ("M-g", spawn "kupfer")
   , ("M-C-b", spawn "firefox")
   , ("M-C-m", spawn "urxvtc -e mutt")
   , ("M-C-n", spawn "urxvtc -e newsbeuter")
   , ("M-C-a", spawn "urxvtc -e cmus")
   , ("M-C-e", spawn "emacs")
   , ("M-C-i", spawn "pidgin")
   , ("M-C-t", spawn "urxvtc -e task shell")
   , ("<XF86AudioPlay>", spawn "cmus-remote --pause")
   , ("<XF86AudioNext>", spawn "cmus-remote --next")
   , ("<XF86AudioPrev>", spawn "cmus-remote --prev")
   , ("<XF86AudioLowerVolume>", spawn "ponymix decrease 5")
   , ("<XF86AudioRaiseVolume>", spawn "ponymix increase 5")
   , ("<XF86AudioMute>", spawn "ponymix toggle")
   ]

myWorkspaces :: [String]
myWorkspaces = ["1:web", "2:code", "3:im", "4:mail", "5:news", "6:music", "7:scratch", "8:scratch", "9:scratch"]

myManageHook = composeAll
             [ isDialog --> doFloat
             , className =? "mplayer2" --> doFloat
             , className =? "mpv" --> doFloat
             , className =? "vlc" --> doFloat
             , className =? "feh" --> doFloat
             , className =? "Emacs" --> doShift "2:code"
             , className =? "Firefox" --> doShift "1:web"
             , className =? "Pidgin" --> doShift "3:im"
             , className =? "Wine" --> doFloat
             , title =? "newsbeuter" --> doShift "5:news"
             , title =? "ncmpcpp" --> doShift "6:music"
             , title =? "cmus" --> doShift "6:music"
             , title =? "mutt" --> doShift "4:mail"
             , title =? "plugin-container" --> doFloat
             , title =? "operapluginwrapper-native" --> doFloat
             , title =? "BlindMessageService" --> doFloat
             , className =? "viewnior" --> doFloat
             , className =? "Xfce4-notifyd" --> doIgnore
             , className =? "t-engine" --> doFloat
             , className =? "Pcsx2" --> doFloat
             , className =? "Eog" --> doFloat
             ]

myLayout = spacing 3 $ onWorkspace "3:im" imLayout $
           tiled ||| Mirror tiled ||| Full
  where
    tiled = Tall nmaster delta ratio
    nmaster = 1
    ratio = 1/2
    delta = 5/100

imLayout = reflectHoriz $ withIM (1%6) (And (ClassName "Pidgin") (Role "buddy_list")) Grid

myBar :: String
myBar = "/home/spooky/.cabal/bin/xmobar"

myPP handler = xmobarPP { ppVisible = xmobarColor "#7f9f7f" "" . wrap "[" "]"
                  , ppCurrent = xmobarColor "#dfaf8f" "" . wrap "<" ">"
                  , ppTitle = xmobarColor "#dcdccc" ""
                  , ppUrgent = xmobarColor "#dcdccc" "#cc9393"
                  , ppOutput = hPutStrLn handler
                  }

-- don't fade windows on inactive monitor
myLogHook = fadeInactiveCurrentWSLogHook 0.9
