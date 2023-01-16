#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\Pictures\Paomedia-Small-N-Flat-Key.ico
#AutoIt3Wrapper_Compression=3
#AutoIt3Wrapper_Res_Description=Rödl Dynamics Passwordmanager
#AutoIt3Wrapper_Res_Fileversion=1.0.0.3
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductVersion=1.0
#AutoIt3Wrapper_Res_CompanyName=Rödl Dynamics
#AutoIt3Wrapper_Res_LegalCopyright=Rödl Dynamics
#AutoIt3Wrapper_Res_LegalTradeMarks=Rödl Dynamics
#AutoIt3Wrapper_Res_Language=1031
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------
Opt ("MustDeclareVars",1)
; Script Start - Add your code below here
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
#include <Clipboard.au3>
#include <Crypt.au3>
#include <Array.au3>

Global $INI = @ScriptDir & "\PWDatei.txt"
Local $Algorithmus = $CALG_RC4
Global $pos = 30

; Schlüssel
Global $Key = -1
Global $height = 10
_Crypt_Startup()

;Sectionsnames beliebig vielen Sections
Global $SectionNames = IniReadSectionNames($INI)
Global $Buttons[UBound($SectionNames)]
Global $captions[UBound($SectionNames)]
Global $passwoerter[UBound($SectionNames)]
Global $passwoerterVer[UBound($passwoerter)]
Global $passwoerterEnt[UBound($passwoerterVer)]

For $n = 0 to UBound($SectionNames)-1
	$height = $height+ 50
Next

Global  $Fenster = GUICreate("Rödl Dynamics - Fast Password Copy",250,$height)

For $i = 1 to UBound($SectionNames)-1
	$captions[$i] = IniRead($INI,$SectionNames[$i],"Caption","") ; Caption zuweisung
	$passwoerter[$i] = IniRead($INI,$SectionNames[$i],"PW","") ; Passwort zuweisung
		If $captions[$i] == "" Then ; wennn die Caption leer ist
			$Buttons[$i] =  GUICtrlCreateButton("",10,9,0,0)
		ElseIf $captions[$i] <> "" and $passwoerter[$i] == "" Then ; wenn die Caption nicht leer ist aber das Passwort
			Global $eingabe = InputBox("Fehlendes passwort ","Wie lautet das Passwort für "& $captions[$i] ,"","") ; Passwort wird eingegeben
			$passwoerter[$i] = $eingabe 																	; passwort ist gleich der Eingabe
			$passwoerterVer[$i] =  _Crypt_EncryptData($passwoerter[$i], $Key,$Algorithmus,$CALG_USERKEY)	;Passwort wird verschlüsselt
			IniWrite($INI,$SectionNames[$i],"PW",$passwoerterVer[$i])										;verschlüsseltes passwort wird in die INI- Datei geschrieben
			$Buttons[$i] = GUICtrlCreateButton($captions[$i],10,$pos,230,30)								;Button wird erstellt
			$pos = $pos +50
			Exit 0			;Position des nächsten Buttons wird verschoben
		Else																							    ;
			$passwoerterVer[$i] = $passwoerter[$i]														    ;verschlüsseltes Passwort wird dem Passwort gleich gesetzt
			$Buttons[$i] = GUICtrlCreateButton($captions[$i],10,$pos,230,30)							    ;Button wird erstellt
			$pos = $pos +50																				    ;Position des neuen Buttons um 50 nach unten Verschoben
	EndIf
Next

GUISetState(@SW_SHOWNA)
While 1
	Local $nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			ExitLoop
	EndSwitch
	Local $buttonIndex = _ArraySearch($Buttons,$nMsg,1,$Buttons[0])
		If $buttonIndex > 0 Then
			$passwoerterEnt[$buttonIndex] = _Crypt_DecryptData($passwoerter[$buttonIndex],$Key,$Algorithmus)
			_ClipBoard_SetData(BinaryToString($passwoerterEnt[$buttonIndex]))
			ExitLoop
	EndIf
WEnd