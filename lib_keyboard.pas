unit lib_keyboard;

// Issued uder MIT License from https://github.com/RJDevProjects/PrivateTouchType
//
// MIT License
//
// Copyright (c) 2019 Robert Jones
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, Math,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Platform, FMX.ImgList, FMX.Printer,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects;

type
  TKeyCallback = procedure(AASCII: Integer; AKeyType: Integer; AForm: TForm; AFieldname: String);
  TfrmKeyboard = class(TForm)
    procedure pnlCharKeyMouseEnter(Sender: TObject);
    procedure pnlCharKeyMouseLeave(Sender: TObject);
    procedure pnlImageKeyMouseEnter(Sender: TObject);
    procedure pnlCharKeyUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure pnlCharKeyDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure pnlPhysicalKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure pnlPhysicalKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
  private
    { Private declarations }
    function FindRectangleComponent(AKeyboard: TRectangle; AName: String): TRectangle;
    function FindImageComponent(AKeyboard: TRectangle; AName: String): TImage;
    function FindSkinComponent(AKey: TImage; AName: String): TObject;
    function FindLabelComponent(AKeyboard: TRectangle; AName: String): TLabel;
    function ConvertPhysicalToVirtual(AKey: Word; AKeyChar: Char; AShift: TShiftState): TObject;
    function GetASCIIFromKeyName(Sender: TObject): Integer;
    procedure ShowKeyboard(AX,AY: Single; AType,ADerivative: String; ALanguage,AKeyWidth,AKeyHeight,AWidth,AOuterWidth,AInitialPanel: Integer; AOuterBorder,AInnerBorder,AKeyBorder: Boolean; KeyCallback: TKeyCallback; AField: TComponent);
    procedure AddToKeys(AKey: String);
    procedure ProcessAKey(Sender: TObject);
    procedure CharKeyUp(Sender: TObject);
    procedure CharKeyDown(Sender: TObject);
    procedure ResetActiveKeys;
    procedure AdjustLabelPosition(AImage: TImage; AUp: Boolean);
    procedure DisplayKeyboard;
    procedure CloseKeyboard;
    procedure ShowKeyboardPopup(Sender: TObject);
    procedure HidePopupKeyboard;
    procedure SwitchKeyboard(APanel: Integer);
    procedure ShiftKeyboard;
    procedure KeyClick;
    procedure RefreshPanelColours;
    procedure SetShiftKeys(AState: Boolean);
    procedure SetToggleKey(AKey: Integer; AForm: TForm; AState: Boolean);
    procedure SetNumLockKeys(AState: Boolean);
  public
    { Public declarations }
  end;
  TKeyKeyboard = class
    function SkinNo: Integer;
    procedure SetSkinNo(AValue: Integer);
    function CurrencyShortcuts: Boolean;
    procedure SetCurrencyShortcuts(AValue: Boolean);
    function OuterWidth: Integer;
    procedure SetOuterWidth(AValue: Integer);
    function InitialPanel: Integer;
    procedure SetInitialPanel(AValue: Integer);
    function KeyBorder: Boolean;
    procedure SetKeyBorder(AValue: Boolean);
    function InnerBorder: Boolean;
    procedure SetInnerBorder(AValue: Boolean);
    function OuterBorder: Boolean;
    procedure SetOuterBorder(AValue: Boolean);
    function KeyWidth: Integer;
    procedure SetKeyWidth(AValue: Integer);
    function KeyHeight: Integer;
    procedure SetKeyHeight(AValue: Integer);
    function Language: Integer;
    procedure SetLanguage(AValue: Integer);
    function ImagePath: String;
    procedure SetImagePath(AValue: String);
    function BorderColour: Cardinal;
    procedure SetBorderColour(AValue: Cardinal);
    function InnerColour: Cardinal;
    procedure SetInnerColour(AValue: Cardinal);
    function TextColour: Cardinal;
    procedure SetTextColour(AValue: Cardinal);
    function ModifierColour: Cardinal;
    procedure SetModifierColour(AValue: Cardinal);
    function ShiftModifierColour: Cardinal;
    procedure SetShiftModifierColour(AValue: Cardinal);
    function DeadKeyColour: Cardinal;
    procedure SetDeadKeyColour(AValue: Cardinal);
    function UpColour: Cardinal;
    procedure SetUpColour(AValue: Cardinal);
    function DownColour: Cardinal;
    procedure SetDownColour(AValue: Cardinal);
    function OverColour: Cardinal;
    procedure SetOverColour(AValue: Cardinal);
    function SpaceUpColour: Cardinal;
    procedure SetSpaceUpColour(AValue: Cardinal);
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; Override;
    procedure SetKeyboard;
    procedure PresentTheKeyboard(AX,AY: Single; AType,ADerivative: String; AWidth: Integer; KeyCallback: TKeyCallback; AField: TComponent);
    procedure HideKeyboard;
  end;

var
  frmKeyboard: TfrmKeyboard;
  keyKeyboard: TKeyKeyboard;
  KeyCallbackProcedure: TKeyCallback;

// User executable functions
procedure PresentTheKeyboard(AX,AY: Single; AType,ADerivative: String; ALanguage,AKeyWidth,AKeyHeight,AWidth,AOuterWidth,AInitialPanel: Integer; AOuterBorder,AInnerBorder,AKeyBorder: Boolean; KeyCallBack: TKeyCallBack; AField: TComponent);
procedure SetTheKeyboard(ASkin: Integer; ACurrencyShortCuts: Boolean; APath: String);
procedure DestroyTheKeyboard;
procedure HideTheKeyboard;
function KeyChr(AASCII: Integer): Char;
function KeyOrd(AChar: Char): Integer;
function KeyASCII(AASCII: Integer): Integer;
function SetKeyASCII(AASCII: Integer): Integer;
function GetTabKeyNo(AField: TObject): Integer;
function FindKeyboardComponent(var AType: Integer; AForm: TForm; AName: String): TObject;

implementation

{$R *.fmx}

uses lib_keyboard_defs, lib_keyboard_fields, lib_keyboard_opsys;

{
// Add these to your uses list and all lib_keyboard....pas units to your project
uses
  lib_keyboard,lib_keyboard_defs;

// Required code for calling application

// This is a callback function executed with almost every keypress. Some are handled within the library.
// Only one keyboard can be used at at time. The lib_keyboard functions will switch from one layout to another on demand.
procedure ASCIIKeyPressed(AASCII: Integer; AKeyType: Integer; AForm: TForm; AFieldname: String);
var
  iASCII,iType: Integer;

  procedure EscKeyPressed(AField: TObject);
  begin
    // Add your code here to abandon this form or other process. Default action is to close the form.
    AForm.Close;
  end;

  procedure TabKeyPressed(ANext: Boolean; AField: TObject);
  var
    iTabNo: Integer;
  begin
    iTabNo := GetTabKeyNo(AField);
    // Add your code here to navigate to the next or previous field.
    if ANext then
    begin
      case iTabNo of
        1: begin end;
        2: begin end;
      end;
    end
    else
    begin
      case iTabNo of
        1: begin end;
        2: begin end;
      end;
    end;
  end;

begin
  iASCII := AASCII;
  with AForm do
  begin
    case AKeyType of
      // Sample of key type definitions. Full list in lib_keyboard_defs.pas
      KEY_TYPEALT: begin end; // Alt key
      KEY_TYPEF: begin end; // Function keys F1..F12;
      KEY_TYPESWIPE:
        begin
          case iASCII of
            KEY_SWIPEUP: begin end;
            KEY_SWIPEDOWN: begin end;
            KEY_SWIPELEFT: begin end;
            KEY_SWIPERIGHT: begin end;
          end;
        end;
    else
      begin
        case iASCII of
          KEY_TABNEXT:
            begin
              TabKeyPressed(True,FindKeyboardComponent(iType,AForm,AFieldname));
            end;
          KEY_TABPREVIOUS:
            begin
              TabKeyPressed(False,FindKeyboardComponent(iType,AForm,AFieldname));
            end;
          KEY_ESC:
            begin
              EscKeyPressed(FindKeyboardComponent(iType,AForm,AFieldname));
            end;
          KEY_WINDOWS: begin end; // Windows Key pressed
          KEY_MICROPHONE: begin end; // Microphone Key pressed
          KEY_PRTSCR: begin end; // Capture Screen bitmap and do something with it
        end;
      end;
    end;
  end;
end;

// Basic procedure style keyboard launch using parameters and single method. Execute on trigger of "OnEnter" event
PresentTheKeyboard(Name.Position.X, // X co-ordinate for the keyboard
                  Name.Position.Y + Name.Size.Height + 5, // Y co-cordinate for the keyboard
                  'F', // Keyboard type
                  '', // Derivative
                  44, // Language
                  0, // Key width
                  0, // Key height % of Width, 100 or 0 is same size as the width, not used when a Skin is in use
                  Round(Name.Width), // Width of the keyboard, 0 = Autosize
                  0, // Outer keyboard width
                  KEY_PANELLOWERCASE, // Initial panel, UpperCase, LowerCase or Punctuation and Special characters
                  False, // Add 1px border to keyboard
                  False, // Add 1px border to inner keyboard panel
                  True, // Keyboard border, not used when a Skin is in use
                  ASCIIKeyPressed, // Callback function
                  Name); // Field to be attached to the keyboard

// Basic initialization of the keyboard module. Place in the Form.OnCreate event
SetTheKeyboard(0, // Skin number, 0 = No skin
               True, // Use Currency symbol Alt key shortcut
               ''); // Use default folder for images

// When you are finished with the keyboard
DestroyTheKeyboard; // Tidy up and free everything keyboard related
}

constructor TKeyKeyboard.Create;
begin
  SetSkinNo(0); // No images/skin
  SetCurrencyShortcuts(True); // Ctrl+Alt+? will generate currency symbol
  SetKeyWidth(0); // 0 will auto calculatethe width based on width of keyboard defined and maximum number of keys in use
  SetKeyHeight(0); // 0 will use the same height and the key width, any other value will be the % of the key width
  SetOuterWidth(0); // width of border between key and edge of keyboard
  SetInitialPanel(KEY_PANELLOWERCASE); // initial panel when keyboard presented
  SetKeyBorder(True); // When no skin is in use add a border to each key with a 1px gap in between each key
  SetLanguage(44); // Keyboard language
  SetInnerBorder(False); // Add a 1px border to the keyboard area containing the keys
  SetOuterBorder(False); // Add a 1px border to the outer edge of the keyboard
  SetImagePath(''); // Set the folder containing the images used for the keyboard. Default is the images sub-folder
end;

destructor TKeyKeyboard.Destroy;
begin
  DestroyTheKeyboard;
end;

procedure TKeyKeyboard.SetSkinNo(AValue: Integer);
begin
  KEY_SKIN := AValue;
end;

function TKeyKeyboard.SkinNo: Integer;
begin
  Result := KEY_SKIN;
end;

procedure TKeyKeyboard.SetImagePath(AValue: String);
begin
  KEY_IMAGEPATH := AValue;
end;

function TKeyKeyboard.ImagePath: String;
begin
  Result := KEY_IMAGEPATH;
end;

procedure TKeyKeyboard.SetCurrencyShortcuts(AValue: Boolean);
begin
  KEY_CURRENCYSHORTCUTS := AValue;
end;

function TKeyKeyboard.CurrencyShortcuts: Boolean;
begin
  Result := KEY_CURRENCYSHORTCUTS;
end;

procedure TKeyKeyboard.SetKeyBorder(AValue: Boolean);
begin
  KEY_KEYBORDER := AValue;
end;

function TKeyKeyboard.KeyBorder: Boolean;
begin
  Result := KEY_KEYBORDER;
end;

procedure TKeyKeyboard.SetInnerBorder(AValue: Boolean);
begin
  KEY_INNERBORDER := AValue;
end;

function TKeyKeyboard.InnerBorder: Boolean;
begin
  Result := KEY_INNERBORDER;
end;

procedure TKeyKeyboard.SetOuterBorder(AValue: Boolean);
begin
  KEY_OUTERBORDER := AValue;
end;

function TKeyKeyboard.OuterBorder: Boolean;
begin
  Result := KEY_OUTERBORDER;
end;

function TKeyKeyboard.OuterWidth: Integer;
begin
  Result := KEY_OUTERWIDTH;
end;

procedure TKeyKeyboard.SetOuterWidth(AValue: Integer);
begin
  KEY_OUTERWIDTH := AValue;
end;

function TKeyKeyboard.InitialPanel: Integer;
begin
  Result := KEY_INITIALPANEL;
end;

procedure TKeyKeyboard.SetInitialPanel(AValue: Integer);
begin
  KEY_INITIALPANEL := AValue;
end;

function TKeyKeyboard.KeyWidth: Integer;
begin
  Result := KEY_KEYWIDTH;
end;

procedure TKeyKeyboard.SetKeyWidth(AValue: Integer);
begin
  KEY_KEYWIDTH := AValue;
end;

function TKeyKeyboard.KeyHeight: Integer;
begin
  Result := KEY_KEYHEIGHT;
end;

procedure TKeyKeyboard.SetKeyHeight(AValue: Integer);
begin
  KEY_KEYHEIGHT := AValue;
end;

function TKeyKeyboard.Language: Integer;
begin
  Result := KEY_LANGUAGE;
end;

procedure TKeyKeyboard.SetLanguage(AValue: Integer);
begin
  KEY_LANGUAGE := AValue;
end;

function TKeyKeyboard.BorderColour: Cardinal;
begin
  Result := KEY_BORDERCOLOUR;
end;

procedure TKeyKeyboard.SetBorderColour(AValue: Cardinal);
begin
  KEY_BORDERCOLOUR := AValue;
  frmKeyboard.RefreshPanelColours;
end;

function TKeyKeyboard.InnerColour: Cardinal;
begin
  Result := KEY_INNERCOLOUR;
end;

procedure TKeyKeyboard.SetInnerColour(AValue: Cardinal);
begin
  KEY_INNERCOLOUR := AValue;
  frmKeyboard.RefreshPanelColours;
end;

function TKeyKeyboard.TextColour: Cardinal;
begin
  Result := KEY_TEXTCOLOUR;
end;

procedure TKeyKeyboard.SetTextColour(AValue: Cardinal);
begin
  KEY_TEXTCOLOUR := AValue;
end;

function TKeyKeyboard.ModifierColour: Cardinal;
begin
  Result := KEY_ALTGRCOLOUR;
end;

procedure TKeyKeyboard.SetModifierColour(AValue: Cardinal);
begin
  KEY_ALTGRCOLOUR := AValue;
end;

function TKeyKeyboard.ShiftModifierColour: Cardinal;
begin
  Result := KEY_SHIFTALTGRCOLOUR;
end;

procedure TKeyKeyboard.SetShiftModifierColour(AValue: Cardinal);
begin
  KEY_SHIFTALTGRCOLOUR := AValue;
end;

function TKeyKeyboard.DeadKeyColour: Cardinal;
begin
  Result := KEY_DEADCOLOUR;
end;

procedure TKeyKeyboard.SetDeadKeyColour(AValue: Cardinal);
begin
  KEY_DEADCOLOUR := AValue;
end;

function TKeyKeyboard.UpColour: Cardinal;
begin
  Result := KEY_UPCOLOUR;
end;

procedure TKeyKeyboard.SetUpColour(AValue: Cardinal);
begin
  KEY_UPCOLOUR := AValue;
end;

function TKeyKeyboard.DownColour: Cardinal;
begin
  Result := KEY_DOWNCOLOUR;
end;

procedure TKeyKeyboard.SetDownColour(AValue: Cardinal);
begin
  KEY_DOWNCOLOUR := AValue;
end;

function TKeyKeyboard.OverColour: Cardinal;
begin
  Result := KEY_OVERCOLOUR;
end;

procedure TKeyKeyboard.SetOverColour(AValue: Cardinal);
begin
  KEY_OVERCOLOUR := AValue;
end;

procedure TKeyKeyboard.SetSpaceUpColour(AValue: Cardinal);
begin
  KEY_SPACEUPCOLOUR := AValue;
end;

function TKeyKeyboard.SpaceUpColour: Cardinal;
begin
  Result := KEY_SPACEUPCOLOUR;
end;

procedure TKeyKeyboard.SetKeyboard;
begin
  SetTheKeyboard(SkinNo,CurrencyShortcuts,ImagePath);
end;

procedure TKeyKeyboard.PresentTheKeyboard(AX,AY: Single; AType,ADerivative: String; AWidth: Integer; KeyCallback: TKeyCallback; AField: TComponent);
begin
  frmKeyboard.ShowKeyboard(AX,AY,AType,ADerivative,KEY_LANGUAGE,KEY_KEYWIDTH,KEY_KEYHEIGHT,AWidth,KEY_OUTERWIDTH,KEY_INITIALPANEL,KEY_OUTERBORDER,KEY_INNERBORDER,KEY_KEYBORDER,KeyCallback,AField);
end;

procedure TKeyKeyboard.HideKeyboard;
begin
  HideTheKeyboard;
end;

function TfrmKeyboard.ConvertPhysicalToVirtual(AKey: Word; AKeyChar: Char; AShift: TShiftState): TObject;
var
  sKey: String;
  wKey: Integer;
  oKey: TObject;
