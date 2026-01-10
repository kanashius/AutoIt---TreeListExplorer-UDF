#cs ----------------------------------------------------------------------------

	 AutoIt Version: 3.3.18.0
	 Author:         Kanashius

	 Script Function:
		Example Script for the TreeListExplorer UDF showcasing a simple Example for an Input, TreeView and ListView.

#ce ----------------------------------------------------------------------------

#include "TreeListExplorer.au3"

; StartUp of the TreeListExplorer UDF (required)
__TreeListExplorer_StartUp()
If @error Then ConsoleWrite("__TreeListExplorer_StartUp failed: "&@error&":"&@extended&@crlf)

Global $iWidth = 800, $iHeight = 800, $iSpace = 5, $iCtrlHeight = 25, $iTop = $iSpace, $iCtrlWidth = $iWidth-2*$iSpace
Global $iLargeCtrlHeight = ($iWidth-$iSpace*4-$iCtrlHeight)/2

; create gui
Local $hGui = GUICreate("TreeListExplorer Example", $iWidth, $iHeight)
Local $idInput = GUICtrlCreateInput("", $iSpace, $iTop, $iCtrlWidth, $iCtrlHeight)
$iTop += $iCtrlHeight+$iSpace
Local $idTreeView = GUICtrlCreateTreeView($iSpace, $iTop, $iCtrlWidth, $iLargeCtrlHeight)
$iTop += $iLargeCtrlHeight+$iSpace
Local $idListView = GUICtrlCreateListView("", $iSpace, $iTop, $iCtrlWidth, $iLargeCtrlHeight)
$iTop += $iLargeCtrlHeight+$iSpace

; Create a TreeListExplorer (TLE) system, where multiple controls are connected to
Local $hTLE = __TreeListExplorer_CreateSystem($hGui, Default, "_folderOpened", "_selectionChanged")
; Add the Input control to the TLE system
__TreeListExplorer_AddView($hTLE, $idInput)
If @error Then ConsoleWrite("__TreeListExplorer_AddView $idInput failed: "&@error&":"&@extended&@crlf)
; Add the TreeView control to the TLE system
__TreeListExplorer_AddView($hTLE, $idTreeView)
If @error Then ConsoleWrite("__TreeListExplorer_AddView $idTreeView failed: "&@error&":"&@extended&@crlf)
; Add the ListView control to the TLE system
__TreeListExplorer_AddView($hTLE, $idListView)
If @error Then ConsoleWrite("__TreeListExplorer_AddView $idListView failed: "&@error&":"&@extended&@crlf)


GUISetState(@SW_SHOW)

while True
	Switch GUIGetMsg()
		Case -3
			; Shutdown of the TreeListExplorer UDF
			__TreeListExplorer_Shutdown()
			Exit
	EndSwitch
WEnd

Func _selectionChanged($hSystem, $sRoot, $sFolder, $sSelected)
	ConsoleWrite("Selected: "&$hSystem&"> "&$sRoot&$sFolder&"["&$sSelected&"]"&@crlf)
EndFunc

Func _folderOpened($hSystem, $sRoot, $sFolder, $sSelected)
	ConsoleWrite("Opened: "&$hSystem&"> "&$sRoot&$sFolder&"["&$sSelected&"]"&@crlf)
EndFunc