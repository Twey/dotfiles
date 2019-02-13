{-# LANGUAGE TupleSections, UnicodeSyntax #-}

import XMonad
import XMonad.Layout.Reflect
import XMonad.Layout.NoBorders
import XMonad.Layout.Tabbed
import XMonad.Layout.Spiral
import XMonad.Layout.IM
import XMonad.Layout.Grid
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Spacing
import XMonad.Layout.Tabbed
import XMonad.Layout.LayoutCombinators hiding ((|||))
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.FadeWindows
import XMonad.Hooks.SetWMName
import XMonad.Actions.SpawnOn
import qualified XMonad.StackSet as W
import qualified Data.Map as M
import Data.Ratio
import Control.Monad
import Control.Applicative
import Control.Arrow hiding ((<+>), (|||))
import System.Exit

main = xmonad defaultConfig {
    modMask            = mod4Mask,
    terminal           = "xfce4-terminal",
    borderWidth        = 0,
    normalBorderColor  = "#000000",
    focusedBorderColor = "#ffffff",
    layoutHook         = smartBorders . avoidStruts . layouts $ layoutHook defaultConfig,
    manageHook         = manageDocks <+> windowHooks <+> manageHook defaultConfig,
    startupHook        = setWMName "LG3D",
    logHook            = fadeInactiveLogHook 0.7 >> dzenLogHook,
    workspaces         = map snd myWorkspaces,
    keys               = myKeys
--    mouseBindings      = myMouseBindings
--    focusFollowsMouse  = False
  }

dzenLogHook = return ()
myWorkspaces = concat [
   [(xK_2, "term"),
    (xK_3, "dev"),
    (xK_4, "web"),
    (xK_comma, "comms"),
    (xK_period, "media")],
   zipWith (\k → (k,) . (++) "misc" . show) [xK_p, xK_o, xK_e, xK_u, xK_q, xK_j, xK_k, xK_z] [0 .. 7]
  ]

{-
234
,.p
oeu
qjk
-}

layouts = onWorkspace "term" (spacing 5 Full ||| tall (1 / 2) ||| spacing 5 (spiral $ 1 / 2))
          . onWorkspace "web" webSpace
          . onWorkspace "comms" commSpace
          . onWorkspace "dev" (Full ||| tall (1 / 2) ||| Mirror (tall $ 1 / 2) ||| spacing 5 Grid)
          . onWorkspace "media" mediaSpace
          . onWorkspace "misc0" miscSpace
          . onWorkspace "misc1" miscSpace
          . onWorkspace "misc2" miscSpace
          . onWorkspace "misc3" miscSpace
          . onWorkspace "misc4" miscSpace
          . onWorkspace "misc5" miscSpace
          . onWorkspace "misc6" miscSpace
          . onWorkspace "status" miscSpace
  where tall = spacing 5 . Tall 1 (3 / 100)
        webSpace  = (tabbed shrinkText defaultTheme { fontName = "xft:terminus" } ***|* Full)
                ||| tabbed shrinkText defaultTheme { fontName = "xft:terminus" }
                ||| Full
        commSpace = reflectHoriz
                  . Mirror . Mirror . Mirror
                  . withIM (1 % 3) (ClassName "xfce4-terminal")
                  . Mirror
                  . withIM (1 % 5) (ClassName "Pidgin" `And` Title "Buddy List")
--                                    (Resource "empathy" `And` Role "contact_list")
                  $ spacing 5 Grid
        mediaSpace = id
                   . Mirror
                   . reflectHoriz
                   . withIM (1 % 5) (ClassName "xfce4-terminal")
                   . Mirror
                   . reflectVert
                   $ tall (1 / 2)
        miscSpace = spacing 5 Full ||| tall (1 / 2) ||| Mirror (tall $ 1 / 2) ||| spacing 5 Grid

windowHooks = composeAll [
    className =? "Pidgin"      --> doF (W.shift "comms"),
    className =? "Minefield"   --> doF (W.shift "web"),
    className =? "stalonetray" --> doIgnore
  ]

runOnWorkspace t f = runOnWorkspaces $ liftM2 (>>) (liftM2 when ((== t) . W.tag) f) return

mediaKeys = [0x1008ff14 .. 0x1008ff17]
[xK_AudioPlay, xK_AudioStop, xK_AudioPrev, xK_AudioNext] = mediaKeys

myKeys conf@XConfig{XMonad.modMask = modMask, workspaces = ws, terminal = trm}
  = M.fromList $ concat [
      -- Workspace switchin'
      (do (k, w) ← myWorkspaces
          [((modMask, k),               windows $ W.greedyView w),
           ((modMask .|. shiftMask, k), windows $ W.shift      w)]),

      -- Media controls
      zip (map (0, ) mediaKeys)
          (map (spawn . ("mpc -h \"musicaccess17@localhost\" " ++)) ["toggle", "stop", "prev", "next"]),

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
        ((modMask,               xK_BackSpace), shellPrompt amberXPConfig),
        ((modMask .|. shiftMask, xK_Escape), spawn "xkill"),
        ((modMask,               xK_l     ), spawn "xscreensaver-command --lock"),

        ((modMask,               xK_KP_Insert ), spawn "xrandr -x -y"),
        ((modMask .|. shiftMask, xK_KP_Insert ), spawn "xrandr -o normal"),
        ((0,                     0x1008ffa9   ), toggleMouse),
        ((modMask,               xK_equal     ), resetKeyboard),
        ((modMask,               xK_numbersign), spawn "setxkbmap gb")
      ]
    ]
  where dmenu_cmd = "dmenu -nb \"#f3f3ff\" -nf \"#000077\" -sb \"#ffffff\" -sf \"#0000ff\""
        mpdpass = ""
        resetKeyboard = spawn "setxkbmap us -variant dvorak -option compose:caps"

myMouseBindings XConfig { XMonad.modMask = modMask, workspaces = ws }
  = M.fromList . concat $
    [flip zip (map (const . windows . W.greedyView) ws) $
     [(modMask, button1), (modMask, button3), (modMask, button4),
      (modMask, button5), (modMask, 8), (modMask, 9),
      (modMask .|. shiftMask, button1), (modMask .|. shiftMask, button3), (modMask .|. shiftMask, button4),
      (modMask .|. shiftMask, button5), (modMask .|. shiftMask, 8), (modMask .|. shiftMask, 9)]]
