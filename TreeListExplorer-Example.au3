#cs ----------------------------------------------------------------------------

	 AutoIt Version: 3.3.18.0
	 Author:         Kanashius

	 Script Function:
		Example Script for the TreeListExplorer UDF showcasing most usages.

#ce ----------------------------------------------------------------------------
; #AutoIt3Wrapper_UseX64=Y
#include "TreeListExplorer.au3"

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
Local $idInputPathRight = GUICtrlCreateInput("", $iLeft, $iTop-$iSpace-20, $iCtrlWidth, 20)
; _GUICtrlEdit_SetReadOnly($idInputPathRight, True) ; If the Input should be readonly
Local $idTreeViewLeft = GUICtrlCreateTreeView($iLeft, $iTop, $iCtrlWidth, $iCtrlHeight)
$iTop+=$iCtrlHeight+$iSpace
Local $idListViewLeft = GUICtrlCreateListView("Filename|Modified|Size", $iLeft, $iTop, $iCtrlWidth, $iCtrlHeight, $LVS_SHOWSELALWAYS)
_GUICtrlListView_SetColumnWidth($idListViewLeft, 0, _WinAPI_GetWindowWidth(GUICtrlGetHandle($idListViewLeft))-225)
_GUICtrlListView_SetColumnWidth($idListViewLeft, 1, 120)
_GUICtrlListView_SetColumnWidth($idListViewLeft, 2, 80)
_GUICtrlListView_JustifyColumn($idListViewLeft, 2, 1)
; create right gui
Local $iLeft = $iSpace*2 + $iCtrlWidth
Local $iTop = $iSpace
GUICtrlCreateLabel("Current Folder:", $iLeft, $iTop, 75, 20)
Local $idLabelCurrentFolderRight = GUICtrlCreateLabel("", $iLeft+75, $iTop, $iCtrlWidth-75, 20)
GUICtrlCreateLabel("Selected Folder:", $iLeft, $iTop+20+$iSpace, 80, 20)
Local $idLabelSelectRight = GUICtrlCreateLabel("", $iLeft+80, $iTop+20+$iSpace, $iCtrlWidth-80, 20)
Local $idProgressRight = GUICtrlCreateProgress($iLeft, $iTop+40+$iSpace*2, $iCtrlWidth, 20)
Local $iTop = $iSpace*2+$iTopLine
Local $idTreeViewRight = GUICtrlCreateTreeView($iLeft, $iTop, $iCtrlWidth, $iCtrlHeight)
$iTop+=$iCtrlHeight+$iSpace
Global $idListViewRight = GUICtrlCreateListView("", $iLeft, $iTop, $iCtrlWidth, $iCtrlHeight, $LVS_SHOWSELALWAYS)

; Create TLE system for the left side
Local $hTLESystemLeft = __TreeListExplorer_CreateSystem($hGui);, "", Default, Default, 0)
If @error Then ConsoleWrite("__TreeListExplorer_CreateSystem left failed: "&@error&":"&@extended&@crlf)
; Add Views to TLE system
__TreeListExplorer_AddView($hTLESystemLeft, $idInputPathRight)
If @error Then ConsoleWrite("__TreeListExplorer_AddView $idInputPathRight failed: "&@error&":"&@extended&@crlf)
__TreeListExplorer_AddView($hTLESystemLeft, $idTreeViewLeft)
If @error Then ConsoleWrite("__TreeListExplorer_AddView $idTreeViewLeft failed: "&@error&":"&@extended&@crlf)
__TreeListExplorer_AddView($hTLESystemLeft, $idListViewLeft, Default, Default, Default, Default, False)
__TreeListExplorer_SetCallback($idListViewLeft, $__TreeListExplorer_Callback_ListViewPaths, "_handleListViewData")
__TreeListExplorer_SetCallback($idListViewLeft, $__TreeListExplorer_Callback_ListViewItemCreated, "_handleListViewItemCreated")
If @error Then ConsoleWrite("__TreeListExplorer_AddView $idListViewLeft failed: "&@error&":"&@extended&@crlf)

