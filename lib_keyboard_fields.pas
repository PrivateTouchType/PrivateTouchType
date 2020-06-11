unit lib_keyboard_fields;

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
  System.Classes, System.Types, System.UITypes, System.SysUtils, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Edit, FMX.Memo, FMX.Memo.Types, FMX.Forms, FMX.Platform, FMX.Types;

procedure FieldSetOnKeyDownEvent;
function FieldGetTabKeyNo(AField: TObject): Integer;
procedure FieldGetStartLength(var AStart: Integer; var ASelectedLength: Integer; var ALength: Integer);
function FieldGetStart: Integer;
function FieldGetCaretPos: TPointF;
function FieldGetLinesCount: Integer;
function FieldGetCursorPosition: Integer;
function FieldGetVisibleLines: Integer;
function FieldGetSelectedCharNo: Integer;
function FieldGetSelectedText: String;
function FieldGetCaretLine: Integer;
function FieldGetCaretPosition: Integer;
function FieldGetLineText(ALineNo: Integer): String;
function FieldGetLineBreak: String;
function FieldGetClipboardText: String;
function FieldFindComponent(var AReadOnly: Boolean; var ACase,AType: Integer; AForm: TForm; AName: String): TObject;
procedure FieldGoToLineStart;
procedure FieldGoToLineEnd;
procedure FieldSetSelected(AValue: Integer);
procedure FieldSetStart(AValue: Integer);
procedure FieldSetClipboard;
procedure FieldSetCaretPos(AY,AX: Integer);
procedure FieldSetCursorPosition(AValue: Integer);
procedure FieldSelectAll;
procedure FieldInsertText(AText: String);
procedure FieldDeleteSelected;
procedure FieldScrollMultipleLines(ADown: Boolean);

implementation

uses lib_keyboard_defs,lib_keyboard;

procedure FieldSetOnKeyDownEvent;
begin
  case KEY_FIELDTYPE of
    KEY_FIELD_TEDIT:
      begin
        if not Assigned(TEdit(KEY_FIELD).OnKeyDown) then
        begin
          TEdit(KEY_FIELD).OnKeyUp := frmKeyboard.pnlPhysicalKeyUp;
          TEdit(KEY_FIELD).OnKeyDown := frmKeyboard.pnlPhysicalKeyDown;
        end;
      end;
    KEY_FIELD_TMEMO:
      begin
        if not Assigned(TMemo(KEY_FIELD).OnKeyDown) then
        begin
          TMemo(KEY_FIELD).OnKeyUp := frmKeyboard.pnlPhysicalKeyUp;
          TMemo(KEY_FIELD).OnKeyDown := frmKeyboard.pnlPhysicalKeyDown;
        end;
      end;
  end;
end;

function FieldFindComponent(var AReadOnly: Boolean; var ACase,AType: Integer; AForm: TForm; AName: String): TObject;
var
  i: Integer;

  function SetCase(ACase: TEditCharCase): Integer;
  var
    iCase: Integer;
  begin
    iCase := KEY_FIELDMIXEDCASE;
    if ACase = TEditCharCase.ecUpperCase then
    begin
      iCase := KEY_FIELDUPPERCASE;
    end
    else
    begin
      if ACase = TEditCharCase.ecLowerCase then
      begin
        iCase := KEY_FIELDLOWERCASE;
      end;
    end;
    Result := iCase;
  end;
begin
  i := 0;
  Result := nil;
  AType := KEY_FIELD_UNKNOWN;
  ACase := KEY_FIELDMIXEDCASE;
  AReadOnly := True; // Assume worst case scenario
  while (i < AForm.ComponentCount) and (AType = KEY_FIELD_UNKNOWN) do
  begin
    if LowerCase(AForm.Components[i].Name) = LowerCase(AName) then
    begin
      if (AForm.Components[i] is TEdit) then
      begin
        AType := KEY_FIELD_TEDIT;
        Result := TEdit(AForm.Components[i]);
        AReadOnly := TEdit(Result).ReadOnly;
        ACase := SetCase(TEdit(Result).CharCase);
      end
      else
      begin
        if (AForm.Components[i] is TMemo) then
        begin
          AType := KEY_FIELD_TMEMO;
          Result := TMemo(AForm.Components[i]);
          AReadOnly := TMemo(Result).ReadOnly;
          ACase := SetCase(TMemo(Result).CharCase);
        end;
      end;
    end;
    i := i + 1;
  end;
