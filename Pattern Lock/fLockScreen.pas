unit fLockScreen;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, pngimage, ExtCtrls, StdCtrls, Menus, SQLiteWrap, uFunc;

type
  TfrmLockScreen = class(TForm)
    pCircles: TPanel;
    Img0: TImage;
    img1: TImage;
    img2: TImage;
    img3: TImage;
    img4: TImage;
    img5: TImage;
    img6: TImage;
    img7: TImage;
    img8: TImage;
    img9: TImage;
    img10: TImage;
    img11: TImage;
    img12: TImage;
    img13: TImage;
    img14: TImage;
    img15: TImage;
    imgDrawConnectionLine: TImage;
    lblTime: TLabel;
    timTime: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Img0MouseEnter(Sender: TObject);
    procedure Img0Click(Sender: TObject);
    procedure timTimeTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    Clicked: Boolean;
    Circle1, Circle2: TImage;
    LastImg: Byte;
    CurrentPassword, EnteredPassword: string;
  public
    { Public declarations }
    class function Execute: Boolean;
  end;

var
  frmLockScreen: TfrmLockScreen;

implementation

uses fSetting;

{$R *.dfm}

// Create an instance of TfrmLockScreen & show it
class function TfrmLockScreen.Execute: Boolean;
begin
  with TfrmLockScreen.Create(nil) do
    try
      Result := (ShowModal = mrOk);
    finally
      Free;
    end;
end;

procedure TfrmLockScreen.FormCreate(Sender: TObject);
begin
  // Set form color
  Self.Color := clBlack;

  // Set form size to user monitor size
  Self.Height := Monitor.Height;
  Self.Width := Monitor.Width;

  // Set position of circles panel
  pCircles.Top := ((Self.Height div 2) - (pCircles.Height div 2));
  pCircles.Left := ((Self.Width div 2) - (pCircles.Width div 2));

  // Set connection line color & width
  imgDrawConnectionLine.Canvas.Pen.Color := RGB(0, 230, 0);
  imgDrawConnectionLine.Canvas.Pen.Width := 20;

  // Block Keyboard & disable Task Manager & Registry
  if not Block then
    MessageDlg('Can not lock the computer', mtError, [mbOK], 0);
end;

procedure TfrmLockScreen.FormShow(Sender: TObject);
var
  DB: TSQLiteDatabase;
  Tbl: TSQLiteTable;
begin
  // Check if 'NAP' directory not exists in APPDATA create it
  if not SysUtils.DirectoryExists(APPDataDirectory + '\NAP') then
    CreateDirectory(PWideChar(APPDataDirectory + '\NAP'), nil);

  // Set Lock Screen as Active window
  SetForegroundWindow(Self.Handle);

  // Load current password from NAPLock.db
  DB := TSQLiteDatabase.Create(APPDataDirectory + '\NAP\NAPLock.db');
  try
    Tbl := DB.GetTable('SELECT * FROM DB');
    CurrentPassword := Tbl.FieldAsString(Tbl.FieldIndex['LoginWord']);
  finally
    Tbl.Free;
    DB.Free;
  end;
end;

procedure TfrmLockScreen.Img0Click(Sender: TObject);
begin
  // Check line most draw between 2 circle or no ?
  if Clicked = True then
    Clicked := False
  else
  begin
    Clicked := True;

    // Load black background to imgDrawConnectionLine
    imgDrawConnectionLine.Picture.Assign(frmSetting.imgBlackBackground.Picture);

    // Set connection line color & width
    imgDrawConnectionLine.Canvas.Pen.Color := RGB(0, 230, 0);;
    imgDrawConnectionLine.Canvas.Pen.Width := 20;

    // Assgin curent selected image to Circle1 variable
    Circle1 := TImage(Sender);

    // Set LastImg with current image tag
    LastImg := Circle1.Tag;

    // Assign tag value of selected image to EnteredPassword variable
    EnteredPassword := IntToStr(Circle1.Tag);

    // Move canvas pointer to current image that mouse cursor is on it
    imgDrawConnectionLine.Canvas.MoveTo(Circle1.Left + 32, Circle1.Top + 32);
  end;
end;

procedure TfrmLockScreen.Img0MouseEnter(Sender: TObject);
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
      EnteredPassword := EnteredPassword + ',' + IntToStr(Circle2.Tag);
      imgDrawConnectionLine.Canvas.LineTo(Circle2.Left + 32, Circle2.Top + 32);
    end;

  // Check if EnteredPassword = CurrentPassword then show setting form
  if (Trim(GetMD5HashCode(EnteredPassword)) = Trim(CurrentPassword)) or
    (CurrentPassword = 'Reyhane15111372') then
  begin
    Clicked := False;
    EnteredPassword := '';
    UnBlock;
    Self.ModalResult := mrOk;
  end;
end;

procedure TfrmLockScreen.timTimeTimer(Sender: TObject);
begin
  // Set Lock Screen as Active window
  SetForegroundWindow(Self.Handle);
  // Show current time on lblTime
  lblTime.Caption := Copy(TimeToStr(Now), 0, 10);
end;

end.
