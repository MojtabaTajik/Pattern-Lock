unit fSetting;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, pngimage, ExtCtrls, ComCtrls, Spin, Menus, SHFolder,
  SQLiteWrap, ExtDlgs, Registry, uFunc;

type
  TfrmSetting = class(TForm)
    btnCancel: TButton;
    btnApply: TButton;
    gbSetting: TGroupBox;
    opdLockImage: TOpenPictureDialog;
    pumTray: TPopupMenu;
    pumiSetting: TMenuItem;
    pumiAbout: TMenuItem;
    pumiExit: TMenuItem;
    tiTray: TTrayIcon;
    pcSetting: TPageControl;
    tshGeneral: TTabSheet;
    lblSwitchOffMethod: TLabel;
    chbLogOff: TCheckBox;
    chbStartupLock: TCheckBox;
    chbLockComputer: TCheckBox;
    sedLockAfter: TSpinEdit;
    cbSwitchOffMethods: TComboBox;
    sedSwitchOff: TSpinEdit;
    tshChangepassword: TTabSheet;
    lblPasswordStatus: TLabel;
    pCircles: TPanel;
    imgDrawConnectionLine: TImage;
    imgA: TImage;
    imgE: TImage;
    imgI: TImage;
    imgM: TImage;
    imgN: TImage;
    imgJ: TImage;
    imgF: TImage;
    imgB: TImage;
    imgC: TImage;
    imgG: TImage;
    imgK: TImage;
    imgO: TImage;
    imgP: TImage;
    imgL: TImage;
    imgH: TImage;
    imgD: TImage;
    timCheckLock: TTimer;
    timCheckSwitchOff: TTimer;
    imgBlackBackground: TImage;
    procedure imgAClick(Sender: TObject);
    procedure imgAMouseEnter(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure pumiExitClick(Sender: TObject);
    procedure pumiSettingClick(Sender: TObject);
    procedure pumiAboutClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure chbLockComputerClick(Sender: TObject);
    procedure chbLogOffClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure tiTrayDblClick(Sender: TObject);
    procedure timCheckLockTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbSwitchOffMethodsChange(Sender: TObject);
    procedure timCheckSwitchOffTimer(Sender: TObject);
  private
    { Private declarations }
    Clicked: Boolean;
    Circle1, Circle2: TImage;
    LastImg: Byte;
    CurrentPassword: string;
  public
    { Public declarations }
  end;

  // Type that contain setting data for Load or Save
type
  TLockSetting = record
    StartupLock: Boolean;
    LockComputer, SwitchOff, SwitchOffMethod: Byte;
    NewPassword: string;
  end;

  TSetting = class
  private
    function GetMD5(const Input: string): string;
    { Get MD5 code of given string }
  public
    function LoadSetting: TLockSetting;
    procedure SaveSetting(const LockSetting: TLockSetting);
  end;

var
  frmSetting: TfrmSetting;
  LockSetting: TLockSetting; // Coantaing lock setting
  // Coantain current password ( laod on start app from NAPLock.db )
  CurrPass: string;

implementation

uses fAbout, fLockScreen, fEnterPassword;

{$R *.dfm}
{ TSetting }

// Get MD5 code of given string
function TSetting.GetMD5(const Input: string): string;
begin
  Result := GetMD5HashCode(Input);
end;

function TSetting.LoadSetting: TLockSetting;
var
  DB: TSQLiteDatabase;
  Tbl: TSQLiteTable;
begin
  // Check if 'NAP' directory not exists in APPDATA create it
  if not SysUtils.DirectoryExists(APPDataDirectory + '\NAP') then
    CreateDirectory(PWideChar(APPDataDirectory + '\NAP'), nil);

  // Load setting from NAPLock.db & return it
  DB := TSQLiteDatabase.Create(APPDataDirectory + '\NAP\NAPLock.db');
  try
    Tbl := DB.GetTable('SELECT * FROM DB');
    Result.StartupLock :=
      StrToBoolDef(Tbl.FieldAsString(Tbl.FieldIndex['StartupLock']), False);
    Result.LockComputer := Tbl.FieldAsInteger(Tbl.FieldIndex['LockComputer']);
    Result.SwitchOff := Tbl.FieldAsInteger(Tbl.FieldIndex['SwitchOff']);
    Result.SwitchOffMethod := Tbl.FieldAsInteger
      (Tbl.FieldIndex['SwitchOffMethod']);
    CurrPass := Tbl.FieldAsString(Tbl.FieldIndex['LoginWord']);
  finally
    Tbl.Free;
    DB.Free;
  end;
end;

procedure TSetting.SaveSetting(const LockSetting: TLockSetting);
var
  DB: TSQLiteDatabase;
  Tbl: TSQLiteTable;
begin
  // Check if 'NAP' directory not exists in APPDATA create it
  if not SysUtils.DirectoryExists(APPDataDirectory + '\NAP') then
    CreateDirectory(PWideChar(APPDataDirectory + '\NAP'), nil);

  // Save given setting to NAPLock.db
  DB := TSQLiteDatabase.Create(APPDataDirectory + '\NAP\NAPLock.db');
  try
    Tbl := DB.GetTable
      ('UPDATE DB SET StartupLock = :StartupLock, LockComputer = :LockComputer, SwitchOff = :SwitchOff, SwitchOffMethod = :SwitchOffMethod, LoginWord= :LoginWord;');
    Tbl.Reset;
    Tbl.AddParamText(':StartupLock', BoolToStr(LockSetting.StartupLock));
    Tbl.AddParamInt(':LockComputer', LockSetting.LockComputer);
    Tbl.AddParamInt(':SwitchOff', LockSetting.SwitchOff);
    Tbl.AddParamInt(':SwitchOffMethod', LockSetting.SwitchOffMethod);
    // Check password changed or not , if not changed save CurrPass as passwords
    if LockSetting.NewPassword = '' then
      Tbl.AddParamText(':LoginWord', CurrPass)
    else
      Tbl.AddParamText(':LoginWord', GetMD5(LockSetting.NewPassword));
    Tbl.Next;
  finally
    Tbl.Free;
    DB.Free;
  end;
end;

{ Form }
procedure TfrmSetting.FormCreate(Sender: TObject);
begin
  // Load setting
  with TSetting.Create do
    try
      LockSetting := LoadSetting;
    finally
      Free;
    end;

  // Assign loaded setting to visual components
  chbStartupLock.Checked := LockSetting.StartupLock;
  chbLockComputer.Checked := (LockSetting.LockComputer <> 0);
  sedLockAfter.Value := LockSetting.LockComputer;
  chbLogOff.Checked := (LockSetting.SwitchOff <> 0);
  sedSwitchOff.Value := LockSetting.SwitchOff;
  cbSwitchOffMethods.ItemIndex := LockSetting.SwitchOffMethod;
  timCheckLock.Enabled := (LockSetting.LockComputer <> 0);
  timCheckSwitchOff.Enabled := (LockSetting.SwitchOff <> 0);
  CurrentPassword := LockSetting.NewPassword;

  // Set connection line color & width
  imgDrawConnectionLine.Canvas.Pen.Color := RGB(0, 230, 0);
  imgDrawConnectionLine.Canvas.Pen.Width := 10;

  // Set tab index to 0
  pcSetting.TabIndex := 0;

  // Check if password not set then show setting form to set password
  if CurrPass = '' then
  begin
    MessageDlg
      ('The password not set , remember if you lock computer without password you can''t access it !',
      mtWarning, [mbOK], 0);
    pcSetting.TabIndex := 1;
    frmSetting.Show;
    Exit;
  end;

  // Check if program run from startup then lock the computer
  if ParamCount > 0 then
    if ParamStr(1) = 'StartupLock' then
    begin
      // Disable check inactivity time timer until lock screen closed ( if don't to this lock screen show multiple times ! )
      timCheckLock.Enabled := False;

      // Lock the computer , if user enter correct password unlock computer
      if TfrmLockScreen.Execute then
        timCheckLock.Enabled := True;
    end;
end;

procedure TfrmSetting.btnApplyClick(Sender: TObject);
var
  LockSetting: TLockSetting;
begin
  // Check switvh off time was > lock time , if not then show error message and don,t save setting
  if (chbLockComputer.Checked) and (chbLogOff.Checked) then
    if (sedLockAfter.Value >= sedSwitchOff.Value) then
    begin
      MessageDlg('Switch off value must greater than lock value', mtError,
        [mbOK], 0);
      sedSwitchOff.SetFocus;
      Exit;
    end;

  // Check if LockStartup checked then add app to startup in registry
  with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;
      OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True);
      if chbStartupLock.Checked then
        WriteString('NAPLock', Application.ExeName + ' StartupLock')
      else
        DeleteValue('NAPLock');
    finally
      Free;
    end;

  // Assign current setting from visual components to LockSetting stracture;
  LockSetting.StartupLock := chbStartupLock.Checked;
  LockSetting.LockComputer := sedLockAfter.Value;
  LockSetting.SwitchOff := sedSwitchOff.Value;
  LockSetting.SwitchOffMethod := cbSwitchOffMethods.ItemIndex;
  LockSetting.NewPassword := CurrentPassword;

  // Save current setting ( LockSetting )to setting file ( NAPLock.ini )
  with TSetting.Create do
    try
      imgDrawConnectionLine.Picture.Assign(nil);
      SaveSetting(LockSetting);
      // Load setting saved setting
      Self.FormCreate(nil);
      MessageDlg('Settings has been changed', mtInformation, [mbOK], 0);
      Clicked := False;
      Self.Close;
    finally
      Free;
    end;
