unit AndMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.DateTimeCtrls, FMX.StdCtrls, FMX.Controls.Presentation,
  gua_func,
   tmpLine,
  frmEye, FMX.Layouts;

type
  TForm3 = class(TForm)
    DateEdit1: TDateEdit;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Button1: TButton;
    LayoutUserData: TLayout;
    LayoutAction: TLayout;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TForm3.Button1Click(Sender: TObject);
var
 Bagua:TBagua;
  ClearNum:integer;
  num,i,j: integer;
begin

Bagua:=TBagua.Create;
  num := Bagua.CalcGuaNum(self.DateEdit1.DateTime,
    self.RadioButton1.IsChecked);
 // self.Label1.Text := inttostr(num);
  if num=9 then
    ClearNum:=4
  else
    ClearNum:=num-1;

bagua.Free;
if not assigned(Form2) then
    Form2:=TForm2.Create(self);
    Form2.clearNum := ClearNum;

  //  Form2.Bagua :=  Bagua;

  Form2.Show;

 // Bagua.Free;
end;

procedure TForm3.Button2Click(Sender: TObject);
begin
if not assigned(Form4) then
    Form4:=TForm4.Create(self);
    Form4.Show;
end;

end.
