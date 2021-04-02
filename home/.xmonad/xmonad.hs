{-# LANGUAGE UnicodeSyntax, TupleSections, ParallelListComp #-}

import XMonad
import XMonad.Hooks.DynamicLog hiding (dzenColor)
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Layout.Spacing
import XMonad.Layout.PerWorkspace
import XMonad.Actions.PhysicalScreens
import XMonad.Actions.CycleWS
import XMonad.Layout.Tabbed
import XMonad.Layout.Spiral
import XMonad.Layout.Grid
import XMonad.Layout.Reflect
import XMonad.Layout.LayoutCombinators hiding ((|||))
import XMonad.Layout.IM
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Util.Cursor
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops
import System.IO
import Data.Ratio
import Data.Default
import qualified Data.Map as M
import qualified XMonad.StackSet as W
import Graphics.X11.ExtraTypes.XF86
import Data.Semigroup (All (..))

(⇢) = (,)

myScreens = [xK_a, xK_apostrophe, xK_semicolon]

myWorkspaces = concat [
   [(xK_2, "term"),
    (xK_3, "dev"),
    (xK_4, "web"),
    (xK_comma, "comms"),
    (xK_period, "media")],
   zipWith (\k → (k,) . (++) "misc" . show)
     [xK_p, xK_o, xK_e, xK_u, xK_q, xK_j, xK_k, xK_v, xK_z]
     [0 ..]
  ]

mediaCommands =
  [ xF86XK_AudioPlay ⇢ "toggle"
  , xF86XK_AudioStop ⇢ "stop"
  , xF86XK_AudioPrev ⇢ "prev"
  , xF86XK_AudioNext ⇢ "next" ]

($>) ∷ Functor f ⇒ f a → b → f b
($>) = flip (<$)

keyEventHook ∷ Event → X All
keyEventHook (KeyEvent { ev_event_type = t, ev_keycode = xF86XK_AudioRecord })
  | t == keyPress   = spawn "pactl set-source-mute @DEFAULT_SOURCE@ 1" $> All True
  | t == keyRelease = spawn "pactl set-source-mute @DEFAULT_SOURCE@ 0" $> All True
keyEventHook _ = return $ All True

myKeys conf@XConfig{XMonad.modMask = modMask, workspaces = ws, terminal = trm}
  = M.fromList $ concat [
      -- Workspace switchin'
      do (k, w) ← myWorkspaces
         [ (modMask, k) ⇢ windows (W.view w),
           (modMask .|. shiftMask, k) ⇢ windows (W.shift w) ],

      [ (modMask .|. mask, key) ⇢ f def n
      | (key, n) ← zip myScreens [0 ..]
      , (mask, f) ← [0 ⇢ viewScreen, shiftMask ⇢ sendToScreen]
      ],

      -- Media controls
      [ ((0, key), spawn $ "mpc -h \"musicaccess17@localhost\" " ++ cmd)
      | (key, cmd) ← mediaCommands
      ],

      [ (0, xF86XK_AudioLowerVolume) ⇢ spawn "pactl set-sink-volume @DEFAULT_SINK@ -10%"
      , (0, xF86XK_AudioRaiseVolume) ⇢ spawn "pactl set-sink-volume @DEFAULT_SINK@ +10%"
      , (0, xF86XK_AudioMute)        ⇢ spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle"
      ],

      -- Static bindings
      [
        -- Window order and focus
        (modMask,               xK_h     ) ⇢ windows W.focusUp,
        (modMask,               xK_t     ) ⇢ windows W.focusDown,
        (modMask,               xK_Tab   ) ⇢ windows W.focusDown,
        (modMask,               xK_m     ) ⇢ windows W.focusMaster,
        (modMask .|. shiftMask, xK_h     ) ⇢ windows W.swapUp,
        (modMask .|. shiftMask, xK_t     ) ⇢ windows W.swapDown,
        (modMask,               xK_Return) ⇢ windows W.swapMaster,

        -- Layout specifics
        (modMask,               xK_n    ) ⇢ sendMessage (IncMasterN 1),
        (modMask,               xK_s    ) ⇢ sendMessage (IncMasterN $ negate 1),
        (modMask .|. shiftMask, xK_n    ) ⇢ sendMessage Expand,
        (modMask .|. shiftMask, xK_s    ) ⇢ sendMessage Shrink,
        (modMask,               xK_space) ⇢ sendMessage NextLayout,
        (modMask .|. shiftMask, xK_space) ⇢ setLayout (XMonad.layoutHook conf),

        -- Actions and launchers
        (modMask,               xK_slash    ) ⇢ withFocused (windows . W.sink),
        (modMask,               xK_Delete   ) ⇢ kill,
        (modMask,               xK_Return   ) ⇢ spawn trm,
        (modMask,               xK_BackSpace) ⇢ shellPrompt promptConfig,
        (modMask .|. shiftMask, xK_Escape   ) ⇢ spawn "xkill",
        (modMask,               xK_l        ) ⇢ spawn "xscreensaver-command --lock",

        (modMask, xK_F7) ⇢ spawn "toggle-touchpad",

        (0, xF86XK_MonBrightnessUp)   ⇢ spawn "xbacklight -inc 20",
        (0, xF86XK_MonBrightnessDown) ⇢ spawn "xbacklight -dec 20"
      ]
    ]

promptConfig = greenXPConfig
  { font = myFont
  , position = Top
  , fgColor = "#aceb54"
  , height = barHeight
  }

barHeight = 35

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
        tabTheme = Theme
          { activeColor         = "#000000"
          , inactiveColor       = "#000000"
          , urgentColor         = "#000000"
          , activeBorderColor   = "#aceb54"
          , inactiveBorderColor = "#777777"
          , urgentBorderColor   = "#FF0000"
          , activeBorderWidth   = 1
          , inactiveBorderWidth = 1
          , urgentBorderWidth   = 1
          , activeTextColor     = "#FFFFFF"
          , inactiveTextColor   = "#AAAAAA"
          , urgentTextColor     = "#FF0000"
          , fontName            = myFont
          , decoWidth           = 200
          , decoHeight          = barHeight
          , windowTitleAddons   = []
          , windowTitleIcons    = []
          }

myFont = "xft:DejaVu Sans Mono"

dzenThemeBase =
  [ "-fn '" ++ myFont ++ "'"
  ]

dzenThemeXmonad = dzenThemeBase ++
  [ "-w 1920"
  , "-ta l"
  ]

dzenThemeConky = dzenThemeBase ++
  [ "-w 1920"
  , "-x 1920"
  , "-ta r"
  ]

dzenConky = "dzen2 -dock " ++ unwords dzenThemeConky
dzenXmonad = "dzen2 -dock " ++ unwords dzenThemeXmonad
conky = "conky -c ~/.xmonad/conky"

dzenColor c s = ("^fg(" ++ c ++ ")") ++ dzenEscape s ++ "^fg()"

myLogHook :: Handle -> X ()
myLogHook h = dynamicLogWithPP $ defaultPP
    { ppCurrent         = dzenColor "#aceb54" . pad
    , ppVisible         = pad
    , ppHidden          = const ""
    , ppHiddenNoWindows = const ""
    , ppUrgent          = dzenColor "red" . pad
    , ppWsSep           = ""
    , ppSep             = "|"
    , ppLayout          = const ""
    , ppTitle           = (" " ++) . dzenColor "white"
    , ppOutput          = hPutStrLn h
    }

main = do
  xmonadBar ← spawnPipe $ dzenXmonad
  systemBar ← spawnPipe $ conky ++ " | " ++ dzenConky
  putStrLn dzenXmonad
  xmonad . docks $ def
    { modMask = mod4Mask
    , terminal = "xfce4-terminal"
    , borderWidth = 0
    , layoutHook = avoidStruts . layoutMod $ layoutHook def
    , logHook = myLogHook xmonadBar
    , startupHook = do
        setWMName "LG3D"
        setDefaultCursor xC_right_ptr
    , workspaces = map snd myWorkspaces
    , keys = myKeys
    , handleEventHook = handleEventHook def <+> fullscreenEventHook <+> keyEventHook
    }
