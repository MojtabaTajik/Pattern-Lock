unit fAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, pngimage, ExtCtrls, StdCtrls, ComCtrls, ShellAPI;

type
  TfrmAbout = class(TForm)
    imgLogo: TImage;
    lblHeader: TLabel;
    lblWrittenBy: TLabel;
    Label1: TLabel;
    Label2: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
    class function Execute: Boolean;
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.dfm}
{ TfrmAbout }

class function TfrmAbout.Execute: Boolean;
begin
  with TfrmAbout.Create(nil) do
    try
      Result := (ShowModal = mrOk);
    finally
      Free;
    end;
end;

end.