begin
  wKey := -1;
  if (AKey = KEY_SCANALT) and (ssAlt in AShift) then
  begin
    wKey := KEY_ALTGR;
    KEY_ALTGRDOWN := True;
    AddToKeys('altgr+');
    if ssShift in AShift then
    begin
      AddToKeys('shift+');
    end;
  end
  else
  begin
    if ssAlt in AShift then
    begin
      wKey := AKey;
      KEY_ALTGRDOWN := True;
      AddToKeys('altgr+');
      if ssShift in AShift then
      begin
        AddToKeys('shift+');
      end;
    end
    else
    begin
      if (AKey = KEY_SCANSHIFT) and (ssShift in AShift) then
      begin
        if not KEY_SHIFTDOWN then
        begin
          wKey := KEY_SHIFTIN;
          KEY_SHIFTDOWN := True;
        end;
      end
      else
      begin
        if ssCtrl in AShift then
        begin
          if AKey = KEY_SCANCTRL then
          begin
            wKey := KEY_CTRL;
          end
          else
          begin
            KEY_ALTGRDOWN := False;
            wKey := AKey;
          end;
        end
        else
        begin
          KEY_ALTGRDOWN := False;
          case AKey of
            0: wKey := Ord(AKeyChar);
            8: wKey := KEY_BACKSPACE;
            13: wKey := KEY_ENTER;
            16: wKey := KEY_SHIFTIN;
            17: wKey := KEY_CTRL;
            18: wKey := KEY_ALT;
            20: wKey := KEY_CAPS;
            27: wKey := KEY_ESC;
            33: wKey := KEY_PGUP;
            34: wKey := KEY_PGDN;
            35: wKey := KEY_END;
            36: wKey := KEY_HOME;
            37: wKey := KEY_CURSORLEFT;
            38: wKey := KEY_CURSORUP;
            39: wKey := KEY_CURSORRIGHT;
            40: wKey := KEY_CURSORDOWN;
            //38: wKey := KEY_CURSORNUMUP;
            //38: wKey := KEY_CURSORNUMDOWN;
            //38: wKey := KEY_CURSORNUMLEFT;
            //38: wKey := KEY_CURSORNUMRIGHT;
            //45: wKey := KEY_PRTSCR;
            45: wKey := KEY_INSERT;
            //45: wKey := KEY_NUMINSERT;
            46: wKey := KEY_DELETE;
            91: wKey := KEY_WINDOWS;
            112: wKey := KEY_F1;
            113: wKey := KEY_F2;
            114: wKey := KEY_F3;
            115: wKey := KEY_F4;
            116: wKey := KEY_F5;
            117: wKey := KEY_F6;
            118: wKey := KEY_F7;
            119: wKey := KEY_F8;
            120: wKey := KEY_F9;
            121: wKey := KEY_F10;
            122: wKey := KEY_F11;
            123: wKey := KEY_F12;
            144: wKey := KEY_NUMLOCK;
          end;
        end;
      end;
    end;
  end;
  oKey := nil;
  if wKey <> -1 then
  begin
    sKey := IntToStr(SetKeyASCII(wKey)).PadLeft(KEY_DIGITS,'0');
    if KEY_SKIN > 0 then
    begin
      case KEY_PANELNO of
        1: oKey := FindImageComponent(pnlUCKeyboard,sKey);
        2: oKey := FindImageComponent(pnlLCKeyboard,sKey);
        3: oKey := FindImageComponent(pnlPCKeyboard,sKey);
      end;
    end
    else
    begin
      case KEY_PANELNO of
        1: oKey := FindRectangleComponent(pnlUCKeyboard,sKey);
        2: oKey := FindRectangleComponent(pnlLCKeyboard,sKey);
        3: oKey := FindRectangleComponent(pnlPCKeyboard,sKey);
      end;
    end;
  end;
  Result := oKey;
end;

procedure TfrmKeyboard.pnlPhysicalKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  oKey: TObject;
begin
  ResetActiveKeys;
  if (Key = KEY_SCANSHIFT) and (KEY_SHIFTDOWN) then
  begin
    oKey := ConvertPhysicalToVirtual(Key,KeyChar,Shift);
    if oKey <> nil then
    begin
      CharKeyDown(oKey); // This will flip Shift if required
    end;
    if Key = KEY_SCANSHIFT then
    begin
      KEY_SHIFTDOWN := False;
    end;
  end;
  oKey := ConvertPhysicalToVirtual(Key,KeyChar,Shift);
  if oKey <> nil then
  begin
    CharKeyUp(oKey);
    Key := 0;
    KeyChar := #0;
  end;
end;

procedure TfrmKeyboard.pnlPhysicalKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  iKey: Integer;
  oKey: TObject;
begin
  iKey := Key;
  if (Key <> KEY_SCANALT) and (Key <> KEY_SCANSHIFT) and (Key <> KEY_SCANCTRL) then
  begin
    if ssAlt in Shift then
    begin
      if not KEY_ALTGRDOWN then
      begin
        oKey := ConvertPhysicalToVirtual(KEY_SCANALT,KeyChar,Shift);
        if oKey <> nil then
        begin
          CharKeyDown(oKey);
        end;
      end;
    end;
    if ssShift in Shift then
    begin
      if not KEY_SHIFTDOWN then
      begin
        oKey := ConvertPhysicalToVirtual(KEY_SCANSHIFT,KeyChar,Shift);
        if oKey <> nil then
        begin
          CharKeyDown(oKey);
        end;
      end;
    end;
    if ssCtrl in Shift then
    begin
      if (iKey >= 65) and (iKey <= 91) and (KEY_PANELNO = 2) then
      begin
        iKey := iKey + 32; // Ctry key always results in Uppercase chars
      end;
      oKey := ConvertPhysicalToVirtual(KEY_SCANCTRL,KeyChar,Shift);
      if oKey <> nil then
      begin
        CharKeyDown(oKey);
      end;
    end;
    oKey := ConvertPhysicalToVirtual(iKey,KeyChar,Shift);
    if oKey <> nil then
    begin
      CharKeyDown(oKey);
    end;
  end;
  // Clear the Key on KeyDown to prevent double processing. It will be processed on KeyUp if valid
  if not (ssAlt in Shift) then
  begin
    Key := 0;
    KeyChar := #0;
  end;
end;

procedure SetTheKeyboard(ASkin: Integer; ACurrencyShortCuts: Boolean; APath: String);
begin
  if not Assigned(frmKeyboard) then
  begin
    frmKeyboard := TfrmKeyboard.CreateNew(Application);
  end;
  SetKeyboardDefs(frmKeyboard,ASkin,ACurrencyShortCuts,APath);
end;

procedure PresentTheKeyboard(AX,AY: Single; AType,ADerivative: String; ALanguage,AKeyWidth,AKeyHeight,AWidth,AOuterWidth,AInitialPanel: Integer; AOuterBorder,AInnerBorder,AKeyBorder: Boolean; KeyCallBack: TKeyCallBack; AField: TComponent);
begin
  frmKeyboard.ShowKeyboard(AX,AY,UpperCase(AType),UpperCase(ADerivative),ALanguage,AKeyWidth,AKeyHeight,AWidth,AOuterWidth,AInitialPanel,AOuterBorder,AInnerBorder,AKeyBorder,KeyCallBack,AField);
end;

procedure DestroyTheKeyboard;
begin
  DestroyAndFreeKeyboard(True); // Destroy the default Virtual Keyboard
end;

procedure HideTheKeyboard;
begin
  if Assigned(pnlKeyboardPopup) then
  begin
    pnlKeyboardPopup.Visible := False;
    pnlKeyboardPopup.Parent := pnlKeyboardBase;
  end;
  if Assigned(pnlUCKeyboard) then
  begin
    pnlUCKeyboard.Visible := False;
  end;
  if Assigned(pnlLCKeyboard) then
  begin
    pnlLCKeyboard.Visible := False;
  end;
  if Assigned(pnlPCKeyboard) then
  begin
    pnlPCKeyboard.Visible := False;
  end;
  if Assigned(pnlKeyboardBase) then
  begin
    pnlKeyboardBase.Visible := False;
  end;
end;

function GetTabKeyNo(AField: TObject): Integer;
begin
  Result := FieldGetTabKeyNo(AField);
end;

function KeyOrd(AChar: Char): Integer;
begin
  Result := Ord(AChar);
end;

function KeyChr(AASCII: Integer): Char;
begin
  Result := Chr(KeyASCII(AASCII));
end;

function KeyASCII(AASCII: Integer): Integer;
var
  iASCII: Integer;
begin
  iASCII := AASCII;
  if iASCII > -1 then
  begin
    iASCII := KEY_SCRAMBLE[AASCII];
  end;
  Result := iASCII;
end;

function SetKeyASCII(AASCII: Integer): Integer;
var
  i,j: Integer;
  sValue: String;
begin
  j := AASCII;
  if j > 0 then
  begin
    sValue := IntToStr(AASCII);
    i := sKeyboardMap.IndexOf(sValue);
    if i > -1 then // Found existing mapped character
    begin
      j := KEY_MAP[i];
    end
    else
    begin
      i := 0;
      j := 0;
      while i <> -1 do // Generate a unique random number
      begin
        j := RandomRange(1,2000);
        if KEY_SCRAMBLE[j] = 0 then
        begin
          i := -1;
        end;
      end;
      sKeyboardMap.Add(sValue);
      i := sKeyboardMap.IndexOf(sValue);
      KEY_MAP[i] := j;
      KEY_SCRAMBLE[j] := AASCII;
    end;
  end;
  Result := j;
end;

function FindKeyboardComponent(var AType: Integer; AForm: TForm; AName: String): TObject;
var
  bReadOnly: Boolean;
  iCase: Integer;
begin
  Result := FieldFindComponent(bReadOnly,iCase,AType,AForm,AName);
end;

procedure TfrmKeyboard.ShowKeyboardPopup(Sender: TObject);
var
  iX,iY: Integer;
  pnlImage: TImage;
begin
  iX := -1;
  iY := -1;
  if Sender is TRectangle then
  begin
    iX := Round(TRectangle(Sender).Position.X);
    iY := Round(TRectangle(Sender).Position.Y + TRectangle(Sender).Size.Height);
  end
  else
  begin
    if Sender is TImage then
    begin
      pnlImage := TImage(Sender);
      if Copy(pnlImage.Name,1,3) = 'img' then
      begin
        pnlImage := TImage(pnlImage.Parent);
      end;
      iX := Round(pnlImage.Position.X);
      iY := Round(pnlImage.Position.Y + pnlImage.Size.Height);
    end;
  end;
  if (iX > -1) and (iY > -1) then
  begin
    if (iX + pnlKeyboardPopup.Size.Width) > pnlKeyboardBase.Size.Width then
    begin
      pnlKeyboardPopup.Position.X := pnlKeyboardBase.Size.Width - pnlKeyboardPopup.Size.Width;
    end
    else
    begin
      pnlKeyboardPopup.Position.X := iX;
    end;
    if (iY - pnlKeyboardPopup.Size.Height) > 0 then
    begin
      pnlKeyboardPopup.Position.Y := iY - pnlKeyboardPopup.Size.Height;
    end
    else
    begin
      pnlKeyboardPopup.Position.Y := 0;
    end;
    case KEY_PANELNO of
      1: pnlKeyboardPopup.Parent := pnlUCKeyboard;
      2: pnlKeyboardPopup.Parent := pnlLCKeyboard;
      3: pnlKeyboardPopup.Parent := pnlPCKeyboard;
    end;
    pnlKeyboardPopup.Visible := True;
  end;
end;

function TfrmKeyboard.FindRectangleComponent(AKeyboard: TRectangle; AName: String): TRectangle;
var
  i: Integer;
begin
  Result := nil;
  if AKeyboard.ChildrenCount > 0 then
  begin
    i := 0;
    while (i < AKeyboard.ChildrenCount) and (Result = nil) do
    begin
      if AKeyboard.Children[i].Name = AName then
      begin
        if AKeyboard.Children[i] is TRectangle then
        begin
          Result := AKeyboard.Children[i] as TRectangle;
        end;
      end;
      i := i + 1;
    end;
  end;
end;

function TfrmKeyboard.FindImageComponent(AKeyboard: TRectangle; AName: String): TImage;
var
  i: Integer;
  sKeyName: String;
  bPartial: Boolean;
begin
  Result := nil;
  if AKeyboard.ChildrenCount > 0 then
  begin
    i := 0;
    bPartial := (Length(AName) = KEY_DIGITS);
    while (i < AKeyboard.ChildrenCount) and (Result = nil) do
    begin
      if bPartial then
      begin
        sKeyName := AKeyboard.Children[i].Name;
        if Copy(sKeyName,Length(sKeyName) - KEY_DIGITS + 1,KEY_DIGITS) = AName then
        begin
          if AKeyboard.Children[i] is TImage then
          begin
            Result := AKeyboard.Children[i] as TImage;
          end;
        end;
      end
      else
      begin
       if AKeyboard.Children[i].Name = AName then
        begin
          if AKeyboard.Children[i] is TImage then
          begin
            Result := AKeyboard.Children[i] as TImage;
          end;
        end;
      end;
      i := i + 1;
    end;
  end;
end;

function TfrmKeyboard.FindSkinComponent(AKey: TImage; AName: String): TObject;
var
  i: Integer;
begin
  Result := nil;
  if AKey.ChildrenCount > 0 then
  begin
    i := 0;
    while (i < AKey.ChildrenCount) and (Result = nil) do
    begin
      if AKey.Children[i].Name = AName then
      begin
        if AKey.Children[i] is TImage then
        begin
          Result := AKey.Children[i] as TImage;
        end
        else
        begin
          if AKey.Children[i] is TLabel then
          begin
            Result := AKey.Children[i] as TLabel;
          end;
        end;
      end;
      i := i + 1;
    end;
  end;
end;

function TfrmKeyboard.FindLabelComponent(AKeyboard: TRectangle; AName: String): TLabel;
var
  i: Integer;
begin
  Result := nil;
  if AKeyboard.ChildrenCount > 0 then
  begin
    i := 0;
    while (i < AKeyboard.ChildrenCount) and (Result = nil) do
    begin
      if AKeyboard.Children[i].Name = AName then
      begin
        if AKeyboard.Children[i] is TLabel then
        begin
          Result := AKeyboard.Children[i] as TLabel;
        end;
      end;
      i := i + 1;
    end;
  end;
end;

