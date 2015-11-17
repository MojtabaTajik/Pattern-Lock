unit uFunc;

interface

uses
  Windows, Classes, SysUtils, SHFolder, wcrypt2;

// Coantain circles that can access to current circle
type
  TAllowedCircles = set of 0 .. 15;

  // Record that coantain must blocked fields
type
  TBlockKeys = packed record
    wsyskey: Boolean;
    wkeyboard: Boolean;
    walttab: Boolean;
    wwinkey: Boolean;
    wctrlesc: Boolean;
    waltesc: Boolean;
    wctrlshesc: Boolean;
    wctrlenter: Boolean;
    wctrlaltenter: Boolean;
    wsnapshot: Boolean;
    wreturn: Boolean;
    wshift: Boolean;
    wtab: Boolean;
    wesc: Boolean;
    wctrl: Boolean;
    walt: Boolean;
    wfkeys: Boolean;
    winsert: Boolean;
    whome: Boolean;
    wdel: Boolean;
    wend: Boolean;
    wpup: Boolean;
    wpdown: Boolean;
    wleft: Boolean;
    wup: Boolean;
    wright: Boolean;
    wdown: Boolean;
  end;

  { Block functions }

function StartHook(wblockkeys: TBlockKeys): Boolean; Stdcall;
  external 'LockHooks.dll'; // Start hook

function StopHook: Boolean; Stdcall; external 'LockHooks.dll'; // Stop hook

function CtrlAltDelED(state: Boolean): Boolean; stdcall;
  external 'LockHooks.dll'; // Disable Ctrl + Alt, + Delete

function RegeditED(state: Boolean): Boolean; stdcall; external 'LockHooks.dll';
// Disable Regeistry

{ Imported API,s }

// Standby & Hibernate function
function SetSuspendState(Hibernate, ForceCritical, disablewakeevent: Boolean)
  : Boolean; stdcall; external 'PowrProf.dll' name 'SetSuspendState';

// Check system support Hibernate function
function IsHibernateAllowed: Boolean; stdcall;
  external 'PowrProf.dll' name 'IsPwrHibernateAllowed';

// Check system support Standby function
function IsPwrSuspendAllowed: Boolean; stdcall;
  external 'PowrProf.dll' name 'IsPwrSuspendAllowed';

{ My Functions }

// Return application data of current user
function APPDataDirectory: string;

// Return MD5 hash code of give string
function GetMD5HashCode(const Input: string): string;

function Block: Boolean;

Procedure UnBlock;

implementation

// Get Application Data directory
function APPDataDirectory: string;
const
  SHGFP_TYPE_CURRENT = 0;
var
  path: array [0 .. MAX_PATH] of char;
begin
  if SUCCEEDED(SHGetFolderPath(0, CSIDL_LOCAL_APPDATA, 0, SHGFP_TYPE_CURRENT,
    @path[0])) then
    Result := path
  else
    Result := '';
end;

function GetMD5HashCode(const Input: string): string;
var
  hCryptProvider: HCRYPTPROV;
  hHash: HCRYPTHASH;
  bHash: array [0 .. $7F] of Byte;
  dwHashBytes: Cardinal;
  pbContent: PByte;
  i: Integer;
begin
  dwHashBytes := 16;
  pbContent := Pointer(PChar(Input));
  Result := '';
  if CryptAcquireContext(@hCryptProvider, nil, nil, PROV_RSA_FULL,
    CRYPT_VERIFYCONTEXT or CRYPT_MACHINE_KEYSET) then
  begin
    if CryptCreateHash(hCryptProvider, CALG_MD5, 0, 0, @hHash) then
    begin
      if CryptHashData(hHash, pbContent, Length(Input) * sizeof(char), 0) then
      begin
        if CryptGetHashParam(hHash, HP_HASHVAL, @bHash[0], @dwHashBytes, 0) then
        begin
          for i := 0 to dwHashBytes - 1 do
          begin
            Result := Result + Format('%.2x', [bHash[i]]);
          end;
        end;
      end;
      CryptDestroyHash(hHash);
    end;
    CryptReleaseContext(hCryptProvider, 0);
  end;
  Result := AnsiLowerCase(Result);
end;

function Block: Boolean;
var
  BlockKeys: TBlockKeys;
begin
  // Block Keyboard & disable Task Manager & Registry
  Result := True;
  CtrlAltDelED(True);
  RegeditED(True);
  BlockKeys.wkeyboard := True;
  BlockKeys.wsyskey := True;
  if not StartHook(BlockKeys) then
    Result := False;
end;

procedure UnBlock;
begin
  StopHook;
  CtrlAltDelED(False);
  RegeditED(False);
end;

end.