end;

function FieldGetTabKeyNo(AField: TObject): Integer;
var
  iTabNo: Integer;
begin
  iTabNo := -1;
  if AField is TMemo then
  begin
    iTabNo := TMemo(AField).TabOrder;
  end
  else
  begin
    if AField is TEdit then
    begin
      iTabNo := TEdit(AField).TabOrder;
    end;
  end;
  Result := iTabNo;
end;

procedure FieldGetStartLength(var AStart: Integer; var ASelectedLength: Integer; var ALength: Integer);
begin
  AStart := 0;
  ASelectedLength := 0;
  ALength := 0;
  if KEY_FIELDTYPE = KEY_FIELD_TMEMO then
  begin
    AStart := TMemo(KEY_FIELD).SelStart;
    ASelectedLength := TMemo(KEY_FIELD).SelLength;
    ALength := Length(TMemo(KEY_FIELD).Text);
  end
  else
  begin
    if KEY_FIELDTYPE = KEY_FIELD_TEDIT then
    begin
      AStart := TEdit(KEY_FIELD).SelStart;
      ASelectedLength := TEdit(KEY_FIELD).SelLength;
      ALength := Length(TEdit(KEY_FIELD).Text);
    end;
  end;
end;

function FieldGetCaretPos: TPointF;
begin
  Result := TMemo(KEY_FIELD).Caret.Pos;
end;

function FieldGetCursorPosition: Integer;
begin
  Result := TMemo(KEY_FIELD).CaretPosition.Pos;
end;

function FieldGetStart: Integer;
var
  iStart: Integer;
begin
  iStart := 0;
  case KEY_FIELDTYPE of
    KEY_FIELD_TMEMO: iStart := TMemo(KEY_FIELD).SelStart;
    KEY_FIELD_TEDIT: iStart := TEdit(KEY_FIELD).SelStart;
  end;
  Result := iStart;
end;

function FieldGetLinesCount: Integer;
begin
  Result := TMemo(KEY_FIELD).Lines.Count;
end;

function FieldGetVisibleLines: Integer;
var
  iLines: Integer;
begin
  iLines := 1;
  if KEY_FIELDTYPE = KEY_FIELD_TMEMO then
  begin
    iLines := Round(TMemo(KEY_FIELD).ViewportSize.cy / (TMemo(KEY_FIELD).TextSettings.Font.Size + 4));
  end;
  Result := iLines;
end;

procedure FieldGoToLineStart;
begin
  case KEY_FIELDTYPE of
    KEY_FIELD_TMEMO: TMemo(KEY_FIELD).GoToLineBegin;
    KEY_FIELD_TEDIT: TEdit(KEY_FIELD).GoToTextBegin;
  end;
end;

procedure FieldGoToLineEnd;
begin
  case KEY_FIELDTYPE of
    KEY_FIELD_TMEMO: TMemo(KEY_FIELD).GoToLineEnd;
    KEY_FIELD_TEDIT: TEdit(KEY_FIELD).GoToTextEnd;
  end;
end;

procedure FieldSetSelected(AValue: Integer);
begin
  case KEY_FIELDTYPE of
    KEY_FIELD_TMEMO: TMemo(KEY_FIELD).SelLength := AValue;
    KEY_FIELD_TEDIT: TEdit(KEY_FIELD).SelLength := AValue;
  end;
  if AValue = 0 then
  begin
    KEY_SELECTSTART := -1;
    KEY_SELECTROWSTART := -1;
  end;
end;

procedure FieldDeleteSelected;
begin
  case KEY_FIELDTYPE of
    KEY_FIELD_TMEMO: TMemo(KEY_FIELD).DeleteSelection;
    KEY_FIELD_TEDIT: TEdit(KEY_FIELD).DeleteSelection;
  end;
end;

procedure FieldSetStart(AValue: Integer);
begin
  case KEY_FIELDTYPE of
    KEY_FIELD_TMEMO: TMemo(KEY_FIELD).SelStart := AValue;
    KEY_FIELD_TEDIT: TEdit(KEY_FIELD).SelStart := AValue;
  end;
