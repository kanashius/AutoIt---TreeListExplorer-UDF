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
Local $hInputPathRight = GUICtrlCreateInput("", $iLeft, $iTop-$iSpace-20, $iCtrlWidth, 20)
; _GUICtrlEdit_SetReadOnly($hInputPathRight, True) ; If the Input should be readonly
Local $hTreeViewLeft = GUICtrlCreateTreeView($iLeft, $iTop, $iCtrlWidth, $iCtrlHeight)
$iTop+=$iCtrlHeight+$iSpace
Local $hListViewLeft = GUICtrlCreateListView("", $iLeft, $iTop, $iCtrlWidth, $iCtrlHeight)
; create right gui
Local $iLeft = $iSpace*2 + $iCtrlWidth
Local $iTop = $iSpace
GUICtrlCreateLabel("Current Folder:", $iLeft, $iTop, 75, 20)
Local $hLabelCurrentFolderRight = GUICtrlCreateLabel("", $iLeft+75, $iTop, $iCtrlWidth-75, 20)
GUICtrlCreateLabel("Selected Folder:", $iLeft, $iTop+20+$iSpace, 80, 20)
Local $hLabelSelectRight = GUICtrlCreateLabel("", $iLeft+80, $iTop+20+$iSpace, $iCtrlWidth-80, 20)
Local $hProgressRight = GUICtrlCreateProgress($iLeft, $iTop+40+$iSpace*2, $iCtrlWidth, 20)
Local $iTop = $iSpace*2+$iTopLine
Local $hTreeViewRight = GUICtrlCreateTreeView($iLeft, $iTop, $iCtrlWidth, $iCtrlHeight)
$iTop+=$iCtrlHeight+$iSpace
Local $hListViewRight = GUICtrlCreateListView("", $iLeft, $iTop, $iCtrlWidth, $iCtrlHeight, $LVS_SHOWSELALWAYS)

; Create TLE system for the left side
Local $hTLESystemLeft = __TreeListExplorer_CreateSystem($hGui)
If @error Then ConsoleWrite("__TreeListExplorer_CreateSystem failed: "&@error&":"&@extended&@crlf)
; Add Views to TLE system
__TreeListExplorer_AddView($hTLESystemLeft, $hInputPathRight)
If @error Then ConsoleWrite("__TreeListExplorer_AddView $hInputPathRight failed: "&@error&":"&@extended&@crlf)
__TreeListExplorer_AddView($hTLESystemLeft, $hTreeViewLeft)
If @error Then ConsoleWrite("__TreeListExplorer_AddView $hTreeView failed: "&@error&":"&@extended&@crlf)
__TreeListExplorer_AddView($hTLESystemLeft, $hListViewLeft)
If @error Then ConsoleWrite("__TreeListExplorer_AddView $hListView failed: "&@error&":"&@extended&@crlf)

; Create TLE system for the right side
Local $hTLESystemRight = __TreeListExplorer_CreateSystem($hGui, "", "_currentFolderRight", "_selectCallback")
If @error Then ConsoleWrite("__TreeListExplorer_CreateSystem failed: "&@error&":"&@extended&@crlf)
; Add Views to TLE system: ShowFolders=True, ShowFiles=True
__TreeListExplorer_AddView($hTLESystemRight, $hTreeViewRight, True, True, "_clickCallback", "_doubleClickCallback", "_loadingCallback")
If @error Then ConsoleWrite("__TreeListExplorer_AddView $hTreeView failed: "&@error&":"&@extended&@crlf)
__TreeListExplorer_AddView($hTLESystemRight, $hListViewRight, True, True, "_clickCallback", "_doubleClickCallback", "_loadingCallback")
If @error Then ConsoleWrite("__TreeListExplorer_AddView $hListView failed: "&@error&":"&@extended&@crlf)

; Set the root directory for the right side to the users directory
__TreeListExplorer_SetRoot($hTLESystemRight, "C:\Users")
If @error Then ConsoleWrite("__TreeListExplorer_SetRoot failed: "&@error&":"&@extended&@crlf)
; Open the User profile on the right side
; __TreeListExplorer_OpenPath($hTLESystemRight, @UserProfileDir)
__TreeListExplorer_OpenPath($hTLESystemRight, "")
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
		__TreeListExplorer_Reload($hTLESystemRight, True) ; reload all folders in the right system
		__TreeListExplorer_OpenPath($hTLESystemRight, @UserProfileDir, "Desktop")
	EndIf
WEnd

Func _currentFolderRight($hSystem, $sRoot, $sFolder, $sSelected)
	GUICtrlSetData($hLabelCurrentFolderRight, $sRoot&$sFolder&"["&$sSelected&"]")
	; ConsoleWrite("Folder "&$hSystem&": "&$sRoot&$sFolder&"["&$sSelected&"]"&@CRLF)
EndFunc

Func _selectCallback($hSystem, $sRoot, $sFolder, $sSelected)
	GUICtrlSetData($hLabelSelectRight, $sRoot&$sFolder&"["&$sSelected&"]")
	__TreeListExplorer__FileGetIconIndex($sRoot&$sFolder&$sSelected)
	; ConsoleWrite("Select "&$hSystem&": "&$sRoot&$sFolder&"["&$sSelected&"]"&@CRLF)
EndFunc

Func _clickCallback($hSystem, $hView, $sRoot, $sFolder, $sSelected, $item)
	ConsoleWrite("Click at "&$hView&": "&$sRoot&$sFolder&"["&$sSelected&"] :"&$item&@CRLF)
	If $hView=GUICtrlGetHandle($hListViewRight) Then
		Local $sSel = _GUICtrlListView_GetSelectedIndices($hView)
		If StringInStr($sSel, "|") Then ConsoleWrite("Multiple selected items: "&$sSel&@CRLF)
	EndIf
EndFunc

Func _doubleClickCallback($hSystem, $hView, $sRoot, $sFolder, $sSelected, $item)
	ConsoleWrite("Double click at "&$hView&": "&$sRoot&$sFolder&"["&$sSelected&"] :"&$item&@CRLF)
EndFunc

Func _loadingCallback($hSystem, $hView, $sRoot, $sFolder, $sSelected, $sPath, $bLoading)
	; ConsoleWrite("Loading "&$hSystem&": Status: "&$bLoading&" View: "&$hView&" >> "&$sRoot&$sFolder&"["&$sSelected&"] >> "&$sPath&@CRLF)
	If $bLoading Then
		Switch $hView
			Case GUICtrlGetHandle($hTreeViewLeft)
				ToolTip("Load TreeView: "&$sPath)
				;ConsoleWrite("Load: "&$hView&" >> "&$sPath&@crlf)
			Case GUICtrlGetHandle($hListViewLeft)
				ToolTip("Load ListView: "&$sPath)
				;ConsoleWrite("Load: "&$hView&" >> "&$sPath&@crlf)
			Case GUICtrlGetHandle($hListViewRight), GUICtrlGetHandle($hTreeViewRight)
				GUICtrlSetData($hProgressRight, 50)
		EndSwitch
	Else
		Switch $hView
			Case GUICtrlGetHandle($hListViewRight), GUICtrlGetHandle($hTreeViewRight)
				GUICtrlSetData($hProgressRight, 0)
		EndSwitch
		ToolTip("")
		;ConsoleWrite("Done: "&$hView&" >> "&$sPath&@crlf)
	EndIf
EndFunc