procedure TfrmKeyboard.ShowKeyboard(AX,AY: Single; AType,ADerivative: String; ALanguage,AKeyWidth,AKeyHeight,AWidth,AOuterWidth,AInitialPanel: Integer; AOuterBorder,AInnerBorder,AKeyBorder: Boolean; KeyCallback: TKeyCallback; AField: TComponent);
var
  i,j,iLeft,iLeftCol,iRightCol,iTopRow,iMaxKeys,iKeyWidth,iKeyHeight,iOffset,iKeyNo: Integer;
  sRows: TStringList;
  sPanelType,sSet,sImageName: String;
  ScreenSvc: IFMXScreenService;

  function FindFormOwner(AField: TComponent): TForm;
  begin
    Result := nil;
    if AField.Owner is TForm then
    begin
      Result := TForm(AField.Owner);
    end;
  end;

  procedure SetBorder(ARectangle: TRectangle; AKey,ABorder,ASimple: Boolean);
  begin
    if KEY_SKIN = 0 then
    begin
      if ABorder then
      begin
        if AKey then
        begin
          ARectangle.Size.Width := ARectangle.Size.Width - 2;
          ARectangle.Size.Height := ARectangle.Size.Height - 2;
          ARectangle.Position.X := ARectangle.Position.X + 1;
          ARectangle.Position.Y := ARectangle.Position.Y + 1;
        end;
        ARectangle.Sides := [TSide(0),TSide(1),TSide(2),TSide(3)];
      end
      else
      begin
        if ASimple then
        begin
          ARectangle.Sides := [TSide(0),TSide(1),TSide(2),TSide(3)];
        end
        else
        begin
          ARectangle.Sides := [];
        end;
      end;
    end
    else
    begin
      ARectangle.Sides := [];
    end;
  end;

  procedure AddCharKey(AKeyCount: Integer; ARowCount: Integer; AParent: TRectangle; ASet: String; ACharNo,AShiftCharNo,AAltCharNo,AAltGrCharNo: Integer; AKeyType: String);
  var
    sChar,sShiftChar,sAltChar,sAltGrChar,sCharNo,sShiftCharNo,sAltCharNo,sAltGrCharNo,sName,sShiftName: String;
    pnlCharKey: TRectangle;
    imgCharKey,pnlSkinKey: TImage;
    iFontOffset: Integer;

    function SetFontOffset(AOffset: Integer): Integer;
    var
      iOffset: Integer;
    begin
      iOffset := AOffset;
      if Length(sChar) = 1 then
      begin
        iOffset := 0;
      end
      else
      begin
        if KEY_SKIN > 0 then
        begin
          if KEY_FONTSIZE <= 20 then
          begin
            iOffset := Round(iOffset * 0.50);
          end
          else
          begin
            if KEY_FONTSIZE >= 45 then
            begin
              iOffset := iOffset + 8;
            end
            else
            begin
              if KEY_FONTSIZE >= 35 then
              begin
                iOffset := iOffset + 6;
              end
              else
              begin
                if KEY_FONTSIZE >= 25 then
                begin
                  iOffset := iOffset + 2;
                end;
              end;
            end;
          end;
        end
        else
        begin
          if KEY_FONTSIZE <= 10 then
          begin
            iOffset := Round(iOffset * 0.25);
          end
          else
          begin
            if KEY_FONTSIZE <= 20 then
            begin
              iOffset := Round(iOffset * 0.50);
            end
            else
            begin
              if KEY_FONTSIZE <= 30 then
              begin
                iOffset := 0;
              end;
            end;
          end;
        end;
      end;
      Result := iOffset;
    end;

    procedure ConvertBitmap(ABitmap: TBitmap; AColour,AFrameColour: TAlphaColor);
    var
      x,y: Integer;
      bChangeFrame,bChangeModifier: Boolean;
      vPixelColor: TAlphaColor;
      Bitdata: TBitmapData;
    begin
      bChangeFrame := False;
      bChangeModifier := False;
      if AColour <> KEY_MODIFIERTYPEBASE then
      begin
        bChangeModifier := True;
      end;
      if AFrameColour <> TAlphaColors.Black then
      begin
        bChangeFrame := True;
      end;
      if (ABitmap.Map(TMapAccess.ReadWrite,Bitdata)) then
      begin
        try
          for x := 0 to ABitmap.Width - 1 do
          begin
            for y := 0 to ABitmap.Height - 1 do
            begin
              vPixelColor := Bitdata.GetPixel(x,y);
              if bChangeFrame then
              begin
                if vPixelColor = TAlphaColors.Black then
                begin
                  Bitdata.SetPixel(x,y,AFrameColour);
                end;
              end;
              if bChangeModifier then
              begin
                if TAlphaColorRec.ColorToRGB(vPixelColor) = TAlphaColorRec.ColorToRGB(KEY_MODIFIERTYPEBASE) then
                begin
                  Bitdata.SetPixel(x,y,AColour);
                end;
              end;
            end;
          end;
        finally
          ABitmap.Unmap(Bitdata);
        end;
      end;
    end;

    procedure AddCharKeyLabel(AName,ALabel,AChar: String; ACharNo,AFontOffset: Integer);
    var
      sName,sImageName,sCharName: String;
      lblCharKey: TLabel;
      imgCharKey: TImage;
      bSetBold,bImage: Boolean;
      iScaleKeyCount,xpOffset,ypOffset: Integer;
    begin
      bImage := False;
      xpOffset := 10;
      ypOffset := 12;
      sCharName := IntToStr(KeyASCII(ACharNo)).PadLeft(KEY_DIGITS,'0');
      sImageName := KEY_IMAGEPATH + 'key-' + sCharName + '0.png';
      if FileExists(sImageName) then // So an "image/modifier" related key
      begin
        bImage := True;
        // Look for override image for this skin
        if FileExists(KEY_IMAGEPATH + 'key-' + sCharName + IntToStr(KEY_SKIN) + '.png') then
        begin
          sImageName := KEY_IMAGEPATH + 'key-' + sCharName + IntToStr(KEY_SKIN) + '.png';
        end;
      end;
      if bImage and (sKeyboardModifier.IndexOf(sCharName) <> -1) then
      begin
        sName := 'i' + ALabel + Copy(AName,KEY_DIGITS);
        if KEY_SKIN > 0 then
        begin
          imgCharKey := TImage(FindSkinComponent(pnlSkinKey,sName));
        end
        else
        begin
          imgCharKey := FindImageComponent(pnlCharKey,sName);
        end;
        if imgCharKey = nil then
        begin
          imgCharKey := TImage.Create(Self);
          imgCharKey.Name := sName;
          if KEY_SKIN > 0 then
          begin
            imgCharKey.Parent := pnlSkinKey;
          end
          else
          begin
            imgCharKey.Parent := pnlCharKey;
          end;
          imgCharKey.OnMouseUp := pnlCharKeyUp;
          imgCharKey.OnMouseDown := pnlCharKeyDown;
          imgCharKey.OnMouseEnter := pnlImageKeyMouseEnter;
          imgCharKey.Bitmap.LoadFromFile(sImageName);
          if (KEY_MODIFIERFRAMECOLOUR <> TAlphaColors.Black) or (KEY_MODIFIERTYPECOLOUR <> KEY_MODIFIERTYPEBASE) then
          begin
            ConvertBitmap(imgCharKey.Bitmap,KEY_MODIFIERTYPECOLOUR,KEY_MODIFIERFRAMECOLOUR);
          end;
        end;
        imgCharKey.Size.Width := Round(iKeyWidth / 2);
        imgCharKey.Size.Height := Round(iKeyHeight / 2);
        imgCharKey.Scale.X := 1;
        imgCharKey.Scale.Y := 1;
        if ALabel = 'T' then
        begin
          imgCharKey.Position.X := Round((iKeyWidth - imgCharKey.Size.Width) / 2);
          imgCharKey.Position.Y := Round(iKeyHeight * ypOffset / 100 / 2);
        end
        else
        begin
          if ALabel = 'B' then
          begin
            imgCharKey.Position.X := Round((iKeyWidth - imgCharKey.Size.Width) / 2);
            imgCharKey.Position.Y := Round(iKeyHeight) - Round(imgCharKey.Size.Height) - Round(iKeyHeight * ypOffset / 100 / 2);
          end
          else
          begin
            if ALabel = 'TL' then
            begin
              imgCharKey.Position.Y := Round(iKeyHeight * ypOffset / 100 / 2);
            end
            else
            begin
              if ALabel = 'TR' then
              begin
                imgCharKey.Position.X := Round(iKeyWidth) - imgCharKey.Size.Width;
                imgCharKey.Position.Y := Round(iKeyHeight * ypOffset / 100 / 2);
              end
              else
              begin
                if ALabel = 'BR' then
                begin
                  imgCharKey.Position.X := Round(iKeyWidth) - imgCharKey.Size.Width;
                  imgCharKey.Position.Y := Round(iKeyHeight) - Round(imgCharKey.Size.Height) - Round(iKeyHeight * ypOffset / 100 / 2);
                end
                else
                begin
                  if ALabel = 'BL' then
                  begin
                    imgCharKey.Position.Y := Round(iKeyHeight) - Round(imgCharKey.Size.Height) - Round(iKeyHeight * ypOffset / 100 / 2);
                  end
                end;
              end;
            end;
          end;
        end;
        imgCharKey.Visible := True;
      end
      else
      begin
        sName := 'l' + ALabel + Copy(AName,KEY_DIGITS);
        if KEY_SKIN > 0 then
        begin
          xpOffset := 20;
          lblCharKey := TLabel(FindSkinComponent(pnlSkinKey,sName));
          iScaleKeyCount := 1;
        end
        else
        begin
          lblCharKey := FindLabelComponent(pnlCharKey,sName);
          iScaleKeyCount := AKeyCount;
        end;
        if lblCharKey = nil then
        begin
          lblCharKey := TLabel.Create(Self);
          lblCharKey.Name := sName;
          if KEY_SKIN > 0 then
          begin
            lblCharKey.Parent := pnlSkinKey;
          end
          else
          begin
            lblCharKey.Parent := pnlCharKey;
          end;
          lblCharKey.AutoSize := True;
          lblCharKey.StyledSettings := [];
          lblCharKey.TextSettings.Wordwrap := False;
        end;
        if AChar = '&' then
        begin
          lblCharKey.Text := '&&';
        end
        else
        begin
          if KeyASCII(ACharNo) = 173 then
          begin
            lblCharKey.Text := '-'; // Replacement for "soft-hyphen" which is invisible
          end
          else
          begin
            if KeyASCII(ACharNo) = 8204 then
            begin
              lblCharKey.Text := KeyChr(8890); // Replacement for "Zero width spacing character" (zwsc) which is invisible
            end
            else
            begin
              lblCharKey.Text := AChar;
            end;
          end;
        end;
        lblCharKey.TextSettings.FontColor := KEY_TEXTCOLOUR;
        if Length(AChar) = 1 then
        begin
          lblCharKey.TextSettings.Font.Size := KEY_FONTSIZE;
        end
        else
        begin
          lblCharKey.TextSettings.Font.Size := KEY_FONTSIZE - AFontOffset;
        end;
        lblCharKey.TextSettings.Font.Family := KEY_FONTNAME;
        lblCharKey.TextSettings.Font.Style := [];
        bSetBold := False;
        case KeyASCII(ACharNo) of
          KEY_CAPS: bSetBold := KEY_CAPSLOCKMODE;
          KEY_NUMLOCK: bSetBold := KEY_NUMLOCKMODE;
          KEY_INSERT: bSetBold := KEY_INSERTMODE;
        end;
        if bSetBold then
        begin
          lblCharKey.TextSettings.Font.Style := [TFontStyle.fsBold];
        end;
        if (KeyASCII(ACharNo) = KEY_CAPS) or (KeyASCII(ACharNo) = KEY_NUMLOCK) or (KeyASCII(ACharNo) = KEY_INSERT) then
        begin
          if sKeyboardModeList.IndexOf(lblCharKey.Name) = -1 then
          begin
            sKeyboardModeList.Add(lblCharKey.Name);
          end;
        end;
        lblCharKey.Scale.X := 1;
        lblCharKey.Scale.Y := 1;
        if KEY_SKIN > 0 then
        begin
          if ASet = 'C' then // Popup panel keys
          begin
            if AKeyCount = 5 then
            begin
              xpOffset := xpOffset * 3;
            end
            else
            begin
              xpOffset := xpOffset * 2;
            end;
          end;
          if AKeyCount > 1 then
          begin
            lblCharKey.Scale.X := 1 / AKeyCount;
          end;
          if ARowCount > 1 then
          begin
            lblCharKey.Scale.Y := 1 / ARowCount;
          end;
        end;
        if ALabel = 'CT' then
        begin
          lblCharKey.Position.X := Round(((iKeyWidth * AKeyCount) - lblCharKey.Size.Width) / 2 * lblCharKey.Scale.X);
          lblCharKey.Position.Y := Round(((iKeyHeight * ARowCount) - lblCharKey.Size.Height) / 2 * lblCharKey.Scale.Y);
          lblCharKey.TextSettings.HorzAlign := TTextAlign.Center;
          lblCharKey.TextSettings.VertAlign := TTextAlign.Center;
        end
        else
        begin
          if ALabel = 'T' then
          begin
            lblCharKey.Position.X := Round(((iKeyWidth * iScaleKeyCount) - lblCharKey.Size.Width) / 2);
            lblCharKey.Position.Y := Round(iKeyHeight * ARowCount * ypOffset / 100);
            lblCharKey.TextSettings.HorzAlign := TTextAlign.Center;
            lblCharKey.TextSettings.VertAlign := TTextAlign.Trailing;
          end
          else
          begin
            if ALabel = 'B' then
            begin
              lblCharKey.Position.X := Round(((iKeyWidth * iScaleKeyCount) - lblCharKey.Size.Width) / 2);
              lblCharKey.Position.Y := Round(iKeyHeight * ARowCount * (100 - ypOffset) / 100) - Round(lblCharKey.Size.Height);
              lblCharKey.TextSettings.HorzAlign := TTextAlign.Center;
              lblCharKey.TextSettings.VertAlign := TTextAlign.Leading;
            end
            else
            begin
              if ALabel = 'TL' then
              begin
                lblCharKey.Position.X := Round(iKeyWidth * iScaleKeyCount * (xpOffset / 100 / AKeyCount));
                lblCharKey.Position.Y := Round(iKeyHeight * ARowCount * ypOffset / 100 / 2);
                lblCharKey.TextSettings.HorzAlign := TTextAlign.Leading;
                lblCharKey.TextSettings.VertAlign := TTextAlign.Leading;
              end
              else
              begin
                if ALabel = 'TR' then
                begin
                  if KEY_SKIN > 0 then
                  begin
                    lblCharKey.Position.X := Round(iKeyWidth * iScaleKeyCount * (100 - xpOffset) / 100) - lblCharKey.Size.Width;
                  end
                  else
                  begin
                    lblCharKey.Position.X := Round(iKeyWidth * iScaleKeyCount * (100 - (xpOffset * 2)) / 100) - lblCharKey.Size.Width;
                  end;
                  lblCharKey.Position.Y := Round(iKeyHeight * ARowCount * ypOffset / 100 / 2);
                  lblCharKey.TextSettings.HorzAlign := TTextAlign.Trailing;
                  lblCharKey.TextSettings.VertAlign := TTextAlign.Leading;
                  lblCharKey.TextSettings.FontColor := KEY_SHIFTALTGRCOLOUR;
                end
                else
                begin
                  if ALabel = 'BR' then
                  begin
                    if KEY_SKIN > 0 then
                    begin
                      lblCharKey.Position.X := Round(iKeyWidth * iScaleKeyCount * (100 - xpOffset) / 100) - Round(lblCharKey.Size.Width);
                    end
                    else
                    begin
                      lblCharKey.Position.X := Round(iKeyWidth * iScaleKeyCount * (100 - (xpOffset * 2)) / 100) - Round(lblCharKey.Size.Width);
                    end;
                    lblCharKey.Position.Y := Round(iKeyHeight * ARowCount * (100 - ypOffset) / 100) - Round(lblCharKey.Size.Height);
                    lblCharKey.TextSettings.HorzAlign := TTextAlign.Trailing;
                    lblCharKey.TextSettings.VertAlign := TTextAlign.Trailing;
                    lblCharKey.TextSettings.FontColor := KEY_ALTGRCOLOUR;
                  end
                  else
                  begin
                    if ALabel = 'BL' then
                    begin
                      lblCharKey.Position.X := Round(iKeyWidth * iScaleKeyCount * (xpOffset / 100 / AKeyCount));
                      lblCharKey.Position.Y := Round(iKeyHeight * ARowCount * (100 - ypOffset) / 100) - Round(lblCharKey.Size.Height);
                      lblCharKey.TextSettings.HorzAlign := TTextAlign.Leading;
                      lblCharKey.TextSettings.VertAlign := TTextAlign.Trailing;
                    end
                  end;
                end;
              end;
            end;
          end;
        end;
        if sKeyboardModifier.IndexOf(IntToStr(KeyASCII(ACharNo)).PadLeft(KEY_DIGITS,'0')) <> -1 then
        begin
          lblCharKey.TextSettings.FontColor := KEY_DEADCOLOUR;
        end;
        lblCharKey.Visible := True;
      end;
    end;

  begin
    if ACharNo > -1 then
    begin
      pnlCharKey := nil;
      pnlSkinKey := nil;
      if ACharNo > 0 then
      begin
        sChar := '';
        sAltChar := '';
        sAltGrChar := '';
        sShiftChar := '';
        sShiftName := '';
        iKeyNo := iKeyNo + 1;
        sCharNo := IntToStr(ACharNo).PadLeft(KEY_DIGITS,'0');
        if KEY_SKIN > 0 then
        begin
          sName := 'pnlSkinKey' + IntToStr(iKeyNo).PadLeft(KEY_KEYNODIGITS,'0') + ASet + sCharNo;
          pnlSkinKey := FindImageComponent(AParent,sName);
          if pnlSkinKey = nil then
          begin
            pnlSkinKey := TImage.Create(Self);
            pnlSkinKey.Name := sName;
            pnlSkinKey.Parent := AParent;
            pnlSkinKey.OnMouseUp := pnlCharKeyUp;
            pnlSkinKey.OnMouseDown := pnlCharKeyDown;
            if ASet <> 'C' then // Do not trigger event in Popup panel
            begin
              pnlSkinKey.OnMouseEnter := pnlImageKeyMouseEnter;
            end;
          end;
          pnlSkinKey.Bitmap := KEY_SKINUP.Bitmap;
          if ASet = 'C' then // Reduce the size of Popup keys
          begin
            pnlSkinKey.Position.X := iLeft + 4;
            pnlSkinKey.Position.Y := iTopRow;
            pnlSkinKey.Size.Width := Round(iKeyWidth) - 2;
            pnlSkinKey.Size.Height := Round(iKeyHeight) - 2;
          end
          else
          begin
            pnlSkinKey.Position.X := iLeft;
            pnlSkinKey.Position.Y := iTopRow;
            pnlSkinKey.Size.Width := iKeyWidth;
            pnlSkinKey.Size.Height := iKeyHeight;
          end;
          pnlSkinKey.Scale.X := AKeyCount;
          pnlSkinKey.Scale.Y := ARowCount;
          pnlSkinKey.Visible := True;
        end
        else
        begin
          sName := 'pnlCharKey' + IntToStr(iKeyNo).PadLeft(KEY_KEYNODIGITS,'0') + ASet + sCharNo;
          pnlCharKey := FindRectangleComponent(AParent,sName);
          if pnlCharKey = nil then
          begin
            pnlCharKey := TRectangle.Create(Self);
            pnlCharKey.Name := sName;
            pnlCharKey.Parent := AParent;
          end;
          if ASet = 'C' then // Reduce the size of Popup keys
          begin
            pnlCharKey.Position.X := iLeft + 2;
            pnlCharKey.Position.Y := iTopRow;
            pnlCharKey.Size.Width := Round(iKeyWidth * AKeyCount) - 4;
            pnlCharKey.Size.Height := Round(iKeyHeight * ARowCount) - 2;
          end
          else
          begin
            pnlCharKey.Position.X := iLeft;
            pnlCharKey.Position.Y := iTopRow;
            pnlCharKey.Size.Width := iKeyWidth * AKeyCount;
            pnlCharKey.Size.Height := iKeyHeight * ARowCount;
          end;
          pnlCharKey.OnMouseUp := pnlCharKeyUp;
          pnlCharKey.OnMouseDown := pnlCharKeyDown;
          pnlCharKey.OnMouseEnter := pnlCharKeyMouseEnter;
          pnlCharKey.OnMouseLeave := pnlCharKeyMouseLeave;
          SetBorder(pnlCharKey,True,AKeyBorder,False);
          pnlCharKey.Fill.Color := KEY_UPCOLOUR;
          pnlCharKey.Visible := True;
        end;
        // Work out shift key
        if AShiftCharNo <> 0 then
        begin
          if (ASet <> 'P') or (AKeyType = '+') then
          begin
            sShiftChar := KeyChr(AShiftCharNo);
          end;
          sShiftCharNo := IntToStr(AShiftCharNo).PadLeft(KEY_DIGITS,'0');
          sShiftName := Copy(sName,1,10) + IntToStr(iKeyNo).PadLeft(KEY_KEYNODIGITS,'0') + ASet + sShiftCharNo;
          if sKeyboardShift.IndexOf(ASet + ',' + sName + ',' + sShiftName) = -1 then
          begin
            sKeyboardShift.Add(ASet + ',' + sName + ',' + sShiftName);
          end;
          if AKeyType = '+' then // NumLock key
          begin
            if sKeyboardNumLock.IndexOf(ASet + ',' + sName + ',' + sShiftName) = -1 then
            begin
              sKeyboardNumLock.Add(ASet + ',' + sName + ',' + sShiftName);
            end;
          end;
        end;
        // Work out Shift AltGr key
        if (AAltCharNo <> 0) and (AAltGrCharNo <> 0) then
        begin
          sAltChar := KeyChr(AAltCharNo);
          sAltCharNo := IntToStr(AAltCharNo).PadLeft(KEY_DIGITS,'0');
          if sKeyboardShiftAltGrKey.IndexOf(sCharNo) = -1 then
          begin
            sKeyboardShiftAltGrKey.Add(sCharNo);
            sKeyboardShiftAltGr.Add(sAltCharNo);
          end;
        end;
        // Work out AltGr key
        if AAltGrCharNo <> 0 then
        begin
          sAltGrChar := KeyChr(AAltGrCharNo);
          sAltGrCharNo := IntToStr(AAltGrCharNo).PadLeft(KEY_DIGITS,'0');
          if sKeyboardAltGrKey.IndexOf(sCharNo) = -1 then
          begin
            sKeyboardAltGrKey.Add(sCharNo);
            sKeyboardAltGr.Add(sAltGrCharNo);
          end;
          if AShiftCharNo <> 0 then
          begin
            if sKeyboardAltGrKey.IndexOf(sShiftCharNo) = -1 then
            begin
              sKeyboardAltGrKey.Add(sShiftCharNo);
              sKeyboardAltGr.Add(sAltGrCharNo);
            end;
          end;
        end;
        iFontOffset := 0;
        case KeyASCII(ACharNo) of
          KEY_F1..KEY_F12: sChar := 'F' + IntToStr(KeyASCII(ACharNo) - KEY_F1 + 1);
          KEY_TABNEXT,KEY_TABPREVIOUS:
            begin
              sChar := KEY_LANGTEXT[3]; // Tab
              iFontOffset := SetFontOffset(4);
            end;
          KEY_ESC:
            begin
              sChar := KEY_LANGTEXT[4]; // Esc
              iFontOffset := SetFontOffset(4);
            end;
          KEY_POPUPCOPY:
            begin
              sChar := KEY_LANGTEXT[5]; // Copy (Ctrl+C)
              iFontOffset := SetFontOffset(3);
            end;
          KEY_POPUPPASTE:
            begin
              sChar := KEY_LANGTEXT[6]; // Paste (Ctrl+V)
              iFontOffset := SetFontOffset(3);
            end;
          KEY_POPUPCUT:
            begin
              sChar := KEY_LANGTEXT[7]; // Cut (Ctrl+X)
              iFontOffset := SetFontOffset(3);
            end;
          KEY_POPUPSELECTALL:
            begin
              sChar := KEY_LANGTEXT[8]; // Select All (Ctrl+A)
              iFontOffset := SetFontOffset(3);
            end;
          KEY_CTRL:
            begin
              sChar := KEY_LANGTEXT[9]; // Ctrl
              iFontOffset := SetFontOffset(4);
            end;
          KEY_CAPS:
            begin
              sChar := KEY_LANGTEXT[10]; // Caps
              iFontOffset := SetFontOffset(4);
            end;
          KEY_FUNC:
            begin
              sChar := KEY_LANGTEXT[11]; // Fn
              iFontOffset := SetFontOffset(4);
            end;
          KEY_ALT:
            begin
              sChar := KEY_LANGTEXT[12]; // Alt
              iFontOffset := SetFontOffset(4);
            end;
          KEY_ALTGR:
            begin
              sChar := KEY_LANGTEXT[13]; // Alt Gr
              iFontOffset := SetFontOffset(4);
            end;
          KEY_HOME:
            begin
              sChar := KEY_LANGTEXT[14]; // Home
              iFontOffset := SetFontOffset(4);
            end;
          KEY_END:
            begin
              sChar := KEY_LANGTEXT[15]; // End
              iFontOffset := SetFontOffset(4);
            end;
          KEY_DELETE:
            begin
              sChar := KEY_LANGTEXT[16]; // Del
              iFontOffset := SetFontOffset(4);
            end;
          KEY_INSERT,KEY_NUMINSERT:
            begin
              sChar := KEY_LANGTEXT[17]; // Ins
              iFontOffset := SetFontOffset(4);
            end;
          KEY_NUMLOCK:
            begin
              sChar := KEY_LANGTEXT[18]; // Num Lock
              iFontOffset := SetFontOffset(4);
            end;
          KEY_PGUP:
            begin
              if AKeyType = '+' then
              begin
                sChar := KEY_LANGTEXT[19]; // Pg Up
              end
              else
              begin
                sChar := KEY_LANGTEXT[20]; // Page Up
              end;
              iFontOffset := SetFontOffset(4);
            end;
          KEY_PGDN:
            begin
              if AKeyType = '+' then
              begin
                sChar := KEY_LANGTEXT[21]; // Pg Dn
              end
              else
              begin
                sChar := KEY_LANGTEXT[22]; // Page Down
              end;
              iFontOffset := SetFontOffset(4);
            end;
          KEY_NEXT:
            begin
              sChar := KEY_LANGTEXT[23]; // Next/Done/Go/Return
              iFontOffset := SetFontOffset(8);
            end;
          KEY_ABC:
            begin
              sChar := KEY_LANGTEXT[24]; // ABC
              iFontOffset := SetFontOffset(4);
            end;
          KEY_123:
            begin
              sChar := KEY_LANGTEXT[25]; // 123
              iFontOffset := SetFontOffset(4);
            end;
          KEY_URL:
            begin
              sChar := KEY_LANGTEXT[26]; // URL
              iFontOffset := SetFontOffset(4);
            end;
          KEY_EMAIL:
            begin
              sChar := KEY_LANGTEXT[27]; // Email
              iFontOffset := SetFontOffset(4);
            end;
          KEY_PRTSCR:
            begin
              sChar := KEY_LANGTEXT[28]; // PrtScr
              iFontOffset := SetFontOffset(4);
            end;
          KEY_SPACE:
            begin
              if KEY_SKIN = 0 then
              begin
                pnlCharKey.Fill.Color := KEY_SPACEUPCOLOUR;
                if KEY_SPACEUPCOLOUR <> KEY_UPCOLOUR then
                begin
                  SetBorder(pnlCharKey,True,False,False);
                end;
              end;
            end;
          KEY_POPUP:
            begin
              KEY_POPUPPANEL := True;
            end;
        else
          begin
            sChar := KeyChr(ACharNo);
          end;
        end;
        if sKeyboardImages.IndexOf(IntToStr(KeyASCII(ACharNo)).PadLeft(KEY_DIGITS,'0')) <> -1 then // Matches standard graphics
        begin
          sName := 'img' + Copy(sName,4);
          if KEY_SKIN > 0 then
          begin
            imgCharKey := TImage(FindSkinComponent(pnlSkinKey,sName));
          end
          else
          begin
            imgCharKey := FindImageComponent(pnlCharKey,sName);
          end;
          if imgCharKey = nil then
          begin
            imgCharKey := TImage.Create(Self);
            imgCharKey.Name := sName;
            if KEY_SKIN > 0 then
            begin
              imgCharKey.Parent := pnlSkinKey;
            end
            else
            begin
              imgCharKey.Parent := pnlCharKey;
              imgCharKey.OnMouseEnter := pnlImageKeyMouseEnter;
            end;
            imgCharKey.OnMouseDown := pnlCharKeyDown;
            imgCharKey.OnMouseUp := pnlCharKeyUp;
            imgCharKey.Anchors := [];
            // Look for image for skin 0 - this saves lots of pointless checks later
            sImageName := KEY_IMAGEPATH + 'key-' + IntToStr(KeyASCII(ACharNo)).PadLeft(KEY_DIGITS,'0') + '0.png';
            if FileExists(sImageName) then // So an "image" related key
            begin
              // Look for override image for this skin
              if FileExists(KEY_IMAGEPATH + 'key-' + sCharNo + IntToStr(KEY_SKIN) + '.png') then
              begin
                sImageName := KEY_IMAGEPATH + 'key-' + sCharNo + IntToStr(KEY_SKIN) + '.png';
              end;
              imgCharKey.Bitmap.LoadFromFile(sImageName);
              if KEY_TEXTCOLOUR <> TAlphaColors.Black then // Colour of standard keyboard graphics
              begin
                ConvertBitmap(imgCharKey.Bitmap,TAlphaColors.Black,KEY_TEXTCOLOUR);
              end;
            end;
          end;
          imgCharKey.Size.Width := Round(iKeyWidth * 0.5);
          imgCharKey.Size.Height := Round(iKeyHeight * 0.5);
          imgCharKey.Scale.X := 1;
          imgCharKey.Scale.Y := 1;
          if KEY_SKIN > 0 then
          begin
            if AKeyCount > 1 then
            begin
              imgCharKey.Scale.X := 1 / AKeyCount;
            end;
            if ARowCount > 1 then
            begin
              imgCharKey.Scale.Y := 1 / ARowCount;
            end;
            imgCharKey.Position.X := Round((iKeyWidth - (imgCharKey.Size.Width * imgCharKey.Scale.X)) / 2);
            imgCharKey.Position.Y := Round((iKeyHeight - Round(imgCharKey.Size.Height * imgCharKey.Scale.Y)) / 2);
          end
          else
          begin
            imgCharKey.Position.X := Round((pnlCharKey.Size.Width - imgCharKey.Size.Width) / 2);
            imgCharKey.Position.Y := (Round(iKeyHeight * ARowCount) / 2) - Round(imgCharKey.Size.Height / 2);
          end;
          imgCharKey.Visible := True;
        end
        else
        begin
          if sShiftChar <> '' then
          begin
            AddCharKeyLabel(sName,'TL',sShiftChar,AShiftCharNo,iFontOffset);
            AddCharKeyLabel(sName,'BL',sChar,ACharNo,iFontOffset);
          end
          else
          begin
            if KEY_LABELCENTRE and (ASet <> 'C') and (sShiftChar = '') and (sAltGrChar = '') and (sAltChar = '') then
            begin
              AddCharKeyLabel(sName,'CT',sChar,ACharNo,iFontOffset);
            end
            else
            begin
              AddCharKeyLabel(sName,'TL',sChar,ACharNo,iFontOffset);
            end;
          end;
          if (sAltGrChar <> '') or (sAltChar <> '') then
          begin
            if sAltChar <> '' then
            begin
              AddCharKeyLabel(sName,'TR',sAltChar,AAltCharNo,iFontOffset);
            end;
            if sAltGrChar <> '' then
            begin
              AddCharKeyLabel(sName,'BR',sAltGrChar,AAltGrCharNo,iFontOffset);
            end;
          end;
        end;
      end;
      iLeft := iLeft + (iKeyWidth * AKeyCount);
      if iLeft > iRightCol then
      begin
        iRightCol := iLeft;
      end;
    end;
  end;

  procedure AddSet(AKeyboard: TRectangle; AType,ASet: String; ALanguage: Integer);
  var
    i,j,k,iASCII,iCheckASCII,iShiftASCII,iAltASCII,iAltGrASCII,iRowLength,iKeyCount,iRowCount: Integer;
    bSkip: Boolean;
    sKeyType: String;

    function OverrideCase(AASCII: Integer): Integer;
    var
      iASCII: Integer;
    begin
      iASCII := AASCII;
      if iASCII >= 64 then
      begin
        if KEY_FIELDCASE = KEY_FIELDLOWERCASE then
        begin
          // Convert upper to lower
          case iASCII of
            65..91: iASCII := iASCII + 32; // A - Z
            192..214,215..222,913..929,931..939,1040..1071,65313..65338: iASCII := iASCII + 32;
            1025..1036,1038,1039: iASCII := iASCII + 80;
            1329..1366,4256..4293: iASCII := iASCII + 48;
            9398..9423: iASCII := iASCII + 26;
            7944..7951,7960..7965,7976..7983,7992..7999,8008..8013,8025,8027,8029,8031,8040..8047,8072..8079,8088..8095,8104..8111,8120,8121,8152,8153,8168,8169: iASCII := iASCII - 8;
            256..302,306..310,330..374,386..388,408,416..420,428,440,444,478..494,498..500,506..534,994..1006,1120..1152,1168..1214,1232..1258,1262..1268,1272,7680..7828,7840..7928:
              begin
                if not Odd(iASCII) then
                begin
                  iASCII := iASCII + 1;
                end;
              end;
            313..327,377..381,391,395,401,423,431,435..437,453,455,459,461..475,1217,1219,1223,1227:
              begin
                if Odd(iASCII) then
                begin
                  iASCII := iASCII + 1;
                end;
              end;
            904..906: iASCII := iASCII + 37;
            223: iASCII := 7838;
            376: iASCII := 255;
            385: iASCII := 595;
            390: iASCII := 596;
            398: iASCII := 598;
            399: iASCII := 601;
            400: iASCII := 603;
            403: iASCII := 608;
            404: iASCII := 611;
            406: iASCII := 617;
            407: iASCII := 616;
            412: iASCII := 623;
            413: iASCII := 626;
            415: iASCII := 629;
            425: iASCII := 643;
            430: iASCII := 648;
            433: iASCII := 650;
            434: iASCII := 651;
            439: iASCII := 658;
            458: iASCII := 460;
            902: iASCII := 940;
            908: iASCII := 972;
            909: iASCII := 973;
            910: iASCII := 974;
          end;
        end
        else
        begin
          if KEY_FIELDCASE = KEY_FIELDUPPERCASE then
          begin
            // Convert lower to upper
            case iASCII of
              97..123: iASCII := iASCII - 32; // a - z
              224..246,248..254,945..961,963..971,1072..1103,65345..65370: iASCII := iASCII - 32;
              1105..1116,1118,1119: iASCII := iASCII - 80;
              1377..1414,4304..4341: iASCII := iASCII - 48;
              9424..9449: iASCII := iASCII - 26;
              7936..7943,7952..7957,7968..7975,7984..7991,8000..8005,8017,8019,8021,8023,8032..8039,8064..8071,8080..8087,8096..8103,8112,8113,8144,8145,8160,8161: iASCII := iASCII + 8;
              257..303,307..311,331..375,387..389,409,417..421,429,441,445,479..495,499..501,507..535,995..1007,1121..1153,1169..1215,1233..1259,1263..1269,1273,7681..7829,7841..7929:
                begin
                  if Odd(iASCII) then
                  begin
                    iASCII := iASCII - 1;
                  end;
                end;
              314..328,378..382,392,396,402,424,432,436..438,454,456,462..476,1218,1220,1224,1228:
                begin
                  if not Odd(iASCII) then
                  begin
                    iASCII := iASCII - 1;
                  end;
                end;
              941..943: iASCII := iASCII - 37;
              305: iASCII := iASCII - 232; // lower dotless i - I
              255: iASCII := 376;
              460: iASCII := 458;
              595: iASCII := 385;
              596: iASCII := 390;
              597: iASCII := 394;
              598: iASCII := 398;
              601: iASCII := 399;
              603: iASCII := 400;
              608: iASCII := 403;
              611: iASCII := 404;
              616: iASCII := 407;
              617: iASCII := 406;
              623: iASCII := 412;
              626: iASCII := 413;
              629: iASCII := 415;
              643: iASCII := 425;
              648: iASCII := 430;
              650: iASCII := 433;
              651: iASCII := 434;
              658: iASCII := 439;
              940: iASCII := 902;
              972: iASCII := 908;
              973: iASCII := 909;
              974: iASCII := 910;
              7838: iASCII := 223;
            end;
          end;
        end;
      end;
      Result := iASCII;
    end;

  begin
    iTopRow := 0;
    iLeftCol := 0;
    iRightCol := 0;
    for i := 0 to sRows.Count - 1 do
    begin
      if UpperCase(Copy(sRows[i],1,1)) = ASet then
      begin
        iRowLength := Length(sRows[i]) - 1;
        if Frac(iRowLength / KEY_CHAR_WIDTH) = 0 then // All of the row contains blocks of KEY_CHAR_WIDTH
        begin
          iLeft := iLeftCol;
          j := Round(iRowLength / KEY_CHAR_WIDTH);
          if j < iMaxKeys then
          begin
            iLeft := iLeft + Round(((iMaxKeys - j) * iKeyWidth) / 2);
          end;
          iKeyCount := 1;
          for j := 1 to Round(iRowLength / KEY_CHAR_WIDTH) do
          begin
            iRowCount := 1;
            bSkip := False;
            k := ((j - 1) * KEY_CHAR_WIDTH) + 1 + 1; // Add 1 to ignore the panel type character
            sKeyType := Copy(sRows[i],k + KEY_DIGITS,1);
            iASCII := OverrideCase(StrToIntDef(Copy(sRows[i],k,KEY_DIGITS),-1)); // Change this line to convert from hex to integer
            iShiftASCII := OverrideCase(StrToIntDef(Copy(sRows[i],k + KEY_DIGITS + 1,KEY_DIGITS),-1));
            iAltASCII := OverrideCase(StrToIntDef(Copy(sRows[i],k + ((KEY_DIGITS + 1) * 2),KEY_DIGITS),-1));
            iAltGrASCII := OverrideCase(StrToIntDef(Copy(sRows[i],k + ((KEY_DIGITS + 1) * 3),KEY_DIGITS),-1));
            // Check character from previous row, if the same skip but increase key count
            if iASCII > 0 then
            begin
              if i > 0 then
              begin
                iCheckASCII := StrToIntDef(Copy(sRows[i - 1],k,KEY_DIGITS),-1);
                if iCheckASCII = iASCII then
                begin
                  iKeyCount := iKeyCount + 1;
                  bSkip := True;
                end;
              end;
              if not bSkip then
              begin
                // Check next character, if the same skip but increase key count
                if (k + KEY_CHAR_WIDTH) < iRowLength then
                begin
                  iCheckASCII := StrToIntDef(Copy(sRows[i],k + KEY_CHAR_WIDTH,KEY_DIGITS),-1);
                  if iCheckASCII = iASCII then
                  begin
                    iKeyCount := iKeyCount + 1;
                    bSkip := True;
                  end;
                end;
              end;
            end;
            if not bSkip then
            begin
              if (i < (sRows.Count - 1)) and (iASCII > 0) then // Check for next row, same cell to see if the same
              begin
                if StrToIntDef(Copy(sRows[i + 1],k,KEY_DIGITS),-1) = iASCII then
                begin
                  iRowCount := 2;
                end;
              end;
              AddCharKey(iKeyCount,iRowCount,AKeyboard,ASet,SetKeyASCII(iASCII),SetKeyASCII(iShiftASCII),SetKeyASCII(iAltASCII),SetKeyASCII(iAltGrASCII),sKeyType);
              iKeyCount := 1;
            end;
          end;
        end;
        iTopRow := iTopRow + iKeyHeight;
      end;
    end;
  end;

  procedure AddPopupPanel;
  var
    iPopupKeys: Integer;
  begin
    iLeft := 0;
    iTopRow := 2;
    iPopupKeys := 3;
    if (Length(KEY_LANGTEXT[5]) > 20) or (Length(KEY_LANGTEXT[6]) > 20) or (Length(KEY_LANGTEXT[7]) > 20) or (Length(KEY_LANGTEXT[8]) > 20) then
    begin
      iPopupKeys := 4;
      if ((KEY_FONTSIZE <= 12) and (KEY_SKIN > 0)) or ((KEY_FONTSIZE <= 10) and (KEY_SKIN = 0)) then
      begin
        iPopupKeys := 5;
      end;
    end
    else
    begin
      if KEY_FONTSIZE <= 12 then
      begin
        iPopupKeys := 4;
      end;
    end;
    iRightCol := iKeyWidth * iPopupKeys;
    AddCharKey(iPopupKeys,1,pnlKeyboardPopup,'C',KEY_POPUPSELECTALL,0,0,0,''); // Select All
    iLeft := 0;
    iTopRow := iTopRow + iKeyHeight;
    AddCharKey(iPopupKeys,1,pnlKeyboardPopup,'C',KEY_POPUPPASTE,0,0,0,''); // Paste
    iLeft := 0;
    iTopRow := iTopRow + iKeyHeight;
    AddCharKey(iPopupKeys,1,pnlKeyboardPopup,'C',KEY_POPUPCUT,0,0,0,''); // Cut
    iLeft := 0;
    iTopRow := iTopRow + iKeyHeight;
    AddCharKey(iPopupKeys,1,pnlKeyboardPopup,'C',KEY_POPUPCOPY,0,0,0,''); // Copy
    iTopRow := iTopRow + iKeyHeight;
  end;

  function SetFontSize(ASize: Integer): Integer;
  var
    iFontSize: Integer;
  begin
    iFontSize := 6;
    if ASize >= 70 then
    begin
      iFontSize := (Round(ASize / 5) * 2) - 7;
    end
    else
    begin
      if ASize >= 60 then
      begin
        iFontSize := (Round(ASize / 5) * 2) - 6;
      end
      else
      begin
        if ASize >= 50 then
        begin
          iFontSize := (Round(ASize / 5) * 2) - 5;
        end
        else
        begin
          if ASize >= 40 then
          begin
            iFontSize := (Round(ASize / 5) * 2) - 4;
          end
          else
          begin
            if ASize >= 30 then
            begin
              iFontSize := (Round(ASize / 5) * 2) - 2;
            end
            else
            begin
              if ASize >= 20 then
              begin
                iFontSize := (Round(ASize / 5) * 2);
              end;
            end;
          end;
        end;
      end;
    end;
    Result := iFontSize;
  end;

  procedure SetLanguage(ALanguage: Integer; ADerivative: String);
  var
    i,j: Integer;
    sValue: String;
    sText: TStringList;

    procedure AddLanguageKeys(AList: TStringList; AKeys: String);
    var
      i: Integer;
    begin
      if AKeys <> '' then
      begin
        for i := 1 to Length(AKeys) do
        begin
          AList.Add(Copy(AKeys,i,1));
        end;
      end;
    end;

    function ConvertIt(AText: String): String;
    var
      i: Integer;
      sText,sPart1,sPart2: String;
    begin
      sText := AText;
      while Pos('U+',sText) > 0 do
      begin
        i := Pos('U+',sText);
        sPart1 := '';
        sPart2 := '';
        if i > 1 then
        begin
          sPart1 := Copy(sText,1,i - 1);
        end;
        if Length(sText) > (i + 6) then
        begin
          sPart2 := Copy(sText,i + 7);
        end;
        sText := sPart1 + Chr(StrToInt(Copy(sText,i + 2,5))) + sPart2;
      end;
      Result := StringReplace(sText,'#',Chr(10),[rfReplaceAll]);
    end;

    function FindMatch(ALanguage: Integer; ADerivative: String): Boolean;
    var
      i,j: Integer;
      bMatched: Boolean;
    begin
      i := 0;
      bMatched := False;
      while (i < sLanguage.Count) do
      begin
        if StrToIntDef(Copy(sLanguage[i],1,3),0) = ALanguage then
        begin
          sText := TStringList.Create;
          try
            sText.StrictDelimiter := True;
            sText.Delimiter := '|';
            sText.DelimitedText := sLanguage[i];
            if sText.Count > 0 then
            begin
              if (sText[1] = ADerivative) or (ADerivative = '') then
              begin
                for j := 0 to sText.Count - 1 do
                begin
                  if j <= 99 then
                  begin
                    KEY_LANGTEXT[j] := ConvertIt(sText[j]);
                    bMatched := True;
                  end;
                end;
                i := 999;
              end;
            end;
          finally
            sText.Free;
          end;
        end;
        i := i + 1;
      end;
      if bMatched then
      begin
        AddLanguageKeys(sKeyboardCopy,KEY_LANGTEXT[KEY_MODIFIERSTART - 4]);
        AddLanguageKeys(sKeyboardSelectAll,KEY_LANGTEXT[KEY_MODIFIERSTART - 3]);
        AddLanguageKeys(sKeyboardCut,KEY_LANGTEXT[KEY_MODIFIERSTART - 2]);
        AddLanguageKeys(sKeyboardPaste,KEY_LANGTEXT[KEY_MODIFIERSTART - 1]);
      end;
      Result := bMatched;
    end;

    function ConvertHexToChar(AText: String): String;
    var
      i,j: Integer;
      sOut,sReplace: String;
      sBlock,sSplit,sReplaceChars: TStringList;
    begin
      sOut := '';
      sBlock := TStringList.Create;
      sSplit := TStringList.Create;
      sReplaceChars := TStringList.Create;
      try
        sBlock.StrictDelimiter := True;
        sBlock.Delimiter := ',';
        sBlock.DelimitedText := AText;
        sSplit.StrictDelimiter := True;
        sSplit.Delimiter := ':';
        sReplaceChars.StrictDelimiter := True;
        sReplaceChars.Delimiter := '.';
        if sBlock.Count > 0 then
        begin
          for i := 1 to sBlock.Count - 1 do // block 0 is the modifier value, so ignore it
          begin
            sSplit.DelimitedText := sBlock[i];
            sOut := sOut + ',' + sSplit[0] + ':';
            sReplace := '';
            if sSplit.Count > 1 then
            begin
              sReplaceChars.DelimitedText := sSplit[1];
              if sReplaceChars.Count > 0 then
              begin
                for j := 0 to sReplaceChars.Count - 1 do
                begin
                  sReplace := sReplace + Chr(StrToInt(sReplaceChars[j]));
                end;
              end;
            end;
            sOut := sOut + sReplace;
          end;
        end;
      finally
        sReplaceChars.Free;
        sBlock.Free;
        sSplit.Free;
        Result := sOut;
      end;
    end;
  begin
    for i := 0 to 99 do
    begin
      KEY_LANGTEXT[i] := '';
    end;
    if Assigned(sLanguage) then
    begin
      sKeyboardCopy.Clear;
      sKeyboardSelectAll.Clear;
      sKeyboardCut.Clear;
      sKeyboardPaste.Clear;
      if sLanguage.Count > 0 then
      begin
      if not FindMatch(ALanguage,ADerivative) then // Try using the derivative (if any)
        begin
          FindMatch(ALanguage,'');
        end;
      end;
      sKeyboardModifier.Clear;
      if sKeyboardAccents.Count > 0 then
      begin
        for j := 0 to sKeyboardAccents.Count - 1 do
        begin
          sValue := IntToStr(StrToInt64('$' + Copy(sKeyboardAccents[j],1,KEY_DIGITACCENTS))).PadLeft(KEY_DIGITS,'0');
          i := sKeyboardModifier.IndexOf(sValue);
          if i = -1 then // This modifier is required
          begin
            sKeyboardModifier.Add(sValue);
          end;
          i := sKeyboardModifier.IndexOf(sValue);
          KEY_LANGTEXT[i + KEY_MODIFIERSTART] := ConvertHexToChar(sKeyboardAccents[j]);
        end;
      end;
      sKeyboardAlt.Clear;
      sKeyboardAltGr.Clear;
      sKeyboardShiftAltGr.Clear;
      sKeyboardAltKey.Clear;
      sKeyboardAltGrKey.Clear;
      sKeyboardShiftAltGrKey.Clear;
      if KEY_CURRENCYSHORTCUTS then
      begin
        AddDefaultCurrencyShortcuts;
      end;
    end;
  end;

  procedure SetKeyboardDefaults(ADefaults: String);
  var
    sList: TStringList;
    sFonts: TStringList;
    i: Integer;
    bKeepGoing: Boolean;
  begin
    sList := TStringList.Create;
    sFonts := TStringList.Create;
    try
      sList.Delimiter := '|';
      sList.StrictDelimiter := True;
      sList.DelimitedText := ADefaults;
      if sList.Count > 0 then
      begin
        if sList[0] = 'Y' then
        begin
          KEY_LABELCENTRE := True;
        end;
      end;
      if sList.Count > 1 then // Default font list
      begin
        sFonts.Delimiter := ',';
        sFonts.StrictDelimiter := True;
        sFonts.DelimitedText := sList[1];
        if sFonts.Count > 0 then
        begin
          i := 0;
          bKeepGoing := True;
          while bKeepGoing and (i < sFonts.Count) do
          begin
            if sFonts[i] <> '' then
            begin
              if Printer.Fonts.IndexOf(sFonts[i]) > -1 then
              begin
                KEY_FONTNAME := sFonts[i];
                bKeepGoing := False;
              end;
            end;
            i := i + 1;
          end;
        end;
      end;
    finally
      sFonts.Free;
      sList.Free;
    end;
  end;
