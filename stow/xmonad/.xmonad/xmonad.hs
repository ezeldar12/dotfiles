-- xmonad benoit's config file. April 2.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you only override those defaults you care about.

-- system import
import XMonad hiding ((|||))
import Data.Monoid
import Data.Tuple
import System.Exit
import XMonad.Config.Desktop -- default desktopConfig
import System.IO (hClose)
import Graphics.X11.ExtraTypes.XF86

-- util import
import XMonad.Util.Run
import XMonad.Util.Dzen
import XMonad.Util.SpawnOnce

-- layout import 
import XMonad.Layout.ResizableTile
import XMonad.Layout.BinarySpacePartition
import XMonad.Layout.Tabbed
import XMonad.Layout.TwoPane
import XMonad.Layout.ThreeColumns  
import XMonad.Layout.Accordion
import XMonad.Layout.Spacing
import XMonad.Layout.NoBorders (noBorders, smartBorders)
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.Renamed 
import XMonad.Layout.Minimize
import XMonad.Layout.Column
import XMonad.Layout.Grid

-- hooks import 
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.Place
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.Minimize
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName

-- actions import 
import XMonad.Actions.Minimize
import XMonad.Actions.GridSelect(GSConfig, gridselectWindow, goToSelected, runSelectedAction, gridselectWorkspace, gridselect)
import XMonad.Actions.NoBorders
import XMonad.Actions.DynamicProjects

-- qualified imports
import qualified DBus as D
import qualified DBus.Client as D
import qualified XMonad.Layout.BoringWindows as B
import qualified Codec.Binary.UTF8.String as UTF8
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- Colours
fg        = "#ebdbb2"
bg        = "#282828"
gray      = "#a89984"
bg1       = "#3c3836"
bg2       = "#505050"
bg3       = "#665c54"
bg4       = "#7c6f64"

green     = "#b8bb26"
darkgreen = "#98971a"
red       = "#fb4934"
darkred   = "#cc241d"
yellow    = "#fabd2f"
blue      = "#83a598"
purple    = "#d3869b"
aqua      = "#8ec07c"
white     = "#eeeeee"

pur2      = "#5b51c9"
blue2     = "#2266d0"

----------------------------------------------------
-- Alert configuration with Dzen
-- -------------------------------------------------
alert = dzenConfig cfg1 . show. round
--fg and -bg colors can be changed to preference.
cfg1 = addArgs ["-fg", "#ecef4"] >=> addArgs ["-bg", "#282a36"]
   >=> addArgs ["-bg", "#282a36"] >=> addArgs ["-geometry", "200x100+540+462"]

----------------------------------------------------
-- Program Spawner set up
-- -------------------------------------------------
spawnSelectedName :: GSConfig String -> [(String, String)] -> X ()
spawnSelectedName conf lst = gridselect conf lst >>= flip whenJust spawn
-- This is a function that will take a list of strings and tranform it into a grid. A example of this function being used is the grid that appears when typing Mod-Ctrl-Shift-A.

----------------------------------------------------
-- Definitions
----------------------------------------------------
myTerminal :: String
myTerminal = "alacritty"

myBrowser :: String
myBrowser = "google-chrome"

terminalMultiplexer :: String
terminalMultiplexer = myTerminal ++ " -e bash -c 'tmux attach || tmux'"

programsMenu :: String
programsMenu = "dmenu_extended_run"

screenshooter :: String
screenshooter = ("flameshot gui")

gridPrograms :: [(String, String)]
gridPrograms =
  [ ( "google"        , "google-chrome-stable"                     )
  , ( "jupyter notebook"    , "jupyter notebook"                   )
  , ( "nitrogen"     , "nitrogen"                                  )
  , ( "transmission" , "transmission-gtk"                          )
  , ( "discord"      , "discord"                                   )                   
  , ( "dmenu"         , "dmenu_run"                        )
  ]

----------------------------------------------------------
--                  {{{Key bindings}}}
----------------------------------------------------------

-- Add, modify or remove key bindings here.
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

