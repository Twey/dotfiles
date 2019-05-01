{-# LANGUAGE UnicodeSyntax, TupleSections, ParallelListComp #-}

import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Layout.Spacing
import XMonad.Layout.PerWorkspace
import XMonad.Actions.PhysicalScreens
import XMonad.Layout.Tabbed
import XMonad.Layout.Spiral
import XMonad.Layout.Grid
import XMonad.Layout.Reflect
import XMonad.Layout.LayoutCombinators hiding ((|||))
import XMonad.Layout.IM
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops
import System.IO
import Data.Ratio
import Data.Default
import qualified Data.Map as M
import qualified XMonad.StackSet as W

myScreens = [xK_a, xK_apostrophe, xK_semicolon]

myWorkspaces = concat [
   [(xK_2, "term"),
    (xK_3, "dev"),
    (xK_4, "web"),
    (xK_comma, "comms"),
    (xK_period, "media")],
   zipWith (\k → (k,) . (++) "misc" . show) [xK_p, xK_o, xK_e, xK_u, xK_q, xK_j, xK_k, xK_v, xK_z] [0 ..]
  ]

mediaKeys = [0x1008ff14 .. 0x1008ff17]
[xK_AudioPlay, xK_AudioStop, xK_AudioPrev, xK_AudioNext] = mediaKeys
mediaCommands = ["toggle", "stop", "prev", "next"]

displayKeys = [0x1008ff02 .. 0x1008ff03]
[xK_MonBrightnessUp, xK_MonBrightnessDown] = displayKeys

audioKeys = [0x1008ff11 .. 0x1008ff13]
[xK_AudioLowerVolume, xK_AudioMute, xK_AudioRaiseVolume] = audioKeys

myKeys conf@XConfig{XMonad.modMask = modMask, workspaces = ws, terminal = trm}
  = M.fromList $ concat [
      -- Workspace switchin'
      (do (k, w) ← myWorkspaces
          [((modMask, k),               windows $ W.greedyView w),
           ((modMask .|. shiftMask, k), windows $ W.shift      w)]),

      [((modMask .|. mask, key), f sc)
      | (key, sc) ← zip myScreens [0 ..]
      , (f, mask) ← [(viewScreen def, 0), (sendToScreen def, shiftMask)]],

      -- Media controls
      [ ((0, key), spawn $ "mpc -h \"musicaccess17@localhost\" " ++ cmd)
      | key ← mediaKeys
      | cmd ← mediaCommands ],

      [((0, xK_AudioLowerVolume), spawn $ "pactl set-sink-volume @DEFAULT_SINK@ -10%"),
       ((0, xK_AudioRaiseVolume), spawn $ "pactl set-sink-volume @DEFAULT_SINK@ +10%"),
       ((0, xK_AudioMute), spawn $ "pactl set-sink-mute @DEFAULT_SINK@ toggle")],

      -- Static bindings
      [
        -- Window order and focus
        ((modMask,               xK_h     ), windows W.focusUp),
        ((modMask,               xK_t     ), windows W.focusDown),
        ((modMask,               xK_Tab   ), windows W.focusDown),
        ((modMask,               xK_m     ), windows W.focusMaster),
        ((modMask .|. shiftMask, xK_h     ), windows W.swapUp),
        ((modMask .|. shiftMask, xK_t     ), windows W.swapDown),
        ((modMask,               xK_Return), windows W.swapMaster),

        -- Layout specifics
        ((modMask,               xK_n    ), sendMessage $ IncMasterN 1),
        ((modMask,               xK_s    ), sendMessage . IncMasterN $ negate 1),
        ((modMask .|. shiftMask, xK_n    ), sendMessage Expand),
        ((modMask .|. shiftMask, xK_s    ), sendMessage Shrink),
        ((modMask,               xK_space), sendMessage NextLayout),
        ((modMask .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf),

        -- Actions and launchers
        ((modMask,               xK_slash ), withFocused $ windows . W.sink),
        ((modMask,               xK_Delete), kill),
        ((modMask,               xK_Return), spawn trm),
        ((modMask,               xK_BackSpace), shellPrompt promptConfig),
        ((modMask .|. shiftMask, xK_Escape), spawn "xkill"),
        ((modMask,               xK_l     ), spawn "xscreensaver-command --lock"),

        ((modMask,               xK_F7), spawn "toggle-touchpad"),

        ((modMask,               xK_KP_Insert ), spawn "xrandr -x -y"),
        ((modMask .|. shiftMask, xK_KP_Insert ), spawn "xrandr -o normal"),

        ((0, xK_MonBrightnessUp), spawn "xbacklight -inc 20"),
        ((0, xK_MonBrightnessDown), spawn "xbacklight -dec 20")
      ]
    ]

promptConfig = amberXPConfig
  { font = "xft:terminus"
  , position = Top
  , fgHLight = "#ba7f1c"
  }

layoutMod = onWorkspace "term"   termSpace
          . onWorkspace "web"    webSpace
          . onWorkspace "comms"  commSpace
          . onWorkspace "dev"    devSpace
          . onWorkspace "media"  mediaSpace
          . onWorkspace "misc0"  miscSpace
          . onWorkspace "misc1"  miscSpace
          . onWorkspace "misc2"  miscSpace
          . onWorkspace "misc3"  miscSpace
          . onWorkspace "misc4"  miscSpace
          . onWorkspace "misc5"  miscSpace
          . onWorkspace "misc6"  miscSpace
          . onWorkspace "status" miscSpace
  where space = 5
        tall = smartSpacing space . Tall 1 (3 / 100)
        termSpace = spacing space Full
          ||| tall (1 / 2)
          ||| smartSpacing space (spiral $ 1 / 2)
        webSpace  = tabbed shrinkText tabTheme ***|* Full
          ||| tabbed shrinkText tabTheme
          ||| Full
        commSpace = reflectHoriz
          . Mirror . Mirror . Mirror
          . withIM (1 % 3) (ClassName "xfce4-terminal")
          . Mirror
          . withIM (1 % 5) (ClassName "Pidgin" `And` Title "Buddy List")
          $ spacing space Grid
        devSpace = Full
          ||| tall (1 / 2)
          ||| Mirror (tall $ 1 / 2)
          ||| spacing space Grid
        mediaSpace = Mirror
          . reflectHoriz
          . withIM (1 % 5) (ClassName "xfce4-terminal")
          . Mirror
          . reflectVert
          $ tall (1 / 2)
        miscSpace = smartSpacing space Full
          ||| tall (1 / 2)
          ||| Mirror (tall $ 1 / 2)
          ||| smartSpacing space Grid
        tabTheme = def { fontName = "xft:terminus" }


main = xmonad $ ewmh def
  { modMask = mod4Mask
  , terminal = "xfce4-terminal"
  , borderWidth = 0
  , layoutHook = layoutMod $ layoutHook def
  , startupHook = setWMName "LG3D"
  , workspaces = map snd myWorkspaces
  , keys = myKeys
  , handleEventHook = handleEventHook def <+> fullscreenEventHook
  }
