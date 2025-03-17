#include "TreeListExplorer.au3"
#include <GuiTreeView.au3>

Global $iWidth = 1600, $iHeight = 1000, $iSpace = 5

; StartUp of the TreeListExplorer UDF (required)
__TreeListExplorer_StartUp()
If @error Then ConsoleWrite("__TreeListExplorer_StartUp failed: "&@error&":"&@extended&@crlf)

; create gui
Local $hGui = GUICreate("TreeListExplorer Example", $iWidth, $iHeight)
Local $iTopLine = 100
Local $iCtrlHeight = ($iHeight - $iTopLine)/2 - $iSpace*3, $iCtrlWidth = $iWidth/2 - $iSpace*3
; create left gui
Local $iTop = $iSpace*2+$iTopLine, $iLeft = $iSpace
Local $hTreeViewLeft = GUICtrlCreateTreeView($iLeft, $iTop, $iCtrlWidth, $iCtrlHeight)
$iTop+=$iCtrlHeight+$iSpace
Local $hListViewLeft = GUICtrlCreateListView("", $iLeft, $iTop, $iCtrlWidth, $iCtrlHeight)
; create right gui
Local $iLeft = $iSpace*2 + $iCtrlWidth
Local $iTop = $iSpace
GUICtrlCreateLabel("Current Folder:", $iLeft, $iTop, 75, 20)
Local $hLabelCurrentFolderRight = GUICtrlCreateLabel("", $iLeft+75, $iTop, $iCtrlWidth-75, 20)
Local $hProgressRight = GUICtrlCreateProgress($iLeft, $iTop+20+$iSpace, $iCtrlWidth, 20)
Local $iTop = $iSpace*2+$iTopLine
Local $hTreeViewRight = GUICtrlCreateTreeView($iLeft, $iTop, $iCtrlWidth, $iCtrlHeight)
$iTop+=$iCtrlHeight+$iSpace
Local $hListViewRight = GUICtrlCreateListView("", $iLeft, $iTop, $iCtrlWidth, $iCtrlHeight)

; Create TLE system for the left side
Local $hTLESystemLeft = __TreeListExplorer_CreateSystem($hGui)
If @error Then ConsoleWrite("__TreeListExplorer_CreateSystem failed: "&@error&":"&@extended&@crlf)
; Add Views to TLE system
__TreeListExplorer_AddView($hTLESystemLeft, $hTreeViewLeft)
If @error Then ConsoleWrite("__TreeListExplorer_AddView $hTreeView failed: "&@error&":"&@extended&@crlf)
__TreeListExplorer_AddView($hTLESystemLeft, $hListViewLeft)
If @error Then ConsoleWrite("__TreeListExplorer_AddView $hListView failed: "&@error&":"&@extended&@crlf)

; Create TLE system for the right side
Local $hTLESystemRight = __TreeListExplorer_CreateSystem($hGui, "", "_currentFolder")
If @error Then ConsoleWrite("__TreeListExplorer_CreateSystem failed: "&@error&":"&@extended&@crlf)
; Add Views to TLE system: ShowFolders=True, ShowFiles=True
__TreeListExplorer_AddView($hTLESystemRight, $hTreeViewRight, True, True, "_clickCallback", "_doubleClickCallback", "_loadingCallback", "_selectCallback")
If @error Then ConsoleWrite("__TreeListExplorer_AddView $hTreeView failed: "&@error&":"&@extended&@crlf)
__TreeListExplorer_AddView($hTLESystemRight, $hListViewRight, True, True, "_clickCallback", "_doubleClickCallback", "_loadingCallback", "_selectCallback")
If @error Then ConsoleWrite("__TreeListExplorer_AddView $hListView failed: "&@error&":"&@extended&@crlf)

; Set the root directory for the right side to the users directory
__TreeListExplorer_SetRoot($hTLESystemRight, "C:\Users")
If @error Then ConsoleWrite("__TreeListExplorer_SetRoot failed: "&@error&":"&@extended&@crlf)
; Open the User profile on the right side
__TreeListExplorer_OpenPath($hTLESystemRight, @UserProfileDir)
If @error Then ConsoleWrite("__TreeListExplorer_OpenPath failed: "&@error&":"&@extended&@crlf)

Local $idButtonTest = GUICtrlCreateButton("Test", $iSpace, $iSpace)

GUISetState(@SW_SHOW)

ConsoleWrite("Left root: "&__TreeListExplorer_GetRoot($hTLESystemLeft)&" Left folder: "&__TreeListExplorer_GetPath($hTLESystemLeft)&@crlf)
ConsoleWrite("Right root: "&__TreeListExplorer_GetRoot($hTLESystemRight)&" Right folder: "&__TreeListExplorer_GetPath($hTLESystemRight)&@crlf)

; Removes the TLE system and clears the Tree/Listview
; __TreeListExplorer_DeleteSystem($hTLESystemLeft)
; __TreeListExplorer_RemoveView($hTreeViewRight)

while True
	Local $iMsg = GUIGetMsg()
	If $iMsg=-3 Then
		__TreeListExplorer_Shutdown()
		Exit
	EndIf
	If $iMsg=$idButtonTest Then
		 __TreeListExplorer_OpenPath($hTLESystemRight, @UserProfileDir, ".bash_history")
		; ConsoleWrite("CURRENT PATH: "&__TreeListExplorer_GetPath($hTLESystemRight)&@crlf)
		;__TreeListExplorer_Reload($hTLESystemRight, True) ; reload all folders in the right system
	EndIf
WEnd

Func _currentFolder($hSystem, $sRoot, $sFolder)
	GUICtrlSetData($hLabelCurrentFolderRight, $sRoot&$sFolder)
	; ConsoleWrite("Current folder in system "&$hSystem&": "&$sRoot&$sFolder&@CRLF)
EndFunc

Func _selectCallback($hSystem, $hView, $sRoot, $sFolder)
	ConsoleWrite("Select at "&$hView&": "&$sRoot&$sFolder&@CRLF)
EndFunc

Func _clickCallback($hSystem, $hView, $sRoot, $sFolder)
	ConsoleWrite("Click at "&$hView&": "&$sRoot&$sFolder&@CRLF)
EndFunc

Func _doubleClickCallback($hSystem, $hView, $sRoot, $sFolder)
	ConsoleWrite("Double click at "&$hView&": "&$sRoot&$sFolder&@CRLF)
EndFunc

Func _loadingCallback($hSystem, $hView, $sRoot, $sFolder, $bLoading)
	If $bLoading Then
		Switch $hView
			Case GUICtrlGetHandle($hTreeViewLeft)
				ToolTip("Load TreeView: "&$sRoot&$sFolder)
				;ConsoleWrite("Load: "&$hView&" >> "&$sRoot&$sFolder&@crlf)
			Case GUICtrlGetHandle($hListViewLeft)
				ToolTip("Load ListView: "&$sRoot&$sFolder)
				;ConsoleWrite("Load: "&$hView&" >> "&$sRoot&$sFolder&@crlf)
			Case GUICtrlGetHandle($hListViewRight), GUICtrlGetHandle($hTreeViewRight)
				GUICtrlSetData($hProgressRight, 50)
		EndSwitch
	Else
		Switch $hView
			Case GUICtrlGetHandle($hListViewRight), GUICtrlGetHandle($hTreeViewRight)
				GUICtrlSetData($hProgressRight, 0)
		EndSwitch
		ToolTip("")
		;ConsoleWrite("Done: "&$hView&" >> "&$sRoot&$sFolder&@crlf)
	EndIf
EndFunc