-- Program keybiding are defined as such :
    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn myTerminal)
    -- Spawn multiplexer
    , ((modm .|. controlMask
             .|. shiftMask  , xK_Return ), spawn terminalMultiplexer)
    -- Spawn Grid
    , ((modm .|. shiftMask
             .|. controlMask, xK_a      ), spawnSelectedName def gridPrograms)
    -- Screenshooter 
    , ((modm                , xK_Print  ), spawn $ screenshooter)
    -- Launch program menu
    , ((modm                , xK_p      ), spawn programsMenu)

-- Function keys related to Sound, Brightness are defined as such :
    -- volume keys /// xf86.
    , ((0, xF86XK_AudioMute), spawn "amixer set Master toggle")
    , ((0, xF86XK_AudioLowerVolume), spawn "amixer set Master 5%-")
    , ((0, xF86XK_AudioRaiseVolume), spawn "amixer set Master 5%+")

-- Brightness keys /// xf86. 
    , ((0, xF86XK_MonBrightnessUp), spawn "lux -a 10%")
    , ((0, xF86XK_MonBrightnessDown), spawn "lux -s 10%")

-- Rotate through the available layout algorithms
   , ((modm                , xK_space  ), sendMessage NextLayout)  -- change to the next layout.
   , ((modm .|. shiftMask  , xK_space  ), setLayout $ XMonad.layoutHook conf) -- change to the first layout.
   , ((modm                , xK_f      ), runSelectedAction def $ -- opens a grid to select layout. 
       map (\x -> (x, sendMessage $ JumpToLayout x)) layoutNames) -- grid

--
-- Windows related keybinding
--
    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)
    -- Minimize windows/Reopens minimzed windows.
    , ((modm                , xK_n      ), withFocused minimizeWindow)
    , ((modm .|. shiftMask  , xK_n      ), withLastMinimized maximizeWindowAndFocus)
    -- Windows Selector
    , ((modm                , xK_g      ), goToSelected def)
    -- Open a grid for selecting a window to focus. The window can be in any workspace!

-- Cycle the focused window	
    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)
    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)
    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )
    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

-- Moving Windows
    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)
    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )
    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

-- Shrink and Expand (move mid separation horizontaly)
    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)
    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

  -- Back to tiling if windows has been resized
    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

  -- The Master Pane is not just one window.
    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))
    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

  -- We have a Log out option! Unlike some in a certain story.
    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Rcompile and Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; killall dunst; killall polybar; xmonad --restart")


-- Gaps resizing.
    , ((modm                , xK_u      ), incScreenSpacing 5)
    , ((modm .|. shiftMask  , xK_u      ), incWindowSpacing 5)
    , ((modm                , xK_i      ), decScreenSpacing 5)
    , ((modm .|. shiftMask  , xK_i      ), decWindowSpacing 5)
    , ((modm                , xK_o      ), setScreenSpacing (Border  0  0  0  0))
    , ((modm .|. shiftMask  , xK_o      ), setWindowSpacing (Border 10 10 10 10))

-- Toggle focused windows
    , ((modm                , xK_b      ), withFocused toggleBorder)
    ]

    ++ -- (++ add list. see the "]" 2lines above? we add to this list those below.)

-- Workspaces
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
  -- grid of workspaces
    [((modm .|. shiftMask  , xK_l      ), runSelectedAction def $
         map (\x -> (show x, windows $ W.greedyView x)) (XMonad.workspaces conf))]

  -- Monitors switch
  -- [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
  --     | (key, sc) <- [(xK_e, 0), (xK_w, 1), (xK_r, 2)] -- numbers of minitors, right now : 3 (0,1,2)
  --     , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

-- Mouse bindings: default actions bound to mouse events
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
    
-- Move
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))
-- Shift master
    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

-- Resize
    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
-- Shrink and Expand using mouse.
    , ((modm, button4), (\w -> focus w >> sendMessage Shrink))
    , ((modm, button5), (\w -> focus w >> sendMessage Expand))

    , ((modm .|. shiftMask, button4), (\w -> focus w >> sendMessage MirrorShrink))
    , ((modm .|. shiftMask, button5), (\w -> focus w >> sendMessage MirrorExpand)) ]

------------------------------------------------------------------------
--                          {{{Layouts}}}
------------------------------------------------------------------------
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.

-- List of Name displayed in Polybar. Place in order of rotation. 
layoutNames :: [String]
layoutNames =
    [ "Tiled"  , "MTiled"
    , "Three"  , "MThree"
    , "TwoPane", "MTwoPane"
    , "Grid"   , "MGrid"
    , "Column" , "MColumn"
    , "Mono"   , "Full"
    ]