begin
  KEY_FIELDNAME := '';
  KEY_KEYS := '';
  KEY_UNICODE := '+';
  KEY_MODIFIER := 0;
  KEY_READONLY := True; // Assume the worst
  KEY_LABELCENTRE := False;
  KEY_CAPSLOCKMODE := GetCapsLockState;
  KEY_INSERTMODE := True;
  KEY_NUMLOCKMODE := False;
  KEY_ALTGRDOWN := False;
  KEY_SHIFTDOWN := False;
  KEY_INSHIFT := False;
  KEY_FORM := nil;
  KEY_LPANEL := False;
  KEY_PPANEL := False;
  KEY_POPUPPANEL := False;
  KEY_FIELDCASE := KEY_FIELDMIXEDCASE;
  KEY_FIELDTYPE := KEY_TYPEUNKNOWN;
  KEY_SELECTSTART := -1;
  if (AInitialPanel > 0) and (AInitialPanel < 4) then
  begin
    KEY_INITIALPANEL := AInitialPanel;
  end
  else
  begin
    KEY_INITIALPANEL := 2;
  end;
  KEY_PANELNO := KEY_INITIALPANEL;
  KEY_KEYWIDTH := AKeyWidth;
  KEY_KEYHEIGHT := AKeyHeight;
  KEY_OUTERWIDTH := AOuterWidth;
  KEY_KEYBORDER := AKeyBorder;
  KEY_INNERBORDER := AInnerBorder;
  KEY_OUTERBORDER := AOuterBorder;
  KeyCallbackProcedure := KeyCallback;
  KEY_FORM := FindFormOwner(AField);
  if (KEY_FORM <> nil) and Assigned(KEY_FORM) and (sKeyboards <> nil) and (UpperCase(AType) <> 'C') then
  begin
    KEY_FIELDNAME := AField.Name;
    KEY_FIELD := FieldFindComponent(KEY_READONLY,KEY_FIELDCASE,KEY_FIELDTYPE,KEY_FORM,KEY_FIELDNAME);
    if KEY_FIELDCASE = KEY_FIELDUPPERCASE then
    begin
      KEY_CAPSLOCKMODE := True;
    end;
    if KEY_FIELDTYPE <> KEY_TYPEUNKNOWN then
    begin
      FieldSetOnKeyDownEvent;
    end;
  end;
  if KEY_FIELDTYPE <> KEY_TYPEUNKNOWN then
  begin
    if (AType <> KEY_CURRENTKEYBOARDTYPE) or (ADerivative <> KEY_CURRENTDERIVATIVE) or (AKeyWidth <> KEY_CURRENTKEYWIDTH) or (AKeyHeight <> KEY_CURRENTKEYHEIGHT) or (AWidth <> KEY_CURRENTWIDTH) then
    begin
      if Assigned(sKeyboardModeList) then
      begin
        sKeyboardModeList.Clear;
      end;
      if Assigned(sKeyboardShift) then
      begin
        sKeyboardShift.Clear;
      end;
      if Assigned(sKeyboardNumLock) then
      begin
        sKeyboardNumLock.Clear;
      end;
      if Assigned(pnlKeyboardBase) then
      begin
        frmKeyboard.CloseKeyboard;
      end;
      iKeyNo := 0;
      iMaxKeys := 0;
      // Set language
      if ALanguage = 0 then
      begin
        KEY_LANGUAGE := 44;
      end
      else
      begin
        KEY_LANGUAGE := ALanguage;
      end;
      // Set keyboard type
      if Length(AType) <> 1 then
      begin
        KEY_KEYBOARDTYPE := '0';
      end
      else
      begin
        KEY_KEYBOARDTYPE := AType;
      end;
      sSet := KEY_KEYBOARDTYPE + IntToStr(KEY_LANGUAGE).PadLeft(KEY_KEYNODIGITS,'0') + UpperCase(ADerivative);
      SetLanguage(KEY_LANGUAGE,ADerivative);
      if KEY_LANGTEXT[3] = '' then // If SetLanguage fails (no value defined for Tab detected), load the English language variant
      begin
        SetLanguage(44,'');
      end;
      KEY_FONTNAME := KEY_LANGTEXT[2];
      sRows := TStringList.Create;
      if sKeyboards.Count > 0 then
      begin
        for i := 0 to sKeyboards.Count - 1 do
        begin
          if UpperCase(Trim(Copy(sKeyboards[i],1,6))) = sSet then
          begin
            sPanelType := UpperCase(Copy(sKeyboards[i],7,1));
            sRows.Add(Copy(sKeyboards[i],7));
            if sPanelType = 'D' then
            begin
              SetKeyboardDefaults(Copy(sKeyboards[i],8));
            end
            else
            begin
              if (sPanelType = 'L') then
              begin
                KEY_LPANEL := True;
              end;
              if sPanelType = 'P' then
              begin
                KEY_PPANEL := True;
              end;
              j := Round((Length(Copy(sKeyboards[i],7)) - 1) / KEY_CHAR_WIDTH);
              if j > iMaxKeys then
              begin
                iMaxKeys := j;
              end;
            end;
          end;
        end;
      end;
      if (AKeyWidth <> 0) or (AWidth = 0) then
      begin
        iKeyWidth := AKeyWidth;
      end
      else
      begin
        iKeyWidth := Trunc(AWidth / iMaxKeys);
      end;
      if (AKeyHeight = 0) or (AKeyHeight = 100) or (KEY_SKIN > 0) then // Cannot change height when using a Skin
      begin
        iKeyHeight := iKeyWidth;
      end
      else
      begin
        iKeyHeight := Trunc(iKeyWidth * AKeyHeight / 100);
      end;
      KEY_FONTSIZE := SetFontSize(iKeyWidth);
      KEY_ADJUSTOFFSET := Round(KEY_FONTSIZE * 0.1); // When "Skin" key pressed move labels by several pixels
      // Set Keyboard base panel, holds everything
      if not Assigned(pnlKeyboardBase) then
      begin
        pnlKeyboardBase := TRectangle.Create(Self);
        pnlKeyboardBase.Name := 'pnlKeyboardBase';
        pnlKeyboardBase.Parent := KEY_FORM;
        SetBorder(pnlKeyboardBase,False,AOuterBorder,False);
        pnlKeyboardBase.Fill.Color := KEY_BORDERCOLOUR;
      end;
      pnlKeyboardBase.Visible := False;
      pnlKeyboardBase.Position.X := AX;
      pnlKeyboardBase.Position.Y := AY;
      // Set Upper case keyboard panel within the base panel
      if not Assigned(pnlUCKeyboard) then
      begin
        pnlUCKeyboard := TRectangle.Create(Self);
        pnlUCKeyboard.Name := 'pnlUCKeyboard';
        pnlUCKeyboard.Parent := pnlKeyboardBase;
        SetBorder(pnlUCKeyboard,False,AInnerBorder,False);
        pnlUCKeyboard.Fill.Color := KEY_INNERCOLOUR;
      end;
      pnlUCKeyboard.Visible := False;
      pnlUCKeyboard.Position.X := AOuterWidth;
      pnlUCKeyboard.Position.Y := AOuterWidth;
      AddSet(pnlUCKeyboard,AType,'U',ALanguage);
      if not Assigned(pnlLCKeyboard) then
      begin
        // Set Lower case keyboard panel within the base panel
        pnlLCKeyboard := TRectangle.Create(Self);
        pnlLCKeyboard.Name := 'pnlLCKeyboard';
        pnlLCKeyboard.Parent := pnlKeyboardBase;
        SetBorder(pnlLCKeyboard,False,AInnerBorder,False);
        pnlLCKeyboard.Fill.Color := KEY_INNERCOLOUR;
      end;
      pnlLCKeyboard.Visible := False;
      pnlLCKeyboard.Position.X := AOuterWidth;
      pnlLCKeyboard.Position.Y := AOuterWidth;
      if KEY_LPANEL then
      begin
        AddSet(pnlLCKeyboard,AType,'L',ALanguage);
      end;
      if not Assigned(pnlPCKeyboard) then
      begin
        // Set Punctuation and special character keyboard panel within the base panel
        pnlPCKeyboard := TRectangle.Create(Self);
        pnlPCKeyboard.Name := 'pnlPCKeyboard';
        pnlPCKeyboard.Parent := pnlKeyboardBase;
        SetBorder(pnlPCKeyboard,False,AInnerBorder,False);
        pnlPCKeyboard.Fill.Color := KEY_INNERCOLOUR;
      end;
      pnlPCKeyboard.Visible := False;
      pnlPCKeyboard.Position.X := AOuterWidth;
      pnlPCKeyboard.Position.Y := AOuterWidth;
      if KEY_PPANEL then
      begin
        AddSet(pnlPCKeyboard,AType,'P',ALanguage);
      end;
      sRows.Free;
      iOffset := 0;
      // Set the keyboard size based on keys
      // pnlKeyboardBase.Size.Height := iTopRow + (AOuterWidth * 2);
      if AWidth > 0 then
      begin
        pnlKeyboardBase.Size.Width := AWidth;
        if (iRightCol + (AOuterWidth * 2)) < AWidth then
        begin
          iOffset := AOuterWidth + Round((AWidth - (iRightCol + (AOuterWidth * 2))) / 2);
          pnlUCKeyboard.Position.X := iOffset;
          if KEY_LPANEL then
          begin
            pnlLCKeyboard.Position.X := iOffset;
          end;
          if KEY_PPANEL then
          begin
            pnlPCKeyboard.Position.X := iOffset;
          end;
        end;
      end
      else
      begin
        pnlKeyboardBase.Size.Width := iRightCol + (AOuterWidth * 2);
      end;
      pnlKeyboardBase.Size.Height := iTopRow + (AOuterWidth * 2) + (iOffset * 2);
      pnlUCKeyboard.Size.Height := iTopRow;
      pnlUCKeyboard.Size.Width := iRightCol;
      pnlUCKeyboard.Position.Y := AOuterWidth + iOffset;
      if KEY_LPANEL then
      begin
        pnlLCKeyboard.Size.Height := iTopRow;
        pnlLCKeyboard.Size.Width := iRightCol;
        pnlLCKeyboard.Position.Y := AOuterWidth + iOffset;
      end;
      if KEY_PPANEL then
      begin
        pnlPCKeyboard.Size.Height := iTopRow;
        pnlPCKeyboard.Size.Width := iRightCol;
        pnlPCKeyboard.Position.Y := AOuterWidth + iOffset;
      end;
      if KEY_POPUPPANEL then // Now the Popup panel after everything else as iRightCol and iTopRow must be reset
      begin
        if not Assigned(pnlKeyboardPopup) then
        begin
          // Set Popup keyboard panel within the base panel
          pnlKeyboardPopup := TRectangle.Create(Self);
          pnlKeyboardPopup.Name := 'pnlKeyboardPopup';
        end;
        pnlKeyboardPopup.Parent := pnlKeyboardBase;
        SetBorder(pnlKeyboardPopup,False,False,True);
        pnlKeyboardPopup.Fill.Color := KEY_SPACEUPCOLOUR;
        pnlKeyboardPopup.Visible := False;
        AddPopupPanel;
        pnlKeyboardPopup.Size.Height := iTopRow;
        pnlKeyboardPopup.Size.Width := iRightCol;
      end;
      KEY_CURRENTKEYBOARDTYPE := UpperCase(AType);
      KEY_CURRENTDERIVATIVE := UpperCase(ADerivative);
      KEY_CURRENTKEYWIDTH := AKeyWidth;
      KEY_CURRENTKEYHEIGHT := AKeyHeight;
      KEY_CURRENTWIDTH := AWidth;
    end
    else
    begin // Move it
      pnlKeyboardBase.Position.X := AX;
      pnlKeyboardBase.Position.Y := AY;
    end;
    if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, IInterface(ScreenSvc)) then
    begin
      if ScreenSvc.GetScreenSize.Y > 0 then
      begin
        if Round(pnlKeyboardBase.Position.Y + pnlKeyboardBase.Size.Height) > ScreenSvc.GetScreenSize.Y then
        begin
          pnlKeyboardBase.Position.Y := ScreenSvc.GetScreenSize.Y - pnlKeyboardBase.Size.Height;
        end;
      end;
    end;
    KEY_KEEPCAPITALS := not KEY_LPANEL;
    if (not KEY_PPANEL) and (KEY_PANELNO = 3) then
    begin
      KEY_PANELNO := 2; // If attempted initial punctuation panel but it is not defined then set to lower case panel
    end;
    if (not KEY_LPANEL) and (KEY_PANELNO = 2) then
    begin
      KEY_PANELNO := 1; // If attempted initial lowercase panel but it is not defined then set to upper case panel
    end;
    // Make the keyboard visible
    DisplayKeyboard;
  end;
