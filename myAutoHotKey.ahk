;              ---测试---
;----------------------------------------


;----------------------------------------

;            ---全局配置---
;========================================
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance, force
#WinActivateForce
#HotkeyInterval 20
#MaxHotkeysPerInterval 20000
#MenuMaskKey vk07
#UseHook

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode,Mouse,Screen
DetectHiddenWindows, On

;           ---引入tooltip---
;========================================
#Include, %A_ScriptDir%\libraries\tooltip.ahk

;           ---设置托盘logo---
;========================================
Menu, Tray, Icon, ./icons/ahk_logo.ico

; 		---监听虚拟桌面切换，并提示消息---
;========================================
hwnd := WinExist("ahk_pid " . DllCall("GetCurrentProcessId","Uint"))
hwnd += 0x1000 << 32

hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", A_ScriptDir . "\libraries\virtual-desktop-accessor.dll", "Ptr")

global RegisterPostMessageHookProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "RegisterPostMessageHook", "Ptr")
global GoToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GoToDesktopNumber", "Ptr")
global GetCurrentDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetCurrentDesktopNumber", "Ptr")
global MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "MoveWindowToDesktopNumber", "Ptr")

global DesktopNames := ["自习室-1", "自习室-2", "工作台-1", "工作台-2", "休息一下"]

DllCall(RegisterPostMessageHookProc, Int, hwnd, Int, 0x1400 + 30)
OnMessage(0x1400 + 30, "VWMess")
VWMess(wParam, lParam, msg, hwnd) {
  currentDesktopNumber := lParam + 1
  message := DesktopNames[currentDesktopNumber]
    ?	DesktopNames[currentDesktopNumber]
    : "桌面 " . currentDesktopNumber + 1

  _ShowTooltip(message)
}

;             ---绑定事件---
;========================================
For index, value in DesktopNames {
  wn := "#" . index
  wsn := "#+" . index
  wcn := "#^" . index
  ; MsgBox, %index%aaa
  Hotkey, %wn%, OnCurrentWindowMoveNumberedPress
  Hotkey, %wsn%, OnMoveAndSwitchNumberedPress
  Hotkey, %wcn%, OnMoveNumberedPress
}

;           ---引入 taskbar---
;========================================
#Include, %A_ScriptDir%\taskbar-top.ahk
; #Include, %A_ScriptDir%\taskbar-right.ahk
; #Include, %A_ScriptDir%\taskbar-bottom.ahk
; #Include, %A_ScriptDir%\taskbar-left.ahk

;             ---重启脚本---
;========================================
^!r::Reload

;              ---快捷---
;========================================
; 最小化活动窗口
<!Esc:: WinMinimize, A
<!b::Run https://www.baidu.com/
<!n::Run https://fanyi.baidu.com/translate
<!g::Run https://www.google.com/
<!h::Run https://translate.google.cn/
<!c::Run %ComSpec% /k cd /d `%USERPROFILE`%\Desktop
<!+c::
  Run *RunAs %ComSpec%, , UseErrorLevel
  return
!p::Run C:\Windows\System32\Control.exe
!Del::Run C:\Windows\System32\Taskmgr.exe
!x::Run C:\Windows\System32\Notepad.exe

>!k::ShiftAltTab
>!j::AltTab
>!h::
  Send ^#{Left}
  Send {Ctrl up}
  Return
>!l::
  Send ^#{right}
  Send {Ctrl up}
  Return

; 				---显示当前所在桌面---
;========================================
#Esc::
  _ShowTooltip(DesktopNames[_GetCurrentDesktopNumber()])
  Return
;    ---alt+9 | alt+0输出原始圆括号并左键一格---
;========================================
!9::
  Send {Text}()
  Send {Left}
  Return
!0::
  Send {Text})
  Return
;    ---alt+[ | alt+]输出原始方括号并左键一格---
;========================================
!VKDB::
  Send {Text}[]
  Send {Left}
  Return
!VKDD::
  Send {Text}]
  Return
;    						---alt+' | "并左键一格---
;========================================================
!VKDE::
  Send {Text}''
  Send {Left}
  Return
!+VKDE::
  Send {Text}""
  Send {Left}
  Return
;    						---alt+{ | }并左键一格---
;========================================================
!+VKDB::
  Send {Text}{}
  Send {Left}
  Return
!+VKDD::
  Send {Text}}
  Return