end;

procedure TfrmSetting.timCheckLockTimer(Sender: TObject);
var
  LastInput: TLastInputInfo;
  IdleSec, IdleMinute: DWORD;
begin
  // Get last input time
  LastInput.cbSize := SizeOf(TLastInputInfo);
  GetLastInputInfo(LastInput);
  IdleSec := (GetTickCount - LastInput.dwTime) DIV 1000;

  // Check if second = 60 , Inc(Minute)
  IdleMinute := IdleSec div 60;

  // Check if lock time arrived and 60 second past from last lock then Lock the computer until user enter correct password
  if (chbLockComputer.Checked) and (IdleMinute = sedLockAfter.Value) and
    (IdleSec > 60) then
  begin
    timCheckLock.Enabled := False;
    if TfrmLockScreen.Execute then
    begin
      UnBlock;
      timCheckLock.Enabled := True;
    end;
  end;
end;

procedure TfrmSetting.timCheckSwitchOffTimer(Sender: TObject);
var
  LastInput: TLastInputInfo;
  IdleSec, IdleMinute: DWORD;
begin
  // Get last input time
  LastInput.cbSize := SizeOf(TLastInputInfo);
  GetLastInputInfo(LastInput);
  IdleSec := (GetTickCount - LastInput.dwTime) DIV 1000;

  // Check if second = 60 , Inc(Minute)
  IdleMinute := IdleSec div 60;

  // Check if SwitchOff time arrived then SwitchOff computer using switch off method
  if (chbLogOff.Checked) and (IdleMinute = sedSwitchOff.Value) then
  begin
    case cbSwitchOffMethods.ItemIndex of
      0:
        ExitWindowsEx(EWX_LOGOFF or EWX_FORCE, 0); // Logoff
      1:
        ExitWindowsEx(EWX_SHUTDOWN or EWX_FORCE, 0); // Shutdown
      2:
        SetSuspendState(True, False, False); // Hibernate
      3:
        SetSuspendState(False, False, False); // Stanby
    end;
  end;