end;

procedure TfrmKeyboard.DisplayKeyboard;
begin
  pnlUCKeyboard.Visible := False;
  HidePopupKeyboard;
  if Assigned(pnlLCKeyboard) then
  begin
    pnlLCKeyboard.Visible := False;
  end;
  if Assigned(pnlPCKeyboard) then
  begin
    pnlPCKeyboard.Visible := False;
  end;
  pnlKeyboardBase.Visible := True;
  case KEY_PANELNO of
    1: pnlUCKeyboard.Visible := True;
    2: pnlLCKeyboard.Visible := True;
    3: pnlPCKeyboard.Visible := True;
  end;
end;

procedure TfrmKeyboard.CloseKeyboard;

  procedure ResetKeys(AKeyboard: TRectangle);
  var
    i: Integer;
  begin
    if AKeyboard.ChildrenCount > 0 then
    begin
      for i := 0 to AKeyboard.ChildrenCount - 1 do
      begin
        if AKeyboard.Children[i] is TRectangle then
        begin
          TRectangle(AKeyboard.Children[i]).Visible := False;
        end
        else
        begin
          if AKeyboard.Children[i] is TImage then
          begin
            TImage(AKeyboard.Children[i]).Visible := False;
          end;
        end;
      end;
    end;
  end;
begin
  if Assigned(pnlUCKeyboard) then
  begin
    ResetKeys(pnlUCKeyboard);
  end;
  if Assigned(pnlLCKeyboard) then
  begin
    ResetKeys(pnlLCKeyboard);
  end;
  if Assigned(pnlPCKeyboard) then
  begin
    ResetKeys(pnlPCKeyboard);
  end;
  if Assigned(pnlKeyboardPopup) then
  begin
    ResetKeys(pnlKeyboardPopup);
  end;