; Create TLE system for the right side
Local $hTLESystemRight = __TreeListExplorer_CreateSystem($hGui, "", "_currentFolderRight", "_selectCallback")
If @error Then ConsoleWrite("__TreeListExplorer_CreateSystem right failed: "&@error&":"&@extended&@crlf)
; Add Views to TLE system: ShowFolders=True, ShowFiles=True
__TreeListExplorer_AddView($hTLESystemRight, $idTreeViewRight, True, True)
If @error Then ConsoleWrite("__TreeListExplorer_AddView $idTreeViewRight failed 2: "&@error&":"&@extended&@crlf)
__TreeListExplorer_SetCallback($idTreeViewRight, $__TreeListExplorer_Callback_Click, "_clickCallback")
__TreeListExplorer_SetCallback($idTreeViewRight, $__TreeListExplorer_Callback_DoubleClick, "_doubleClickCallback")
__TreeListExplorer_SetCallback($idTreeViewRight, $__TreeListExplorer_Callback_Loading, "_loadingCallback")

__TreeListExplorer_AddView($hTLESystemRight, $idListViewRight, True, True, True, False)
__TreeListExplorer_SetCallback($idListViewRight, $__TreeListExplorer_Callback_Click, "_clickCallback")
__TreeListExplorer_SetCallback($idListViewRight, $__TreeListExplorer_Callback_DoubleClick, "_doubleClickCallback")
__TreeListExplorer_SetCallback($idListViewRight, $__TreeListExplorer_Callback_Loading, "_loadingCallback")
__TreeListExplorer_SetCallback($idListViewRight, $__TreeListExplorer_Callback_Filter, "_filterCallback")
If @error Then ConsoleWrite("__TreeListExplorer_AddView $idListViewRight failed: "&@error&":"&@extended&@crlf)

; Set the root directory for the right side to the users directory
__TreeListExplorer_SetRoot($hTLESystemRight, "C:\Users")
If @error Then ConsoleWrite("__TreeListExplorer_SetRoot failed: "&@error&":"&@extended&@crlf)
; Open the User profile on the right side
__TreeListExplorer_OpenPath($hTLESystemRight, @DesktopDir)
;__TreeListExplorer_OpenPath($hTLESystemRight, @UserProfileDir)
If @error Then ConsoleWrite("__TreeListExplorer_OpenPath failed: "&@error&":"&@extended&@crlf)

Local $idButtonTest = GUICtrlCreateButton("Test", $iSpace, $iSpace)

GUISetState(@SW_SHOW)

ConsoleWrite("Left root: "&__TreeListExplorer_GetRoot($hTLESystemLeft)&" Left folder: "&__TreeListExplorer_GetPath($hTLESystemLeft)&@crlf)
ConsoleWrite("Right root: "&__TreeListExplorer_GetRoot($hTLESystemRight)&" Right folder: "&__TreeListExplorer_GetPath($hTLESystemRight)&@crlf)

; Removes the TLE system and clears the Tree/Listview
; __TreeListExplorer_DeleteSystem($hTLESystemLeft)
; __TreeListExplorer_RemoveView($idTreeViewRight)

while True
	Switch GUIGetMsg()
		Case -3
			__TreeListExplorer_Shutdown()
			Exit
		Case $idButtonTest
			__TreeListExplorer_Reload($hTLESystemRight, True) ; reload all folders in the right system
			__TreeListExplorer_Reload($hTLESystemLeft, True) ; reload folder in the right system
	EndSwitch
WEnd

Func _handleListViewData($hSystem, $hView, $sPath, ByRef $arPaths)
	ReDim $arPaths[UBound($arPaths)][3] ; resize the array (and return it at the end)
	For $i=0 To UBound($arPaths)-1
		Local $sFilePath = $sPath & $arPaths[$i][0]
		$arPaths[$i][1] = __TreeListExplorer__GetTimeString(FileGetTime($sFilePath, 0)) ; add time modified
		If Not __TreeListExplorer__PathIsFolder($sFilePath) Then $arPaths[$i][2] = FileGetSize($sFilePath) ; Put size as integer numbers here to enable the default sorting
	Next
	; custom sorting could be done here as well, setting the parameter $bEnableSorting to False when adding the ListView. Sorting can then be handled by the user
	Return $arPaths