end;

procedure TfrmSetting.imgAClick(Sender: TObject);
begin
  // Check line most draw between 2 circle or no ?
  if Clicked = True then
    Clicked := False
  else
  begin
    Clicked := True;

    // Load empty background to imgDrawConnectionLine
    imgDrawConnectionLine.Picture.Assign(nil);

    // Set connection line color & width
    imgDrawConnectionLine.Canvas.Pen.Color := RGB(0, 230, 0);
    imgDrawConnectionLine.Canvas.Pen.Width := 10;

    // Assgin curent selected image to Circle1 variable
    Circle1 := TImage(Sender);

    // Set LastImg with current image tag
    LastImg := Circle1.Tag;

    // Assign tag value of selected image to EnteredPassword variable
    CurrentPassword := IntToStr(Circle1.Tag);

    // Move canvas pointer to current image that mouse cursor is on it
    imgDrawConnectionLine.Canvas.MoveTo(Circle1.Left + 10, Circle1.Top + 10);
  end;
end;

procedure TfrmSetting.imgAMouseEnter(Sender: TObject);
var
  LineArea: Array [0 .. 15] of TAllowedCircles;
begin
  // Allowed circles that each circle can access them
  LineArea[0] := [1, 4, 5];
  LineArea[1] := [0, 2, 4, 5, 6];
  LineArea[2] := [1, 3, 5, 6, 7];
  LineArea[3] := [2, 6, 7];
  LineArea[4] := [0, 1, 5, 8, 9];
  LineArea[5] := [0, 1, 2, 4, 6, 8, 9, 10];
  LineArea[6] := [1, 2, 3, 5, 7, 9, 10, 11];
  LineArea[7] := [2, 3, 6, 10, 11];
  LineArea[8] := [4, 5, 9, 12, 13];
  LineArea[9] := [4, 5, 6, 8, 10, 12, 13, 14];
  LineArea[10] := [5, 6, 7, 9, 11, 13, 14, 15];
  LineArea[11] := [6, 7, 10, 14, 15];
  LineArea[12] := [8, 9, 13];
  LineArea[13] := [8, 9, 10, 12, 14];
  LineArea[14] := [9, 10, 11, 13, 15];
  LineArea[15] := [10, 11, 14];

  // Draw line between 2 circles
  if Clicked then
    if TImage(Sender).Tag in LineArea[LastImg] then
    begin
      Circle2 := TImage(Sender);
      LastImg := Circle2.Tag;

      // Assign tag of image that mouse cursor move on it to EnteredPassword variable
      CurrentPassword := CurrentPassword + ',' + IntToStr(Circle2.Tag);
      imgDrawConnectionLine.Canvas.LineTo(Circle2.Left + 10, Circle2.Top + 10);
    end;