end;

procedure TfrmKeyboard.SwitchKeyboard(APanel: Integer);
begin
  KEY_KEYS := '';
  KEY_UNICODE := '+';
  KEY_MODIFIER := 0;
  KEY_KEEPCAPITALS := not KEY_LPANEL; // Prevents Upper - Lower panel switching
  if KEY_LPANEL or KEY_PPANEL then
  begin
    if APanel > 0 then // ABC, 123 key selected
    begin
      if (APanel = 3) and (KEY_PPANEL) then
      begin
        KEY_PANELNO := 3;
      end
      else
      begin
        if (APanel = 2) and (KEY_LPANEL) then
        begin
          KEY_PANELNO := 2;
        end
        else
        begin
          if APanel <> 3 then
          begin
            KEY_PANELNO := 1;
          end;
        end;
      end;
    end
    else
    begin
      case KEY_PANELNO of
        1: begin
             if KEY_LPANEL then
             begin
               KEY_PANELNO := 2;
             end
             else
             begin
               if KEY_PPANEL then
               begin
                 KEY_PANELNO := 3;
               end;
             end;
           end;
        2: begin
             if KEY_PPANEL and KEY_LPANEL then
             begin
               KEY_PANELNO := 3;
             end
             else
             begin
               KEY_PANELNO := 1;
             end;
           end;
        3: begin
             KEY_PANELNO := 1;
           end;
      end;
    end;
    // If CapsLock is on, reset if panel switched from the Caps panel
    if (KEY_PANELNO <> 1) AND KEY_CAPSLOCKMODE then
    begin
      KEY_CAPSLOCKMODE := False;
      SetToggleKey(KEY_CAPS,KEY_FORM,KEY_CAPSLOCKMODE);
    end;
    DisplayKeyboard;
  end;
  HidePopupKeyboard;
end;

procedure TfrmKeyboard.HidePopupKeyboard;
begin
  ResetActiveKeys;
  if Assigned(pnlKeyboardPopup) then
  begin
    pnlKeyboardPopup.Visible := False;
    pnlKeyboardPopup.Parent := pnlKeyboardBase;
  end;
end;

procedure TfrmKeyboard.ShiftKeyboard;
begin
  if Assigned(pnlLCKeyboard) and KEY_LPANEL then
  begin
    case KEY_PANELNO of
      1: KEY_PANELNO := 2;
      2: KEY_PANELNO := 1;
    end;
  end;
end;

procedure TfrmKeyboard.KeyClick;
begin
  KeyClickSound;
end;

procedure TfrmKeyboard.SetShiftKeys(AState: Boolean);
var
  i: Integer;
  sFrom,sTo: String;
  pnlCharKey: TRectangle;
  pnlSkinKey: TImage;
  sList: TStringList;
begin
  ResetActiveKeys;
  if sKeyboardShift.Count > 0 then
  begin
    sList := TStringList.Create;
    try
      sList.StrictDelimiter := True;
      sList.Delimiter := ',';
      for i := 0 to sKeyboardShift.Count - 1 do
      begin
        sList.DelimitedText := sKeyboardShift[i];
        if AState then
        begin
          sFrom := sList[1];
          sTo := sList[2];
        end
        else
        begin
          sFrom := sList[2];
          sTo := sList[1];
        end;
        if KEY_SKIN > 0 then
        begin
          if sList[0] = 'U' then
          begin
            pnlSkinKey := FindImageComponent(pnlUCKeyboard,sFrom);
          end
          else
          begin
            pnlSkinKey := FindImageComponent(pnlLCKeyboard,sFrom);
          end;
          if pnlSkinKey <> nil then // If found change its name to the shift character
          begin
            pnlSkinKey.Name := sTo;
          end;
        end
        else
        begin
          if sList[0] = 'U' then
          begin
            pnlCharKey := FindRectangleComponent(pnlUCKeyboard,sFrom);
          end
          else
          begin
            pnlCharKey := FindRectangleComponent(pnlLCKeyboard,sFrom);
          end;
          if pnlCharKey <> nil then // If found change its name to the shift character
          begin
            pnlCharKey.Name := sTo;
          end;
        end;
      end;
    finally
      sList.Free;
    end;
  end;
  KEY_INSHIFT := AState;
end;

procedure TfrmKeyboard.SetNumLockKeys(AState: Boolean);
var
  i: Integer;
  sFrom,sTo: String;
  pnlCharKey: TRectangle;
  pnlSkinKey: TImage;
  sList: TStringList;
begin
  if sKeyboardNumLock.Count > 0 then
  begin
    sList := TStringList.Create;
    try
      sList.StrictDelimiter := True;
      sList.Delimiter := ',';
      for i := 0 to sKeyboardNumLock.Count - 1 do
      begin
        sList.DelimitedText := sKeyboardNumLock[i];
        if AState then
        begin
          sFrom := sList[1];
          sTo := sList[2];
        end
        else
        begin
          sFrom := sList[2];
          sTo := sList[1];
        end;
        if KEY_SKIN > 0 then
        begin
          pnlSkinKey := nil;
          if sList[0] = 'U' then
          begin
            pnlSkinKey := FindImageComponent(pnlUCKeyboard,sFrom);
          end
          else
          begin
            if sList[0] = 'L' then
            begin
              pnlSkinKey := FindImageComponent(pnlLCKeyboard,sFrom);
            end
            else
            begin
              if sList[0] = 'P' then
              begin
                pnlSkinKey := FindImageComponent(pnlPCKeyboard,sFrom);
              end;
            end;
          end;
          if pnlSkinKey <> nil then // If found change it's name to the NumLock character
          begin
            pnlSkinKey.Name := sTo;
          end;
        end
        else
        begin
          pnlCharKey := nil;
          if sList[0] = 'U' then
          begin
            pnlCharKey := FindRectangleComponent(pnlUCKeyboard,sFrom);
          end
          else
          begin
            if sList[0] = 'L' then
            begin
              pnlCharKey := FindRectangleComponent(pnlLCKeyboard,sFrom);
            end
            else
            begin
              if sList[0] = 'P' then
              begin
                pnlCharKey := FindRectangleComponent(pnlPCKeyboard,sFrom);
              end;
            end;
          end;
          if pnlCharKey <> nil then // If found change it's name to the NumLock character
          begin
            pnlCharKey.Name := sTo;
          end;
        end;
      end;
    finally
      sList.Free;
    end;
  end;
end;

procedure TfrmKeyboard.SetToggleKey(AKey: Integer; AForm: TForm; AState: Boolean);
var
  i: Integer;
  sKeyNo,sPanel: String;
  oField: TObject;
begin
  sKeyNo := IntToStr(SetKeyASCII(AKey)).PadLeft(KEY_DIGITS,'0');
  if sKeyboardModeList.Count > 0 then
  begin
    for i := 0 to sKeyboardModeList.Count - 1 do
    begin
      if Copy(sKeyboardModeList[i],Length(sKeyboardModeList[i]) - KEY_DIGITS + 1) = sKeyNo then
      begin
        sPanel := Copy(sKeyboardModeList[i],Length(sKeyboardModeList[i]) - KEY_DIGITS,1);
        if KEY_SKIN > 0 then
        begin
          if (sPanel = 'L') and Assigned(pnlLCKeyboard) then
          begin
            oField := FindImageComponent(pnlLCKeyboard,'pnlSkin' + Copy(sKeyboardModeList[i],KEY_DIGITS));
          end
          else
          begin
            if (sPanel = 'P') and Assigned(pnlPCKeyboard) then
            begin
              oField := FindImageComponent(pnlPCKeyboard,'pnlSkin' + Copy(sKeyboardModeList[i],KEY_DIGITS));
            end
            else
            begin
              oField := FindImageComponent(pnlUCKeyboard,'pnlSkin' + Copy(sKeyboardModeList[i],KEY_DIGITS));
            end;
          end;
        end
        else
        begin
          if (sPanel = 'L') and Assigned(pnlLCKeyboard) then
          begin
            oField := FindRectangleComponent(pnlLCKeyboard,'pnlChar' + Copy(sKeyboardModeList[i],KEY_DIGITS));
          end
          else
          begin
            if (sPanel = 'P') and Assigned(pnlPCKeyboard) then
            begin
              oField := FindRectangleComponent(pnlPCKeyboard,'pnlChar' + Copy(sKeyboardModeList[i],KEY_DIGITS));
            end
            else
            begin
              oField := FindRectangleComponent(pnlUCKeyboard,'pnlChar' + Copy(sKeyboardModeList[i],KEY_DIGITS));
            end;
          end;
        end;
        if oField <> nil then
        begin
          if KEY_SKIN > 0 then
          begin
            oField := TLabel(FindSkinComponent(TImage(oField),sKeyboardModeList[i]));
          end
          else
          begin
            oField := FindLabelComponent(TRectangle(oField),sKeyboardModeList[i]);
          end;
          if oField <> nil then
          begin
            if AState then
            begin
              TLabel(oField).Font.Style := [TFontStyle.fsBold];
            end
            else
            begin
              TLabel(oField).Font.Style := [];
            end;
          end;
        end;
      end;
    end;
  end;
  case AKey of
    KEY_CAPS:
      begin
        KEY_KEEPCAPITALS := AState;
        if AState then
        begin
          KEY_PANELNO := 1;
          DisplayKeyboard;
        end
        else
        begin
          if (not KEY_KEEPCAPITALS) and KEY_LPANEL then
          begin
            KEY_PANELNO := 2;
            DisplayKeyboard;
          end;
        end;
      end;
    KEY_NUMLOCK:
      begin
        KEY_NUMLOCKMODE := AState;
      end;
    KEY_INSERT,KEY_NUMINSERT:
      begin
        KEY_INSERTMODE := AState;
      end;
  end;
end;

procedure TfrmKeyboard.ResetActiveKeys;
var
  i,j: Integer;
  sName,sSaveName: String;
  imgKey: TImage;
  pnlKey: TRectangle;
begin
  if Assigned(pnlKeyboardBase) and (sKeyDownList.Count > 0) then
  begin
    sSaveName := '';
    for i := 0 to sKeyDownList.Count - 1 do
    begin
      sName := sKeyDownList[i];
      if not (KEY_ALTGRDOWN and (Copy(sName,Length(sName) - KEY_DIGITS + 1,KEY_DIGITS) = IntToStr(KEY_ALTGR))) then
      begin
        j := 1;
        if Copy(sName,KEY_NAMETYPEPOSITION,1) = 'P' then
        begin
          j := 3;
        end
        else
        begin
          if Copy(sName,KEY_NAMETYPEPOSITION,1) = 'L' then
          begin
            j := 2;
          end
          else
          begin
            if Copy(sName,KEY_NAMETYPEPOSITION,1) = 'C' then
            begin
              j := 4;
            end;
          end;
        end;
        if KEY_SKIN = 0 then
        begin
          pnlKey := nil;
          case j of
            1: pnlKey := FindRectangleComponent(pnlUCKeyboard,sName);
            2: pnlKey := FindRectangleComponent(pnlLCKeyboard,sName);
            3: pnlKey := FindRectangleComponent(pnlPCKeyboard,sName);
            4: pnlKey := FindRectangleComponent(pnlKeyboardPopup,sName);
          end;
          if pnlKey <> nil then
          begin
            if StrToIntDef(Copy(sName,Length(sName) - KEY_DIGITS + 1,KEY_DIGITS),-1) = KEY_SPACE then
            begin
              pnlKey.Fill.Color := KEY_SPACEUPCOLOUR;
            end
            else
            begin
              pnlKey.Fill.Color := KEY_UPCOLOUR;
            end;
          end;
        end
        else
        begin
          imgKey := nil;
          case j of
            1: imgKey := FindImageComponent(pnlUCKeyboard,sName);
            2: imgKey := FindImageComponent(pnlLCKeyboard,sName);
            3: imgKey := FindImageComponent(pnlPCKeyboard,sName);
            4: imgKey := FindImageComponent(pnlKeyboardPopup,sName);
          end;
          if imgKey <> nil then
          begin
            imgKey.Bitmap := KEY_SKINUP.Bitmap;
            AdjustLabelPosition(imgKey,True);
          end;
        end;
      end
      else
      begin
        sSaveName := sName;
      end;
    end;
    sKeyDownList.Clear;
    if sSaveName <> '' then // Add it back in for the next reset
    begin
      sKeyDownList.Add(sSaveName);
    end;
  end;
end;

procedure TfrmKeyboard.AdjustLabelPosition(AImage: TImage; AUp: Boolean);
var
  i: Integer;
  lblKey: TLabel;
  lblImage: TImage;
  iOffset: Integer;
begin
  if (KEY_ADJUSTOFFSET > 0) and (AImage.ChildrenCount > 0) then
  begin
    i := 0;
    iOffset := KEY_ADJUSTOFFSET;
    if AUp then
    begin
      iOffset := iOffset * -1;
    end;
    while i < AImage.ChildrenCount do
    begin
      if AImage.Children[i] is TLabel then
      begin
        lblKey := TLabel(AImage.Children[i]);
        if Copy(lblKey.Name,2,2) = 'TL' then
        begin
          lblKey.Position.X := lblKey.Position.X - iOffset;
          lblKey.Position.Y := lblKey.Position.Y - iOffset;
        end
        else
        begin
          if Copy(lblKey.Name,2,2) = 'TR' then
          begin
            lblKey.Position.X := lblKey.Position.X + iOffset;
            lblKey.Position.Y := lblKey.Position.Y - iOffset;
          end
          else
          begin
            if Copy(lblKey.Name,2,2) = 'BL' then
            begin
              lblKey.Position.X := lblKey.Position.X - iOffset;
              lblKey.Position.Y := lblKey.Position.Y + iOffset;
            end
            else
            begin
              if Copy(lblKey.Name,2,2) = 'BR' then
              begin
                lblKey.Position.X := lblKey.Position.X + iOffset;
                lblKey.Position.Y := lblKey.Position.Y + iOffset;
              end;
            end;
          end;
        end;
      end
      else
      begin
        if AImage.Children[i] is TImage then
        begin
          lblImage := TImage(AImage.Children[i]);
          if Copy(lblImage.Name,2,2) = 'TL' then
          begin
            lblImage.Position.X := lblImage.Position.X - iOffset;
            lblImage.Position.Y := lblImage.Position.Y - iOffset;
          end
          else
          begin
            if Copy(lblImage.Name,2,2) = 'TR' then
            begin
              lblImage.Position.X := lblImage.Position.X + iOffset;
              lblImage.Position.Y := lblImage.Position.Y - iOffset;
            end
            else
            begin
              if Copy(lblImage.Name,2,2) = 'BL' then
              begin
                lblImage.Position.X := lblImage.Position.X - iOffset;
                lblImage.Position.Y := lblImage.Position.Y + iOffset;
              end
              else
              begin
                if Copy(lblImage.Name,2,2) = 'BR' then
                begin
                  lblImage.Position.X := lblImage.Position.X + iOffset;
                  lblImage.Position.Y := lblImage.Position.Y + iOffset;
                end;
              end;
            end;
          end;
        end
      end;
      i := i + 1;
    end;
  end;
