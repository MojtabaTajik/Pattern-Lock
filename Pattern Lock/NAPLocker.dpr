program NAPLocker;

{
  NAP Win Locker ver 1.0.0.223
  This program is licensed onther GNU license
  Written by Mojtaba Tajik on 9/4/2011 - Tehran - Iran

  E-Mail :  Tajik1991@gmail.com
  Website : www.mojtabatajik.com
}

uses
  Forms,
  Windows,
  SysUtils,
  SQLiteWrap,
  fLockScreen in 'fLockScreen.pas' {frmLockScreen} ,
  fSetting in 'fSetting.pas' {frmSetting} ,
  fAbout in 'fAbout.pas' {frmAbout} ,
  fEnterPassword in 'fEnterPassword.pas' {frmEnterPassword} ,
  uFunc in 'uFunc.pas';

{$R *.res}

procedure CreateDB;
var
  DB: TSQLiteDatabase;
begin
  // Check if 'NAP' directory not exists in APPDATA create it
  if not SysUtils.DirectoryExists(APPDataDirectory + '\NAP') then
    CreateDirectory(PWideChar(APPDataDirectory + '\NAP'), nil);

  // If database exists do not create it again !
  if SysUtils.FileExists(APPDataDirectory + '\NAP\NAPLock.db') then
    Exit;

  // Save given setting to NAPLock.db
  DB := TSQLiteDatabase.Create(APPDataDirectory + '\NAP\NAPLock.db');
  try
    DB.ExecSQL
      ('Create TABLE DB(StartupLock int, LockComputer int, SwitchOff int, SwitchOffMethod int, LoginWord varchar(255));');
    DB.ExecSQL
      ('INSERT INTO DB (StartupLock, LockComputer, SwitchOff, SwitchOffMethod, LoginWord) VALUES (0, 0, 0, 0, '''')');
  finally
    DB.Free;
  end;
end;

var
  Mutex: THandle;

begin
  // Report memory leacks
  ReportMemoryLeaksOnShutdown := True;

  // If application run for second time then show error message
  Mutex := CreateMutex(nil, True, 'NAPLocker');
  if (Mutex <> 0) and (GetLastError = 0) then
  begin
    CreateDB; // Create database if not exists
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.ShowMainForm := False;
    Application.Title := 'NAP Locker';
    Application.CreateForm(TfrmSetting, frmSetting);
    Application.Run;
    if Mutex <> 0 then
      CloseHandle(Mutex);
  end
  else
    MessageBox(0, 'Another instance of application is already running !', '',
      +MB_ICONERROR + MB_OK);

end.