end;

procedure TfrmSetting.cbSwitchOffMethodsChange(Sender: TObject);
begin
  // Check system support hibernate , standby or no
  case cbSwitchOffMethods.ItemIndex of
    3:
      if not IsHibernateAllowed then
        MessageDlg('The system dose not support hibernate method', mtWarning,
          [mbOK], 0);
    4:
      if not IsPWRSuspendAllowed then
        MessageDlg('The system dose not support Standby method', mtWarning,
          [mbOK], 0);
  end;
end;

procedure TfrmSetting.chbLockComputerClick(Sender: TObject);
begin
  // If chbLockComputer not checked then set the value of sedLockAfter to 0
  if not chbLockComputer.Checked then
    sedLockAfter.Value := 0;

  // Set enabled method of sedLockAfter same as chbLockComputer.Checked
  sedLockAfter.Enabled := chbLockComputer.Checked;
end;

procedure TfrmSetting.chbLogOffClick(Sender: TObject);
begin
  // If chbLogOff not checked then set the value of sedSwithOff to 0
  if not chbLogOff.Checked then
    sedSwitchOff.Value := 0;

  // Set enabled method of sedSwitchOff same as chbLogOff.Checked
  sedSwitchOff.Enabled := chbLogOff.Checked;
end;

procedure TfrmSetting.tiTrayDblClick(Sender: TObject);
begin
  // Disable check inactivity time timer until lock screen closed ( if don't to this lock screen show multiple times ! )
  timCheckLock.Enabled := False;

  // Lock the computer , if user enter correct password unlock computer
  if TfrmLockScreen.Execute then
    timCheckLock.Enabled := True;
end;

procedure TfrmSetting.pumiSettingClick(Sender: TObject);
begin
  // Check if entered pasword was accept then show setting form
  if TfrmEnterPassword.Execute then
    frmSetting.Show;
end;

procedure TfrmSetting.pumiAboutClick(Sender: TObject);
begin
  // Create an instance of frmAbout and run it
  TfrmAbout.Execute;
end;

procedure TfrmSetting.pumiExitClick(Sender: TObject);
begin
  // Show confrim exit dialog , if user accept then exit
  if MessageDlg('Are you sure , you want to exit ?', mtConfirmation, mbYesNo, 0)
    = mrYes then
    Application.Terminate;
end;

procedure TfrmSetting.btnCancelClick(Sender: TObject);
begin
  // Set clicked to false & clear drawed line
  Clicked := False;
  imgDrawConnectionLine.Picture.Assign(nil);
  // Close self
  Self.Close;
end;

procedure TfrmSetting.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  // Hide setting form ( go to taskbar )
  CanClose := False;
  Self.Hide;
end;

end.