end;

function FieldGetLineText(ALineNo: Integer): String;
var
  sText: String;
begin
  sText := '';
  case KEY_FIELDTYPE of
    KEY_FIELD_TMEMO:
      begin
        if ALineNo = -1 then
        begin
          sText := TMemo(KEY_FIELD).Text;
        end
        else
        begin
          sText := TMemo(KEY_FIELD).Lines[ALineNo];
        end;
      end;
    KEY_FIELD_TEDIT: sText := TEdit(KEY_FIELD).Text;
  end;
  Result := sText;
end;

function FieldGetLineBreak: String;
begin
  Result := TMemo(KEY_FIELD).Lines.LineBreak;
end;

procedure FieldSetCaretPos(AY,AX: Integer);
begin
  TMemo(KEY_FIELD).CaretPosition := TCaretPosition.Create(AY,AX);
end;

function FieldGetClipboardText: String;
var
  sText: String;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService,IInterface(KEY_CLIPBOARD)) then
  begin
    sText := KEY_CLIPBOARD.GetClipboard.AsString;
  end
  else
  begin
    sText := '';
  end;
  Result := sText;
end;

procedure FieldSetClipboard;
begin
  case KEY_FIELDTYPE of
    KEY_FIELD_TMEMO: TMemo(KEY_FIELD).CopyToClipboard;
    KEY_FIELD_TEDIT: TEdit(KEY_FIELD).CopyToClipboard;
  end;
end;

function FieldGetSelectedCharNo: Integer;
var
  iCharNo: Integer;
  sChar: String;
begin
  sChar := '';
  iCharNo := 0;
  case KEY_FIELDTYPE of
    KEY_FIELD_TMEMO: sChar := Copy(TMemo(KEY_FIELD).SelText,1,1);
    KEY_FIELD_TEDIT: sChar := Copy(TEdit(KEY_FIELD).SelText,1,1);
  end;
  if sChar <> '' then
  begin
    iCharNo := Ord(sChar[1]);
  end;
  Result := iCharNo;
end;

function FieldGetSelectedText: String;
var
  sChar: String;
begin
  sChar := '';
  case KEY_FIELDTYPE of
    KEY_FIELD_TMEMO: sChar := TMemo(KEY_FIELD).SelText;
    KEY_FIELD_TEDIT: sChar := TEdit(KEY_FIELD).SelText;
  end;
  Result := sChar;
end;

procedure FieldInsertText(AText: String);
begin
  case KEY_FIELDTYPE of
    KEY_FIELD_TMEMO: TMemo(KEY_FIELD).InsertAfter(TMemo(KEY_FIELD).CaretPosition,AText,[]);
    KEY_FIELD_TEDIT: TEdit(KEY_FIELD).Text := TEdit(KEY_FIELD).Text.Insert(TEdit(KEY_FIELD).SelStart,AText);
  end;
end;

procedure FieldSelectAll;
begin
  case KEY_FIELDTYPE of
    KEY_FIELD_TMEMO: TMemo(KEY_FIELD).SelectAll;
    KEY_FIELD_TEDIT: TEdit(KEY_FIELD).SelectAll;
  end;
end;

procedure FieldSetCursorPosition(AValue: Integer);
begin
  FieldSetCaretPos(2,5);
end;

function FieldGetCaretLine: Integer;
begin
  Result := TMemo(KEY_FIELD).CaretPosition.Line;
end;

function FieldGetCaretPosition: Integer;
begin
  Result := TMemo(KEY_FIELD).CaretPosition.Pos;
end;

procedure FieldScrollMultipleLines(ADown: Boolean);

  function YOffset(ASize: Integer; AUp: Boolean): Integer;
  var
    iOffset: Integer;
  begin
    iOffset := ASize + 4;
    if AUp then
    begin
      iOffset := iOffset * -1;
    end;
    Result := iOffset;
  end;

begin
  case KEY_FIELDTYPE of
    KEY_FIELD_TMEMO: TMemo(KEY_FIELD).ScrollBy(0,YOffset(Round(TMemo(KEY_FIELD).Font.Size),ADown),True);
  end;
end;

end.
