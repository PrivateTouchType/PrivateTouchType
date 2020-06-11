unit lib_keyboard_opsys;

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
{$IFDEF MSWINDOWS}
  Windows,System.SysUtils;
{$ELSE}
  Macapi.AppKit;
{$ENDIF}

const
  KEY_VK_CAPITAL = 20;
  KEY_VK_NUMLOCK = 144;
  KEY_VK_INSERT = 45;

procedure KeyClickSound;
function GetBasePath: String;
function GetCapsLockState: Boolean;
function GetNumLockState: Boolean;
function GetInsLockState: Boolean;
function GetSpecialKeyState(AKey: Integer): Boolean;

implementation

procedure KeyClickSound;
begin
  {$IFDEF MSWINDOWS}
  // Windows.Beep(440,1); // Removed as it causes a delay
  {$ENDIF}
end;

function GetBasePath: String;
begin
  {$IFDEF MSWINDOWS}
    Result := ExtractFilePath(ParamStr(0));
  {$ENDIF}
end;

function GetCapsLockState: Boolean;
begin
  Result := GetSpecialKeyState(VK_CAPITAL);
end;

function GetNumLockState: Boolean;
begin
  Result := GetSpecialKeyState(VK_NUMLOCK);
end;

function GetInsLockState: Boolean;
begin
  Result := GetSpecialKeyState(VK_INSERT);
end;

function GetSpecialKeyState(AKey: Integer): Boolean;
begin
{$IFDEF MSWINDOWS}
  Result := (GetKeyState(AKey) > 0);
{$ELSE}
  if AKey = KEY_VK_CAPITAL then
  begin
  abc not finished this
  Result := NSControlKeyMask and TNSEvent.OCClass.modifierFlags = NSControlKeyMask;
{$ENDIF}
end;

end.