-- layout placed in order we want it to rotate.
myLayout = tiled ||| mirrortiled ||| three  ||| threeMirror  ||| two  ||| twoMirror
       ||| grid  ||| gridMirror  ||| column ||| columnMirror ||| mono ||| fullscreen
  where -- features of each layout are set below. Preset config from Xmonad are not used here. 

--------------------
--IMPORTANT TO UNDERSTAND >
    general2 = spacingRaw False (Border 0 0 0 0) True (Border 10 10 10 10) True
    -- Rule for gaps when windows are spawns. 
    -- The first is true or false for whether you want to automatically disable gaps when there's only one window
    -- The second is the size (top, bottom, right, left) of the gaps on the screen edges
    -- The third is true or false for whether to have screen edge gaps at all
    -- Then, similarly, you have the size of the gaps between windows and whether to enable them.
-------------------
-- FIRST LAYOUT is describe as an example. 
-- Define Template :  
--                -  NoBorders (remove all border)
--                  vs 
--                -  SmartBorders (if only one window or windows is floating, -> no borders shown)See next section.
--                   Minimize: specifiying it enables it to be used for this layout 
    gridTemplate   = minimize $ noBorders $ Grid
-- Define grid and gridMirror :(adding mirror before the LayoutTemplate will simply mirror it.)
--                   renamed : named displayed is changed 
--                   genera12: Gaps when windows are spawns are applied, see how genera12 works.
--                   avoidStruts: Makes it so the bar used doesn't collide with windows.
--                                Need the help of Docks for it to take actions when using polybar. 
--                   gridTemplate : applies it as defined. 
    grid           = renamed [Replace  "Grid"] $ general2 $ avoidStruts $        gridTemplate
    gridMirror     = renamed [Replace "MGrid"] $ general2 $ avoidStruts $ Mirror gridTemplate
-- bit of a caution: do not include avoidStrust, genera12, inside layoutTemplate. 
-- Weird things might happen. No idea why.
------------------
    tiled_template = minimize $ noBorders $ ResizableTall nmaster delta ratio []
    tiled          = renamed [Replace "Tiled" ] $ general2 $ avoidStruts $        tiled_template
    mirrortiled    = renamed [Replace "MTiled"] $ general2 $ avoidStruts $ Mirror tiled_template

    fullscreen     = renamed [Replace "Full"  ] $ minimize $ noBorders $ Full

    twoTemplate    = minimize $ noBorders $ TwoPane delta ratio
    two            = renamed [Replace "TwoPane" ] $ general2 $ avoidStruts $        twoTemplate
    twoMirror      = renamed [Replace "MTwoPane"] $ general2 $ avoidStruts $ Mirror twoTemplate

    mono           = renamed [Replace "Mono"  ] $ general2 $ avoidStruts $ minimize $ noBorders $ Full

    threeTemplate  = minimize $ noBorders $ ThreeCol nmaster (delta) (ratio)
    three          = renamed [Replace "Three" ] $ general2 $ avoidStruts $        threeTemplate
    threeMirror    = renamed [Replace "MThree"] $ general2 $ avoidStruts $ Mirror threeTemplate

    columnTemplate = minimize $ noBorders $ Column 1
    column         = renamed [Replace  "Column"] $ general2 $ avoidStruts $        columnTemplate
    columnMirror   = renamed [Replace "MColumn"] $ general2 $ avoidStruts $ Mirror columnTemplate
  
    nmaster  = 1
    delta    = 3/100
    ratio    = 1/2

------------------------------------------------------------------------
--                        {{{Window rules}}}
------------------------------------------------------------------------
-- IMPORTANT TO READ WHAT THIS SECTION IS FOR >
-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.

-- bit of nice info https://wiki.haskell.org/Xmonad/Frequently_asked_questions#I_need_to_find_the_class_title_or_some_other_X_property_of_my_program