end;

procedure TfrmKeyboard.CharKeyDown(Sender: TObject);
begin
  ResetActiveKeys;
  ProcessAKey(Sender);
end;

procedure TfrmKeyboard.CharKeyUp(Sender: TObject);
begin
  ResetActiveKeys;
end;

procedure TfrmKeyboard.AddToKeys(AKey: String);
var
  sKeys: String;
begin
  sKeys := KEY_KEYS;
  // Add if a new key press
  if Pos(AKey,sKeys) = 0 then
  begin
    sKeys := sKeys + AKey;
  end;
  KEY_KEYS := sKeys;
end;

procedure TfrmKeyboard.ProcessAKey(Sender: TObject);
var
  iASCII,i: Integer;
  bSpaceFound, bModifierPressed: Boolean;
  sLine: String;

  procedure UpdateTheKeySkin(AImage: TImage);
  begin
    AImage.Bitmap := KEY_SKINDOWN.Bitmap;
    sKeyDownList.Add(AImage.Name);
    AdjustLabelPosition(AImage,False);
  end;

  procedure UpdateTheKeyNoSkin(APanel: TRectangle);
  begin
    APanel.Fill.Color := KEY_DOWNCOLOUR;
    sKeyDownList.Add(APanel.Name);
  end;

  function GetDefaultPopupChar(AList: TStringList): Integer;
  var
    iChar: Integer;
    sChar: String;
  begin
    iChar := 0;
    if Assigned(AList) then
    begin
      if AList.Count > 0 then
      begin
        sChar := AList[0];
        iChar := KeyOrd(sChar[1]);
      end;
    end;
    Result := iChar;
  end;

  procedure ProcessFieldWithKey(AASCII: Integer; AKeys: String; AForm: TForm; AFieldname: String);
  var
    sAdd: String;
    bUpdate: Boolean;
    iStart,iSelectedLength,iLength,iKeyType,iASCII: Integer;
    // iStartCaretPos,iStartCaretLine: Integer;

    function IsItAModifier(AASCII: Integer): Boolean;
    var
      i: Integer;
      bResult: Boolean;
    begin
      bResult := False;
      i := sKeyboardModifier.IndexOf(IntToStr(KeyASCII(AASCII)).PadLeft(KEY_DIGITS,'0'));
      if i <> -1 then
      begin
        bResult := True;
      end;
      Result := bResult;
    end;

    function ApplyModifier(AText: String; AModifier: Integer): String;
    var
      i,j,k: Integer;
      sChar,sTarget,sModifiers: String;
    begin
      sChar := '';
      if AText <> '' then
      begin
        i := sKeyboardModifier.IndexOf(IntToStr(KeyASCII(AModifier)).PadLeft(KEY_DIGITS,'0'));
        if i <> -1 then
        begin
          j := KEY_MODIFIERSTART + i; // Modifier starting position
          sModifiers := KEY_LANGTEXT[j];
          sTarget := ',' + IntToStr(Ord(AText[1])) + ':';
          i := Pos(sTarget,sModifiers); // Find the modify character position (if it exists), offset to miss 4-digit modifier code
          if i > 0 then // This character can be modified
          begin
            // Find next , or end of text from i + Length(sTarget)
            j := i + Length(sTarget);
            k := Length(sModifiers);
            if iSelectedLength = 0 then // Force apply to last character
            begin
              if iStart > 0 then
              begin
                iStart := iStart - 1;
              end;
              iSelectedLength := 1;
            end;
            while (j <= k) do
            begin
              if sModifiers[j] = ',' then
              begin
                j := k + 1; // End it
              end
              else
              begin
                sChar := sChar + sModifiers[j];
                j := j + 1;
              end;
            end;
          end;
        end;
      end;
      Result := sChar;
    end;

  begin
    sAdd := '';
    iKeyType := KEY_TYPEUNKNOWN;
    bUpdate := False;
    iASCII := AASCII;
    if KEY_FIELDTYPE <> KEY_FIELD_UNKNOWN then
    begin
      FieldGetStartLength(iStart,iSelectedLength,iLength);
      // Override for Popup
      if Assigned(pnlKeyboardPopup) and pnlKeyboardPopup.Visible then
      begin
        KEY_KEYS := 'ctrl+';
        case iASCII of
          KEY_POPUPSELECTALL: iASCII := GetDefaultPopupChar(sKeyboardSelectAll);
          KEY_POPUPCOPY: iASCII := GetDefaultPopupChar(sKeyboardCopy);
          KEY_POPUPPASTE: iASCII := GetDefaultPopupChar(sKeyboardPaste);
          KEY_POPUPCUT: iASCII := GetDefaultPopupChar(sKeyboardCut);
        end;
        HidePopupKeyboard;
      end;
      case iASCII of
        KEY_BACKSPACE:
          begin
            if KEY_KEYS = '' then // If KEY_KEYS set then Backspace clears that before doing anything else
            begin
              bUpdate := not KEY_READONLY;
              if not ((iStart > 0) and (iSelectedLength > 0)) then
              begin
                if iStart > 0 then
                begin
                  // If Memo field and column zero then need to force move to previous line
                  if (KEY_FIELDTYPE = KEY_FIELD_TMEMO) and (FieldGetCaretPos.Y > 0) and (FieldGetCaretPos.X = 0) then
                  begin
                    iStart := FieldGetStart - 1;
                  end;
                  iStart := iStart - 1;
                  if iSelectedLength = 0  then
                  begin
                    iSelectedLength := 1;
                  end;
                end;
              end;
            end;
          end;
        KEY_DELETE:
          begin
            if iStart < iLength then
            begin
              bUpdate := not KEY_READONLY;
              if iSelectedLength = 0 then
              begin
                iSelectedLength := 1;
              end;
            end;
          end;
        KEY_POPUP:
          begin
            if Assigned(pnlKeyboardPopup) then
            begin
              ShowKeyboardPopup(Sender);
            end;
          end;
        KEY_PGDN:
          begin
            if KEY_FIELDTYPE = KEY_FIELD_TMEMO then
            begin
              FieldSetSelected(0);
              if FieldGetLinesCount > 0 then
              begin
                FieldSetCaretPos(FieldGetCaretLine + FieldGetVisibleLines,FieldGetCaretPosition);
              end;
            end;
          end;
        KEY_PGUP:
          begin
            if KEY_FIELDTYPE = KEY_FIELD_TMEMO then
            begin
              FieldSetSelected(0);
              if FieldGetLinesCount > 0 then
              begin
                FieldSetCaretPos(FieldGetCaretLine - FieldGetVisibleLines,FieldGetCaretPosition);
              end;
            end;
          end;
        KEY_HOME:
          begin
            if KEY_FIELDTYPE = KEY_FIELD_TMEMO then
            begin
              FieldGoToLineStart;
            end
            else
            begin
              if KEY_FIELDTYPE = KEY_FIELD_TEDIT then
              begin
                FieldGoToLineStart;
                FieldSetStart(0);
                FieldSetSelected(0);
              end;
            end;
          end;
        KEY_END:
          begin
            if KEY_FIELDTYPE = KEY_FIELD_TMEMO then
            begin
              FieldGoToLineEnd;
            end
            else
            begin
              if KEY_FIELDTYPE = KEY_FIELD_TEDIT then
              begin
                FieldGoToLineEnd;
                FieldSetStart(iLength);
                FieldSetSelected(0);
              end;
            end;
          end;
        KEY_F1..KEY_F12:
          begin
            if KEY_KEYS <> '' then
            begin
              if KEY_KEYS = 'alt+' then
              begin
                iKeyType := KEY_TYPEALTF;
              end
              else
              begin
                if (KEY_KEYS = 'ctrl+alt+') or (KEY_KEYS = 'alt+ctrl+') then
                begin
                  iKeyType := KEY_TYPECTRLALTF;
                end
                else
                begin
                  if KEY_KEYS = 'fn+' then
                  begin
                    iKeyType := KEY_TYPEFNF;
                  end
                  else
                  begin
                    if KEY_KEYS = 'ctrl+' then
                    begin
                      iKeyType := KEY_TYPECTRLF;
                    end;
                  end;
                end;
              end;
              if iKeyType <> KEY_TYPEUNKNOWN then
              begin
                KeyCallbackProcedure(iASCII - KEY_F1 + 1,iKeyType,KEY_FORM,KEY_FIELDNAME);
              end;
            end
            else
            begin
              if KEY_INSHIFT then
              begin
                KeyCallbackProcedure(iASCII - KEY_F1 + 1,KEY_TYPESHIFTF,KEY_FORM,KEY_FIELDNAME);
              end
              else
              begin
                KeyCallbackProcedure(iASCII - KEY_F1 + 1,KEY_TYPEF,KEY_FORM,KEY_FIELDNAME);
              end;
            end;
          end;
        KEY_CURSORLEFT,KEY_CURSORNUMLEFT:
          begin
            case KEY_FIELDTYPE of
              KEY_FIELD_TMEMO:
                begin
                  if iStart > 0 then
                  begin
                    if (KEY_KEYS = 'ctrl+') and (FieldGetCaretPosition > 0) then
                    begin
                      i := FieldGetCaretPosition;
                      sLine := FieldGetLineText(FieldGetCaretLine);
                      while (i > 0) and (Copy(sLine,i,1) = ' ') do // First search for a character
                      begin
                        i := i - 1;
                      end;
                      while (i > 0) and (Copy(sLine,i,1) <> ' ') do // Then look for a space
                      begin
                        i := i - 1;
                      end;
                      FieldSetCaretPos(FieldGetCaretLine,i);
                      FieldSetSelected(0);
                    end
                    else
                    begin
                      if KEY_INSHIFT then
                      begin
                        if KEY_SELECTSTART = -1 then
                        begin
                          KEY_SELECTSTART := iStart;
                        end;
                        if iStart < KEY_SELECTSTART then
                        begin
                          FieldSetStart(iStart - 1);
                          iSelectedLength := KEY_SELECTSTART - iStart;
                          FieldSetSelected(iSelectedLength + 1);
                        end
                        else
                        begin
                          FieldSetStart(iStart);
                          FieldSetSelected(iSelectedLength - 1);
                        end;
                      end
                      else
                      begin
                        if (FieldGetCaretPos.X = 0) and (FieldGetCaretLine > 0) then
                        begin
                          FieldSetCaretPos(FieldGetCaretLine - 1,0);
                          FieldGoToLineEnd;
                        end
                        else
                        begin
                          FieldSetStart(iStart - 1);
                        end;
                        FieldSetSelected(0);
                      end;
                    end;
                  end;
                end;
              KEY_FIELD_TEDIT:
                begin
                  if iStart > 0 then
                  begin
                    if KEY_KEYS = 'ctrl+' then
                    begin
                      i := FieldGetStart;
                      sLine := FieldGetLineText(-1);
                      while (i > 0) and (Copy(sLine,i,1) = ' ') do // First search for a character
                      begin
                        i := i - 1;
                      end;
                      while (i > 0) and (Copy(sLine,i,1) <> ' ') do // Then look for a space
                      begin
                        i := i - 1;
                      end;
                      FieldSetStart(i);
                      FieldSetSelected(0);
                    end
                    else
                    begin
                      if KEY_INSHIFT then
                      begin
                        if KEY_SELECTSTART = -1 then
                        begin
                          KEY_SELECTSTART := iStart;
                        end;
                        if iStart < KEY_SELECTSTART then
                        begin
                          FieldSetStart(iStart - 1);
                          iSelectedLength := KEY_SELECTSTART - iStart;
                          FieldSetSelected(iSelectedLength + 1);
                        end
                        else
                        begin
                          FieldSetStart(iStart);
                          FieldSetSelected(iSelectedLength - 1);
                        end;
                      end
                      else
                      begin
                        FieldSetStart(iStart - 1);
                        FieldSetSelected(0);
                      end;
                    end;
                  end;
                end;
            end;
          end;
        KEY_CURSORRIGHT,KEY_CURSORNUMRIGHT:
          begin
            case KEY_FIELDTYPE of
{              KEY_FIELD_TMEMO:
                begin
                  iStart := FieldGetCaretPosition;
                  if KEY_KEYS = 'ctrl+' then
                  begin
                    i := iStart + 1;
                    if FieldGetLinesCount > 0 then
                    begin
                      sLine := FieldGetLineText(FieldGetCaretLine);
                    end
                    else
                    begin
                      sLine := FieldGetLineText(-1);
                    end;
                    iLength := Length(sLine);
                    while (i < iLength) and (Copy(sLine,i,1) <> ' ') do // First search for a space
                    begin
                      i := i + 1;
                    end;
                    bSpaceFound := False;
                    while (i <= iLength) and (Copy(sLine,i,1) = ' ') do // Then look for a character
                    begin
                      bSpaceFound := True;
                      i := i + 1;
                    end;
                    if not bSpaceFound then
                    begin
                      if (i = iLength) and (i <> (iStart + 1)) then
                      begin
                        FieldGoToLineEnd;
                      end
                      else
                      begin
                        FieldSetCaretPos(FieldGetCaretLine + 1,0);
                      end;
                    end
                    else
                    begin
                      FieldSetCaretPos(FieldGetCaretLine,i - 1);
                    end;
                    FieldSetSelected(0);
                  end
                  else
                  begin
                    //showmessage('a: ' + IntToStr(FieldGetStart));
                    if Round(FieldGetCaretPosition) = Length(FieldGetLineText(FieldGetCaretLine)) then
                    begin
                      FieldSetCaretPos(FieldGetCaretLine + 1,0);
                    end
                    else
                    begin
                      FieldSetCaretPos(FieldGetCaretLine,Round(FieldGetCaretPosition) + 1);
                    end;
                    iStart := FieldGetStart;
                    if iStart = 0 then
                    showmessage(IntToStr(FieldGetStart));
                    //showmessage('b: ' + IntToStr(FieldGetStart));
                    if KEY_INSHIFT then
                    begin
                      if KEY_SELECTSTART = -1 then
                      begin
                        KEY_SELECTSTART := iStart - 1;
                      end;
                      if KEY_SELECTSTART <> -1 then
                      begin
                        FieldSetStart(KEY_SELECTSTART);

                        FieldSetSelected(iStart - KEY_SELECTSTART);
                      end;
                    end;
                    // showmessage(IntToStr(FieldGetStart));
                    // When moving to new line, you must add 2 chars CR + LF
                    {
                    if KEY_INSHIFT then
                    begin
                      if KEY_SELECTSTART = -1 then
                      begin
                        KEY_SELECTSTART := iStart - 1;
                      end;
                      if iStart < KEY_SELECTSTART then
                      begin
                        iSelectedLength := KEY_SELECTSTART - iStart;
                        FieldSetSelected(iSelectedLength + 1);
                      end
                      else
                      begin
                        if iStart >= (KEY_SELECTSTART) then
                        begin
                          iSelectedLength := iStart - KEY_SELECTSTART + 1;
                        end
                        else
                        begin
                          iSelectedLength := 1;
                        end;
                        FieldSetStart(KEY_SELECTSTART);
                        FieldSetSelected(iSelectedLength);
                      end;
                    end
                    else
                    begin
                      if (KEY_SELECTSTART <> -1) then
                      begin
                        FieldSetStart(KEY_SELECTSTART + iSelectedLength + 1);
                      end
                      else
                      begin
                        FieldSetStart(iStart + 1);
                      end;
                      FieldSetSelected(0);
                    end;
                    //FieldSetSelected(0);
                  end;
                end;  }
              KEY_FIELD_TEDIT,KEY_FIELD_TMEMO:
                begin
                  if KEY_KEYS = 'ctrl+' then
                  begin
                    i := iStart + 1;
                    sLine := FieldGetLineText(-1);
                    while (i < iLength) and (Copy(sLine,i,1) <> ' ') do // First search for a space
                    begin
                      i := i + 1;
                    end;
                    bSpaceFound := False;
                    while (i <= iLength) and (Copy(sLine,i,1) = ' ') do // Then look for a character
                    begin
                      bSpaceFound := True;
                      i := i + 1;
                    end;
                    if not bSpaceFound then
                    begin
                      FieldGoToLineEnd;
                    end
                    else
                    begin
                      FieldSetStart(i - 1);
                    end;
                    FieldSetSelected(0);
                  end
                  else
                  begin
                    if KEY_INSHIFT then
                    begin
                      if KEY_SELECTSTART = -1 then
                      begin
                        KEY_SELECTSTART := iStart;
                      end;
                      if iStart < KEY_SELECTSTART then
                      begin
                        FieldSetStart(iStart + 1);
                        FieldSetSelected(KEY_SELECTSTART - iStart - 1);
                      end
                      else
                      begin
                        if (iStart + iSelectedLength) < iLength then
                        begin
                          FieldSetSelected(iSelectedLength + 1);
                          showmessage('eol 1');
                        end
                        else
                        begin
                          FieldSetSelected(iSelectedLength + 1);
                          showmessage('eol 2');
                        end;
                      end;
                    end
                    else
                    begin
                      if (KEY_SELECTSTART <> -1) then
                      begin
                        FieldSetStart(KEY_SELECTSTART + iSelectedLength + 1);
                      end
                      else
                      begin
                        FieldSetStart(iStart + 1);
                      end;
                      FieldSetSelected(0);
                    end;
                  end;
                end;
            end;
          end;
        KEY_CURSORDOWN,KEY_CURSORNUMDOWN:
          begin
            if KEY_FIELDTYPE = KEY_FIELD_TMEMO then
            begin
              FieldSetSelected(0);
              if KEY_KEYS = 'ctrl+' then
              begin
                FieldScrollMultipleLines(True);
              end
              else
              begin
                if FieldGetCaretLine < (FieldGetLinesCount - 1) then
                begin
                  FieldSetCaretPos(FieldGetCaretLine + 1,FieldGetCaretPosition);
                end;
              end;
            end;
          end;
        KEY_CURSORUP,KEY_CURSORNUMUP:
          begin
            if KEY_FIELDTYPE = KEY_FIELD_TMEMO then
            begin
              FieldSetSelected(0);
              if KEY_KEYS = 'ctrl+' then
              begin
                FieldScrollMultipleLines(False);
              end
              else
              begin
                if FieldGetCaretLine > 0 then
                begin
                  FieldSetCaretPos(FieldGetCaretLine - 1,FieldGetCaretPosition);
                end;
              end;
            end;
          end;
        KEY_ESC:
          begin
            HidePopupKeyboard;
            KeyCallbackProcedure(iASCII,KEY_TYPEKEY,KEY_FORM,KEY_FIELDNAME);
          end;
      else
        begin
          if (Pos('ctrl+',KEY_KEYS) > 0) or (Pos('alt+',KEY_KEYS) > 0) or (Pos('altgr+',KEY_KEYS) > 0) or (Pos('altgr+shift+',KEY_KEYS) > 0) or (Pos('fn+',KEY_KEYS) > 0) or (Pos('f+',KEY_KEYS) > 0) then
          begin
            if (KEY_KEYS = 'ctrl+altgr+') or (KEY_KEYS = 'altgr+ctrl+') then
            begin
              iKeyType := KEY_TYPECTRLALTGR;
            end
            else
            begin
              if (KEY_KEYS = 'ctrl+alt+') or (KEY_KEYS = 'alt+ctrl+') then
              begin
                iKeyType := KEY_TYPECTRLALT;
              end
              else
              begin
                if (KEY_KEYS = 'ctrl+fn+') or (KEY_KEYS = 'fn+ctrl+') then
                begin
                  iKeyType := KEY_TYPECTRLFN;
                end
                else
                begin
                  if KEY_KEYS = 'ctrl+' then
                  begin
                    iKeyType := KEY_TYPECTRL;
                  end
                  else
                  begin
                    if KEY_KEYS = 'fn+' then
                    begin
                      iKeyType := KEY_TYPEFN;
                    end
                    else
                    begin
                      if KEY_KEYS = 'altgr+' then
                      begin
                        iKeyType := KEY_TYPEALTGR;
                      end
                      else
                      begin
                        if KEY_KEYS = 'altgr+shift+' then
                        begin
                          iKeyType := KEY_TYPEALTGRSHIFT;
                        end
                        else
                        begin
                          if KEY_KEYS = 'alt+' then
                          begin
                            iKeyType := KEY_TYPEALT;
                          end;
                        end;
                      end;
                    end;
                  end;
                end;
              end;
            end;
            if iKeyType <> KEY_TYPEUNKNOWN then
            begin
              if iKeyType = KEY_TYPECTRL then
              begin
                if sKeyboardCopy.IndexOf(Chr(iASCII)) <> -1 then // Copy+C
                begin
                  FieldSetClipboard;
                end
                else
                begin
                  if sKeyboardSelectAll.IndexOf(Chr(iASCII)) <> -1 then // Ctrl+A
                  begin
                    FieldSelectAll;
                  end
                  else
                  begin
                    if sKeyboardPaste.IndexOf(Chr(iASCII)) <> -1 then // Ctrl+V
                    begin
                      sAdd := FieldGetClipboardText;
                      bUpdate := not KEY_READONLY;
                    end
                    else
                    begin
                      if sKeyboardCut.IndexOf(Chr(iASCII)) <> -1 then // Ctrl+X
                      begin
                        FieldSetClipboard;
                        bUpdate := not KEY_READONLY;
                      end;
                    end;
                  end;
                end;
              end
              else
              begin
                if (iKeyType = KEY_TYPEALTGR) or (iKeyType = KEY_TYPEALTGRSHIFT) then
                begin
                  if iKeyType = KEY_TYPEALTGR then
                  begin
                    i := sKeyboardAltGrKey.IndexOf(IntToStr(SetKeyASCII(iASCII)).PadLeft(KEY_DIGITS,'0'));
                  end
                  else
                  begin
                    i := sKeyboardShiftAltGrKey.IndexOf(IntToStr(SetKeyASCII(iASCII)).PadLeft(KEY_DIGITS,'0'));
                  end;
                  if i <> -1 then
                  begin
                    bUpdate := not KEY_READONLY;
                    KEY_KEYS := ''; // Done
                    KEY_UNICODE := '+';
                    if iKeyType = KEY_TYPEALTGR then
                    begin
                      iASCII := StrToInt(sKeyboardAltGr[i]);
                    end
                    else
                    begin
                      iASCII := StrToInt(sKeyboardShiftAltGr[i]);
                    end;
                    sAdd := KeyChr(iASCII);
                  end;
                end
                else
                begin
                  if iKeyType = KEY_TYPECTRLALT then
                  begin
                    i := sKeyboardAltKey.IndexOf(IntToStr(SetKeyASCII(iASCII)).PadLeft(KEY_DIGITS,'0'));
                    if i <> -1 then
                    begin
                      bUpdate := not KEY_READONLY;
                      iASCII := StrToInt(sKeyboardAlt[i]);
                      sAdd := KeyChr(iASCII);
                    end;
                  end
                  else
                  begin
                    if iKeyType = KEY_TYPEALT then
                    begin
                      bUpdate := not KEY_READONLY;
                      sAdd := KeyChr(iASCII);
                      KEY_UNICODE := '';
                    end;
                  end;
                end;
              end;
              if KEY_UNICODE <> '' then // Do not call back if just triggered Unicode char entry
              begin
                KeyCallbackProcedure(iASCII,iKeyType,KEY_FORM,KEY_FIELDNAME);
              end;
            end
            else
            begin
              KEY_KEYS := '';
              KEY_UNICODE := '+';
            end;
          end
          else
          begin
            bUpdate := not KEY_READONLY;
            if iASCII = KEY_ENTER then
            begin
              case KEY_FIELDTYPE of
                KEY_FIELD_TEDIT: // Move to next field if Enter pressed in a field which is not multiline
                  begin
                    KeyCallbackProcedure(iASCII,KEY_TYPEKEY,KEY_FORM,KEY_FIELDNAME);
                  end;
                KEY_FIELD_TMEMO:
                  begin
                    sAdd := FieldGetLineBreak;
                  end;
              end;
            end
            else
            begin
              sAdd := Chr(iASCII);
            end;
          end;
        end;
      end;
      if bUpdate then // Direct entry of Unicode value might change this
      begin
        if KEY_UNICODE <> '+' then
        begin
          // Do not present this key
          bUpdate := False;
          if iASCII = KEY_PLUS then // Reset if + selected whilst still in unicode entry mode
          begin
            KEY_UNICODE := '';
          end;
          if ((iASCII < 48) or (iASCII > 57)) and (iASCII <> KEY_ENTER) and (iASCII <> KEY_PLUS) then
          begin
            KEY_UNICODE := '+';
          end
          else
          begin
            if (iASCII <> KEY_ENTER) and (iASCII <> KEY_PLUS) then
            begin
              KEY_UNICODE := KEY_UNICODE + Chr(iASCII);
            end;
            if (Length(KEY_UNICODE) = 6) or (iASCII = KEY_ENTER) then // End on entry of six numeric digits or Enter key
            begin
              iASCII := StrToIntDef(KEY_UNICODE,0);
              if (iASCII > 0) and (iASCII <= 137994) then // Valid Unicode value
              begin
                sAdd := Chr(iASCII); // Override and force update
                bUpdate := not KEY_READONLY;
              end;
              KEY_UNICODE := '+';
            end;
          end;
        end;
      end;
      if bUpdate then
      begin
        // Check and apply modifier key if relevant
        bModifierPressed := IsItAModifier(iASCII);
        if bModifierPressed then
        begin
          if iSelectedLength <> 0 then
          begin
            sAdd := ApplyModifier(FieldGetSelectedText,iASCII);
          end
          else
          begin
            KEY_MODIFIER := iASCII;
          end;
        end
        else
        begin
          if KEY_MODIFIER <> 0 then // Apply modifier key to this one
          begin
            sAdd := ApplyModifier(sAdd,KEY_MODIFIER);
          end;
          KEY_MODIFIER := 0;
        end;
        // If not Insert mode
        if (sAdd <> '') and (not KEY_INSERTMODE) and (iSelectedLength = 0) then
        begin
          iSelectedLength := Length(sAdd);
        end;
        FieldSetStart(iStart);
        FieldSetSelected(iSelectedLength);
        if iSelectedLength <> 0 then
        begin
          FieldDeleteSelected;
        end;
        if sAdd <> '' then
        begin
          FieldInsertText(sAdd);
          FieldSetStart(FieldGetStart + Length(sAdd));
        end;
        KeyCallbackProcedure(iASCII,KEY_TYPEKEY,KEY_FORM,KEY_FIELDNAME);
      end;
    end;
    if (iASCII <> KEY_ALTGR) and (iASCII <> KEY_SHIFTIN) and (iASCII <> KEY_CTRL) then // Modifer behavior needs this
    begin
      KEY_KEYS := '';
    end;
  end;
begin
  iASCII := GetASCIIFromKeyName(Sender);
  if iASCII <> -1 then
  begin
    // Change the key status to show it is pressed
    if Assigned(pnlKeyboardBase) then
    begin
      if KEY_SKIN > 0 then
      begin
        if Sender is TImage then
        begin
          if Copy(TImage(Sender).Name,1,1) = 'i' then // "img" is key base panel, "i" is modifier key image
          begin
            UpdateTheKeySkin(TImage(TImage(Sender).Parent));
          end
          else
          begin
            if Copy(TImage(Sender).Name,1,3) = 'pnl' then
            begin
              UpdateTheKeySkin(TImage(TImage(Sender)));
            end;
          end;
        end;
      end
      else
      begin
        if Sender is TRectangle then
        begin
          UpdateTheKeyNoSkin(TRectangle(TRectangle(Sender)));
        end;
      end;
    end;
    KeyClick;
    bModifierPressed := False;
    if (iASCII = KEY_TABNEXT) or (iASCII = KEY_TABPREVIOUS) then
    begin
      if KEY_INSHIFT then
      begin
        KeyCallbackProcedure(KEY_TABPREVIOUS,KEY_TYPETAB,KEY_FORM,KEY_FIELDNAME);
      end
      else
      begin
        KeyCallbackProcedure(KEY_TABNEXT,KEY_TYPETAB,KEY_FORM,KEY_FIELDNAME);
      end;
      KEY_KEYS := '';
    end
    else
    begin
      case iASCII of // Check for keyboard related changes
        KEY_SWITCHU,KEY_SWITCHL,KEY_SWITCHP: SwitchKeyboard(0);
        KEY_ABC: SwitchKeyboard(2); // Alphabetic keyboard, L first, if not available then the U keyboard
        KEY_123: SwitchKeyboard(3); // Numeric and puncuation keyboard
        KEY_SHIFTIN:
          begin
            if Pos('altgr+',KEY_KEYS) > 0 then // Enable use of AltGr+Shift
            begin
              AddToKeys('shift+');
            end
            else
            begin
              ShiftKeyboard;
              SetShiftKeys((not KEY_INSHIFT)); // Flip it
              DisplayKeyboard;
            end;
          end;
        KEY_CAPS:
          begin
            if KEY_FIELDCASE = KEY_FIELDMIXEDCASE then
            begin
              KEY_CAPSLOCKMODE := not KEY_CAPSLOCKMODE;
              if KEY_INSHIFT then
              begin
                ShiftKeyboard;
                KEY_INSHIFT := False;
              end;
              if KEY_CAPSLOCKMODE then
              begin
                SwitchKeyboard(1);
              end
              else
              begin
                SwitchKeyboard(2);
              end;
              SetToggleKey(KEY_CAPS,KEY_FORM,KEY_CAPSLOCKMODE);
            end;
          end;
        KEY_MICROPHONE,KEY_WINDOWS,KEY_PRTSCR,KEY_NEXT: KeyCallbackProcedure(iASCII,KEY_TYPESPECIAL,KEY_FORM,KEY_FIELDNAME);
        KEY_NUMLOCK:
          begin
            KEY_NUMLOCKMODE := not KEY_NUMLOCKMODE;
            SetToggleKey(KEY_NUMLOCK,KEY_FORM,KEY_NUMLOCKMODE);
            SetNumLockKeys(KEY_NUMLOCKMODE);
          end;
        KEY_INSERT,KEY_NUMINSERT:
          begin
            KEY_INSERTMODE := not KEY_INSERTMODE;
            SetToggleKey(KEY_INSERT,KEY_FORM,KEY_INSERTMODE);
          end;
        KEY_CTRL,KEY_ALT,KEY_ALTGR,KEY_FUNC:
          begin
            case iASCII of
              KEY_CTRL: AddToKeys('ctrl+');
              KEY_ALT: AddToKeys('alt+');
              KEY_ALTGR:
                begin
                  if Pos('shift+',KEY_KEYS) > 0 then // If already in shift, cancel it
                  begin
                    KEY_KEYS := '';
                  end;
                  AddToKeys('altgr+');
                end;
              KEY_FUNC: AddToKeys('fn+');
            end;
          end;
      else // Must be a key to be processed locally
        begin
          ProcessFieldWithKey(iASCII,KEY_KEYS,KEY_FORM,KEY_FIELDNAME);
        end;
      end;
    end;
    if KEY_INSHIFT and (iASCII <> KEY_SHIFTIN) and (iASCII <> KEY_CAPS) and (iASCII <> KEY_ALTGR) and (Pos('altgr+',KEY_KEYS) = 0) and (not bModifierPressed) then
    begin
      if not KEY_SHIFTDOWN then // Do not reset if physical shift key down
      begin
        ShiftKeyboard;
        SetShiftKeys(False);
        DisplayKeyboard;
      end;
    end;
  end;
end;

procedure TfrmKeyboard.pnlImageKeyMouseEnter(Sender: TObject);
var
  iASCII: Integer;
  sName: String;
  pnlCharKey: TRectangle;
begin
  if Assigned(pnlKeyboardBase) then
  begin
    if KEY_SKIN > 0 then
    begin
      HidePopupKeyboard;
    end
    else
    begin
      iASCII := GetASCIIFromKeyName(Sender);
      if iASCII <> -1 then
      begin
        sName := 'pnl' + Copy(TImage(Sender).Name,4);
        pnlCharKey := nil;
        case KEY_PANELNO of
          1: pnlCharKey := FindRectangleComponent(pnlUCKeyboard,sName);
          2: pnlCharKey := FindRectangleComponent(pnlLCKeyboard,sName);
          3: pnlCharKey := FindRectangleComponent(pnlPCKeyboard,sName);
        end;
        if pnlCharKey <> nil then
        begin
          if KEY_SKIN = 0 then
          begin
            pnlCharKey.Fill.Color := KEY_OVERCOLOUR;
            sKeyDownList.Add(sName);
          end;
        end;
      end;
    end;
  end;
end;

procedure TfrmKeyboard.pnlCharKeyMouseEnter(Sender: TObject);
var
  sName: String;
begin
  if Assigned(pnlKeyboardBase) then
  begin
    if (Sender is TRectangle) and (KEY_SKIN = 0) then
    begin
      sName := TRectangle(Sender).Name;
      if Copy(sName,Length(sName) - KEY_DIGITS,1) <> 'C' then // Not a Popup key
      begin
        HidePopupKeyboard;
      end;
      TRectangle(Sender).Fill.Color := KEY_OVERCOLOUR;
      sKeyDownList.Add(sName);
    end;
  end;
end;

procedure TfrmKeyboard.pnlCharKeyMouseLeave(Sender: TObject);
begin
  ResetActiveKeys;
end;

function TfrmKeyboard.GetASCIIFromKeyName(Sender: TObject): Integer;
var
  sName: String;
  iASCII: Integer;
  pnlImage: TImage;
begin
  iASCII := -1;
  sName := '';
  if Sender is TRectangle then
  begin
    sName := TRectangle(Sender).Name;
  end
  else
  begin
    if Sender is TImage then
    begin
      sName := TImage(Sender).Name;
      if (Copy(sName,1,3) <> 'img') and (Copy(sName,1,3) <> 'pnl') then // Look at the parent in case key in INSHIFT
      begin
        pnlImage := TImage(TImage(Sender).Parent);
        sName := pnlImage.Name;
      end;
    end;
  end;
  if sName <> '' then
  begin
    iASCII := StrToIntDef(Copy(sName,Length(sName) - KEY_DIGITS + 1,KEY_DIGITS),-1);
  end;
  Result := KeyASCII(iASCII);
end;

procedure TfrmKeyboard.pnlCharKeyUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  try
    CharKeyUp(Sender);
  except
    on E: Exception do
    begin
    end;
  end;
end;

procedure TfrmKeyboard.pnlCharKeyDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  try
    CharKeyDown(Sender);
  except
    on E: Exception do
    begin
    end;
  end;
end;

procedure TfrmKeyboard.RefreshPanelColours;
begin
  if Assigned(pnlKeyboardBase) then
  begin
    pnlKeyboardBase.Fill.Color := KEY_BORDERCOLOUR;
  end;
  if Assigned(pnlUCKeyboard) then
  begin
    pnlUCKeyboard.Fill.Color := KEY_INNERCOLOUR;
  end;
  if Assigned(pnlLCKeyboard) then
  begin
    pnlLCKeyboard.Fill.Color := KEY_INNERCOLOUR;
  end;
  if Assigned(pnlPCKeyboard) then
  begin
    pnlPCKeyboard.Fill.Color := KEY_INNERCOLOUR;
  end;
  if Assigned(pnlKeyboardPopup) then
  begin
    pnlKeyboardPopup.Fill.Color := KEY_SPACEUPCOLOUR;
  end;
end;

end.