EndFunc

Func _handleListViewItemCreated($hSystem, $hView, $sPath, $sFilename, $iIndex, $bFolder)
	If Not $bFolder Then _GUICtrlListView_SetItemText($hView, $iIndex, __TreeListExplorer__GetSizeString(_GUICtrlListView_GetItemText($hView, $iIndex, 2)), 2) ; convert size in bytes to the short text form, after sorting
EndFunc

Func _currentFolderRight($hSystem, $sRoot, $sFolder, $sSelected)
	GUICtrlSetData($idLabelCurrentFolderRight, $sRoot&$sFolder&"["&$sSelected&"]")
	; ConsoleWrite("Folder "&$hSystem&": "&$sRoot&$sFolder&"["&$sSelected&"]"&@CRLF)
EndFunc

Func _selectCallback($hSystem, $sRoot, $sFolder, $sSelected)
	GUICtrlSetData($idLabelSelectRight, $sRoot&$sFolder&"["&$sSelected&"]")
	; ConsoleWrite("Select "&$hSystem&": "&$sRoot&$sFolder&"["&$sSelected&"]"&@CRLF)
EndFunc

Func _clickCallback($hSystem, $hView, $sRoot, $sFolder, $sSelected, $item)
	ConsoleWrite("Click at "&$hView&": "&$sRoot&$sFolder&"["&$sSelected&"] :"&$item&@CRLF)
	If $hView=GUICtrlGetHandle($idListViewRight) Then
		Local $sSel = _GUICtrlListView_GetSelectedIndices($hView)
		If StringInStr($sSel, "|") Then ConsoleWrite("Multiple selected items: "&$sSel&@CRLF)
	EndIf
EndFunc

Func _doubleClickCallback($hSystem, $hView, $sRoot, $sFolder, $sSelected, $item)
	ConsoleWrite("Double click at "&$hView&": "&$sRoot&$sFolder&"["&$sSelected&"] :"&$item&@CRLF)
EndFunc

Func _filterCallback($hSystem, $hView, $bIsFolder, $sPath, $sName, $sExt)
	; ConsoleWrite("Filter: "&$hSystem&" > "&$hView&" -- Folder: "&$bIsFolder&" Path: "&$sPath&" Filename: "&$sName&" Ext: "&$sExt&@crlf)
	Return $bIsFolder Or $sExt=".au3"
EndFunc

Func _loadingCallback($hSystem, $hView, $sRoot, $sFolder, $sSelected, $sPath, $bLoading)
	; ConsoleWrite("Loading "&$hSystem&": Status: "&$bLoading&" View: "&$hView&" >> "&$sRoot&$sFolder&"["&$sSelected&"] >> "&$sPath&@CRLF)
	If $bLoading Then
		Switch $hView
			Case GUICtrlGetHandle($idTreeViewLeft)
				ToolTip("Load TreeView: "&$sPath)
				;ConsoleWrite("Load: "&$hView&" >> "&$sPath&@crlf)
			Case GUICtrlGetHandle($idListViewLeft)
				ToolTip("Load ListView: "&$sPath)
				;ConsoleWrite("Load: "&$hView&" >> "&$sPath&@crlf)
			Case GUICtrlGetHandle($idListViewRight), GUICtrlGetHandle($idTreeViewRight)
				GUICtrlSetData($idProgressRight, 50)
		EndSwitch
	Else
		Switch $hView
			Case GUICtrlGetHandle($idListViewRight), GUICtrlGetHandle($idTreeViewRight)
				GUICtrlSetData($idProgressRight, 0)
		EndSwitch
		ToolTip("")
		;ConsoleWrite("Done: "&$hView&" >> "&$sPath&@crlf)
	EndIf
EndFunc