-- >> doFloat Move the window to the floating layer. << 
-- >> doIgnore : Map the window and remove it from the WindowSet. <<
myManageHook = composeAll
    [ className =? "MPlayer"                  --> doFloat
    , className =? "Gimp"                     --> doFloat
    , className =? "Gpick"                    --> doFloat  
    , resource  =? "desktop_window"           --> doIgnore
    , resource  =? "kdesktop"                 --> doIgnore 
    , role      =? "pop-up"                   --> doFloat
    , className =? "yad"                      --> doFloat ]
  where
    role = stringProperty "WM_WINDOW_ROLE"

-- OPTIONAL--
--myManageHook' = composeOne [ isFullscreen -?> doFullFloat ]
-- http://hackage.haskell.org/package/xmonad-contrib-0.16/docs/XMonad-Hooks-ManageHelpers.html
-- This enables the windows to be describe as doFullFLoat when in fullscreen.

------------------------------------------------------------------------
--                      {{{Event handling}}}
------------------------------------------------------------------------
-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
myEventHook    = docksEventHook
             <+> fullscreenEventHook

------------------------------------------------------------------------
--                    {{{Status bars and logging}}}
------------------------------------------------------------------------
-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
--myLogHook = return()
myLogHook :: D.Client -> PP
myLogHook dbus = def
    { ppOutput = dbusOutput dbus
    , ppCurrent = wrap ("%{F" ++ blue2 ++ "} ") " %{F-}"
    , ppVisible = wrap ("%{F" ++ blue ++ "} ") " %{F-}"
    , ppUrgent = wrap ("%{F" ++ red ++ "} ") " %{F-}"
    , ppHidden = wrap " " " "
    , ppWsSep = ""
    , ppSep = " | "
    , ppTitle = myAddSpaces 25
    }
-- Emit a DBus signal on log updates
dbusOutput :: D.Client -> String -> IO ()
dbusOutput dbus str = do
    let signal = (D.signal objectPath interfaceName memberName) {
            D.signalBody = [D.toVariant $ UTF8.decodeString str]
        }
    D.emit dbus signal
  where
    objectPath = D.objectPath_ "/org/xmonad/Log"
    interfaceName = D.interfaceName_ "org.xmonad.Log"
    memberName = D.memberName_ "Update"

myAddSpaces :: Int -> String -> String
myAddSpaces len str = sstr ++ replicate (len - length sstr) ' '
 where
   sstr = shorten len str
------------------------------------------------------------------------
--                         {{{Startup hook}}}
------------------------------------------------------------------------
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do   
    spawn "$HOME/.config/polybar/themes/default/launch.sh"
    spawn "dunst"
    spawn "nm-applet"
    spawn "cbatticon"
    spawn "redshift"

------------------------------------------------------------------------
--                        {{{ xmonad config }}}
------------------------------------------------------------------------ 
myConfig = def 
    {
   --simple stuff
      terminal           = myTerminal
    , focusFollowsMouse  = True
    , clickJustFocuses   = False
    , borderWidth        = 0
    , modMask            = mod4Mask
    , workspaces         = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    , normalBorderColor  = "#555555"
    , focusedBorderColor = "#000000"
    
   -- key bindings
    , keys               = myKeys
    , mouseBindings      = myMouseBindings

   -- hooks, layouts
    , layoutHook         = myLayout 
    , manageHook         = 
                           placeHook(smart(0.5, 0.5)) -- place a floating windows at the middle of the screen
                       <+> manageDocks
                       <+> myManageHook   
                       <+> manageHook def

    , handleEventHook    = myEventHook
    , startupHook        = myStartupHook
    }
    -- logHook is handle differently in this setup. see below.
 
-------------------------------------------------------------------------
--                                {{{MAIN}}}
-------------------------------------------------------------------------                                
main :: IO ()
main = do
  dbus <- D.connectSession
  D.requestName dbus (D.busName_ "org.xmonad.Log")
    [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]

  xmonad 
    $ docks -- !not using default.
    $ withUrgencyHook NoUrgencyHook
   -- $ ewmh --  , will do futher testing to see if used/needed. 
    -- $ addDescrKeys ((myModMask, xK_F1), xMessage) myAdditionalKeys
    -- $ addDescrKeys ((myModMask, xK_F1), showKeybindings) myAdditionalKeys
    $ myConfig { logHook = dynamicLogWithPP (myLogHook dbus) }
-----------------------------------------------------------------------
--                    {{{help for keybindings}}}
-----------------------------------------------------------------------

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