;    							---alt+; | :输出原始; | :---
;========================================================
!VKBA::
  Send {Text};
  Return
!+VKBA::
  Send {Text}:
  Return
;    							---alt+-输出原始_---
;========================================================
!VKBD::
  Send {Text}_
  Return
;    							---alt+\输出原始\---
;========================================================
!VKDC::
  Send {Text}\
  Return
;    							---alt+`输出原始`---
;========================================================
!`::
  Send {Text}``
  Return
;    							---alt+1输出原始!---
;========================================================
!1::
  Send {Text}!
  Return
;    							---alt+4输出原始$---
;========================================================
!4::
  Send {Text}$
  Return
;    							---alt+6输出原始^---
;========================================================
!6::
  Send {Text}^
  Return
;    							---alt+. | >输出原始. | >---
;========================================================
!VKBE::
  Send {Text}.
  Return
!+VKBE::
  Send {Text}>
  Return
;    							---alt+, | <输出原始, | <---
;========================================================
!VKBC::
  Send {Text},
  Return
!+VKBC::
  Send {Text}<>
  Sleep, 1
  Send {Left}
  Return
;    							---alt+/ | ?输出原始,/ | ?---
;========================================================
<!VKBF::
  Send {Text}/
  Return
<!+VKBF::
  Send {Text}?
  Return
;      		---]d显示当前时间---
;========================================
:*:]d::
  FormatTime, CurrentDateTime,, yyyy-M-d hh:mm:ss
  SendInput %CurrentDateTime%
  Return
;      ---鼠标5键打开应用切换模式---
;========================================
XButton2::
  Send {LWin down}{tab}{LWin up}
  Return

;          ---大写键切换输入法---
;========================================
CapsLock::
  ; SendInput {LAlt down}{Shift}{LAlt up}
  SendInput {Shift}
  Return

;         ---一键拷贝文件路径---
;========================================
<^<+c::
  Send, ^c
  ClipWait
  path = %Clipboard%
  Clipboard = %path%
  Tooltip, %path%
  Sleep, 500
  Tooltip,
  Return

;           ---获取颜色---
;========================================
~<!i::
  CoordMode, Mouse, Screen
  CoordMode, Pixel, Screen
  MouseGetPos, mouseX, mouseY
  ; 获得鼠标所在坐标，把鼠标的 X 坐标赋值给变量 mouseX ，同理 mouseY
  PixelGetColor, color, %mouseX%, %mouseY%, RGB
  ; 调用 PixelGetColor 函数，获得鼠标所在坐标的 RGB 值，并赋值给 color
  StringRight color, color, 6
  ; 截取 color（第二个 color）右边的6个字符，因为获得的值是这样的：#RRGGBB，一般我们只需要 RRGGBB 部分。把截取到的值再赋给 color（第一个 color）。
  Clipboard = #%color%
  ; 把 color 的值发送到剪贴板
  ToolTip, %Clipboard%
  Sleep, 500
  ToolTip,
  Return

;  			   ---通过vscode打开文件和文件夹---
; 			---资源管理器鼠标左/右划键切换虚拟桌面---
;========================================================
#If WinActive("ahk_exe Explorer.exe")
  WheelLeft::
    Send ^#{Left}
    Return
  WheelRight::
    Send ^#{right}
    Return
  <!v::
    WinGetActiveTitle, title
    ; 如果是在资源管理器打开的话(需要在选择中打开显示路径)
    ; If (RegExMatch(title, "^[A-Z]:\\+")) { }
    before := Clipboard
    Sleep, 1
    Send ^c
    Sleep, 1
    fileTag := FileExist(Clipboard)
    If InStr(fileTag, "D") {
      Run D:\Program Files\Microsoft VS Code\Code.exe "%Clipboard%"
      ; 否则则是文件
    } Else {
      Run D:\Program Files\Microsoft VS Code\Code.exe
      Sleep, 100
      Run D:\Program Files\Microsoft VS Code\Code.exe "%Clipboard%"
    }
    Clipboard := before
    before := ""
    Return
#If
;	 	 ---Chrome/edge 鼠标滚轮切换标签, 滚动左右键关闭标签---
;============================================================
#If WinActive("ahk_exe chrome.exe") or WinActive("ahk_exe msedge.exe")
  ~WheelUp::
    CoordMode, Mouse, Window
    MouseGetPos, xpos, ypos
    WinGetPos, X, Y, Width, Height
    ; 右上角误触区域
    closeArea := 200
    ; 标签高度
    tabHeight := 40
    ; 执行间隔
    interval := 70
    If (xpos >= 0 && xpos <= (Width - closeArea) && ypos >= 0 && ypos <= tabHeight) {
      Sleep, %interval%
      Send ^{PgUp}
    }
    Return
  ~WheelDown::
    CoordMode, Mouse, Window
    MouseGetPos, xpos, ypos
    WinGetPos, X, Y, Width, Height
    ; 右上角误触区域
    closeArea := 200
    ; 标签高度
    tabHeight := 40
    ; 执行间隔
    interval := 70
    If (xpos >= 0 && xpos <= (Width - closeArea) && ypos >= 0 && ypos <= tabHeight) {
      Sleep, %interval%
      Send ^{PgDn}
    }
    Return
  ~WheelLeft::
    CoordMode, Mouse, Window
    MouseGetPos, xpos, ypos
    WinGetPos, X, Y, Width, Height
    ; 右上角误触区域
    closeArea := 200
    ; 标签高度
    tabHeight := 40
    If (xpos >= 0 && xpos <= (Width - closeArea) && ypos >= 0 && ypos <= tabHeight) {
      Send {Esc}
      Send {Text}<<
    }
    Return
  ~WheelRight::
    CoordMode, Mouse, Window
    MouseGetPos, xpos, ypos
    WinGetPos, X, Y, Width, Height
    ; 右上角误触区域
    closeArea := 200
    ; 标签高度
    tabHeight := 40
    If (xpos >= 0 && xpos <= (Width - closeArea) && ypos >= 0 && ypos <= tabHeight) {
      Send {Esc}
      Send {Text}>>
    }
    Return
#If
;						---360浏览器滚动左右键关闭标签---
;============================================================
#If WinActive("ahk_exe 360chrome.exe")
  ~WheelLeft::
    CoordMode, Mouse, Window
    MouseGetPos, xpos, ypos
    WinGetPos, X, Y, Width, Height
    ; 用户信息高度
    infoHeight := 100
    ; 标签高度
    tabHeight := 40
    If (xpos >= 0 && xpos <= Width && ypos >= infoHeight && ypos <= (infoHeight + tabHeight)) {
      Send {Esc}
      Send {Text}<<
    }
    Return
  ~WheelRight::
    CoordMode, Mouse, Window
    MouseGetPos, xpos, ypos
    WinGetPos, X, Y, Width, Height
    ; 用户信息高度
    infoHeight := 100
    ; 标签高度
    tabHeight := 40
    If (xpos >= 0 && xpos <= Width && ypos >= infoHeight && ypos <= (infoHeight + tabHeight)) {
      Send {Esc}
      Send {Text}>>
    }
    Return
#If
; 				---------方法---------
;========================================
_MouseIsOver(WinTitle) {
  MouseGetPos,,, Win
  Return WinExist(WinTitle . " ahk_id " . Win)
}

_MoveBrightness(IndexMove) {

  VarSetCapacity(SupportedBRightness, 256, 0)
  VarSetCapacity(SupportedBRightnessSize, 4, 0)
  VarSetCapacity(BRightnessSize, 4, 0)
  VarSetCapacity(BRightness, 3, 0)

  hLCD := DllCall("CreateFile"
    , Str, "\\.\LCD"
    , UInt, 0x80000000 | 0x40000000 ;Read | Write
    , UInt, 0x1 | 0x2  ; File Read | File Write
    , UInt, 0
    , UInt, 0x3        ; open any existing file
    , UInt, 0
    , UInt, 0)

  If hLCD != -1
  {
    DevVideo := 0x00000023, BuffMethod := 0, Fileacces := 0
    NumPut(0x03, BRightness, 0, "UChar")      ; 0x01 = Set AC, 0x02 = Set DC, 0x03 = Set both
    NumPut(0x00, BRightness, 1, "UChar")      ; The AC bRightness level
    NumPut(0x00, BRightness, 2, "UChar")      ; The DC bRightness level
    DllCall("DeviceIoControl"
      , UInt, hLCD
      , UInt, (DevVideo<<16 | 0x126<<2 | BuffMethod<<14 | Fileacces) ; IOCTL_VIDEO_QUERY_DISPLAY_BRIGHTNESS
      , UInt, 0
      , UInt, 0
      , UInt, &Brightness
      , UInt, 3
      , UInt, &BrightnessSize
      , UInt, 0)

    DllCall("DeviceIoControl"
      , UInt, hLCD
      , UInt, (DevVideo<<16 | 0x125<<2 | BuffMethod<<14 | Fileacces) ; IOCTL_VIDEO_QUERY_SUPPORTED_BRIGHTNESS
      , UInt, 0
      , UInt, 0
      , UInt, &SupportedBrightness
      , UInt, 256
      , UInt, &SupportedBrightnessSize
      , UInt, 0)

    ACBRightness := NumGet(BRightness, 1, "UChar")
    ACIndex := 0
    DCBRightness := NumGet(BRightness, 2, "UChar")
    DCIndex := 0
    BufferSize := NumGet(SupportedBRightnessSize, 0, "UInt")
    MaxIndex := BufferSize-1

    loop, %BufferSize%
    {
      ThisIndex := A_Index-1
      ThisBRightness := NumGet(SupportedBRightness, ThisIndex, "UChar")
      If ACBRightness = %ThisBRightness%
        ACIndex := ThisIndex
      If DCBRightness = %ThisBRightness%
        DCIndex := ThisIndex
    }

    If DCIndex >= %ACIndex%
      BRightnessIndex := DCIndex
    Else
      BRightnessIndex := ACIndex

    BRightnessIndex += IndexMove

    If BRightnessIndex > %MaxIndex%
      BRightnessIndex := MaxIndex

    If BRightnessIndex < 0
      BRightnessIndex := 0

    NewBRightness := NumGet(SupportedBRightness, BRightnessIndex, "UChar")

    NumPut(0x03, BRightness, 0, "UChar")               ; 0x01 = Set AC, 0x02 = Set DC, 0x03 = Set both
    NumPut(NewBRightness, BRightness, 1, "UChar")      ; The AC bRightness level
    NumPut(NewBRightness, BRightness, 2, "UChar")      ; The DC bRightness level

    DllCall("DeviceIoControl"
      , UInt, hLCD
      , UInt, (DevVideo<<16 | 0x127<<2 | BuffMethod<<14 | Fileacces) ; IOCTL_VIDEO_SET_DISPLAY_BRIGHTNESS
      , UInt, &Brightness
      , UInt, 3
      , UInt, 0
      , UInt, 0
      , UInt, 0
      , Uint, 0)

    DllCall("CloseHandle", UInt, hLCD)

  }

}

_ShowTooltip(message := "") {
  params := {}
  params.message := message
  params.lifespan := 750
  ; 未定义position
  params.position := TooltipsCentered
  params.fontSize := 11
  params.fontWeight := 700
  params.fontColor := "0xFFFFFF"
  params.backgroundColor := "0x1F1F1F"
  ; 调用toast.ahk的方法
  Toast(params)
}

_GetCurrentWindowID() {
  WinGet, activeHwnd, ID, A
  explorerHwnd := WinActive("ahk_exe explorer.exe")
  if (explorerHwnd == activeHwnd) {
    WinGet, externalHwnd, ID, ahk_class CabinetWClass
    return externalHwnd
  } else {
    return activeHwnd
  }
}

; 将当前活动窗口移到桌面n
_MoveCurrentWindowToDesktop(n:=1) {
  activeHwnd := _GetCurrentWindowID()
  DllCall(MoveWindowToDesktopNumberProc, UInt, activeHwnd, UInt, n-1)
}

; 切换当前桌面为n
_ChangeDesktop(n) {
  DllCall(GoToDesktopNumberProc, Int, n-1)
}

; # + n 监听
OnCurrentWindowMoveNumberedPress() {
  _MoveCurrentWindowToDesktop(substr(A_ThisHotkey, 0, 1))
}

; # + ^ + n 监听
OnMoveNumberedPress() {
  _ChangeDesktop(substr(A_ThisHotkey, 0, 1))
}

; # + + + n 监听
OnMoveAndSwitchNumberedPress() {
  _MoveAndSwitchCurrentWindowToDesktop(substr(A_ThisHotkey, 0, 1))
}

_MoveAndSwitchCurrentWindowToDesktop(n:=1) {
  _MoveCurrentWindowToDesktop(n)
  _ChangeDesktop(n)
}

_GetCurrentDesktopNumber() {
  return DllCall(GetCurrentDesktopNumberProc) + 1
}