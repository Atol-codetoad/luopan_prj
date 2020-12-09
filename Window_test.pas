unit Window_test;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Math.Vectors,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.DateTimeCtrls,
  gua_func, FMX.Objects;

type
  TForm1 = class(TForm)
    DateEdit1: TDateEdit;
    RadioButton1: TRadioButton;
    GroupBox1: TGroupBox;
    RadioButton2: TRadioButton;
    Label1: TLabel;
    Button1: TButton;
    Circle1: TCircle;
    procedure Button1Click(Sender: TObject);
    procedure FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure DateEdit1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Circle1Tap(Sender: TObject; const Point: TPointF);
    procedure Circle1Click(Sender: TObject);
  private
    { Private declarations }
    IsNeedRepaint:boolean;
  public
    { Public declarations }
    procedure DrawBaGua1(Canva: TCanvas);
    procedure createYuing(Canva: TCanvas; start, stop: TPointF);
  end;
Const
CompassPoint :
   array [0..7] of string  = ('N','NE','E','SE','S','SW','W','NW');

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
begin

IsneedRepaint:=true;
if isNeedRePaint then
  begin
    self.Invalidate;
   // isNeedRePaint:=false;
  end;
end;



procedure TForm1.createYuing(Canva: TCanvas; start, stop: TPointF);
  function HalfLine(p1, p2: TPointF): TPointF;
  begin
    result.X := (p1.X + p2.X) / 2;
    result.Y := (p1.Y + p2.Y) / 2;
  end;

var
  DefColor: TAlphaColor;
  qtr1, qtr3, half, qtr12, qtr32: TPointF;
begin
  DefColor := Canva.Stroke.Color;
  Canva.Stroke.Color := TAlphaColors.Beige;
  Canva.Stroke.Thickness := 6;
  // --------------------------------------------
  half := HalfLine(start, stop);
  qtr1 := HalfLine(start, half);
  qtr12 := HalfLine(qtr1, half);
  qtr3 := HalfLine(half, stop);
  qtr32 := HalfLine(half, qtr3);
  // ------------------------------
  Canva.DrawLine(qtr12, qtr32, 100);
  // -------------------------------------------
  Canva.Stroke.Color := DefColor;
end;

procedure TForm1.DateEdit1Change(Sender: TObject);
begin
 // IsneedRepaint:=true;
end;

procedure TForm1.DrawBaGua1(Canva: TCanvas);
var
  Centr_Point: Tpoint;
  paint_cord: array [0 .. 2] of TPolygon;
  i, j, radius: integer;
  radian: real;
  DefColor: TAlphaColor; // ?
const
  BaGuaYuing: array [0 .. 2, 0 .. 7] of boolean = ((true, false, true, false,
    false, true, true, false), (false, true, true, false, true, true, false,
    false), (true, true, false, true, false, true, false, false));

begin
  Centr_Point.X := (Canva.Width - 100) div 2;
  Centr_Point.Y := (Canva.Height - 200) div 2;
  radius := (Canva.Height - 200) div 3;

  Canva.Stroke.Color := TAlphaColorRec.Crimson;
  // -------------------------

  for i := 0 to 2 do
  begin
    SetLength(paint_cord[i], 8);
    radian := 49 * Pi / 36; // 245 градусов  отнимать от 270(3*pi/2)-25
    // radian := 3*pi/2; //radian :=grad*pi/180
    for j := 0 to 7 do
    begin
      paint_cord[i][j].X := Centr_Point.X + round(radius * cos(radian));
      paint_cord[i][j].Y := Centr_Point.X - round(radius * sin(radian));
      radian := radian + Pi / 4;
    end;

   // paint_cord[i][8] := paint_cord[i][0];
    // ----------------------------------

    Canva.BeginScene();
    Canva.Stroke.Thickness := 5;
    Canva.DrawPolygon(paint_cord[i], 100);
    for j := 0 to 7 do
    begin
      // -------------------------------------
      DefColor := Canva.Stroke.Color;
      Canva.Stroke.Color := TAlphaColors.Beige;
      Canva.Stroke.Thickness := 6;
      Canva.DrawLine(paint_cord[i][j], paint_cord[i][j], 100);
      Canva.Stroke.Color := DefColor;
      Canva.Stroke.Thickness := 5;
      // -------------------------------------
      if BaGuaYuing[i][j] then
        createYuing(Canva, paint_cord[i][j], paint_cord[i][j + 1]);
    end;
   // Canva.EndScene();
    radius := radius - 15;
  end;
end;

{$region newadd}
procedure TForm1.Circle1Tap(Sender: TObject; const Point: TPointF);
begin
  if Sender is Tcircle then
  ShowMessage ((Sender as Tcircle).TagString)  ;
end;

procedure TForm1.Circle1Click(Sender: TObject);
begin
    if Sender is Tcircle then
  ShowMessage ((Sender as Tcircle).TagString)  ;
end;


procedure TForm1.FormPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
var
  num,i: integer;
  Bagua:TBagua;
  ClearNum:integer;
  BaguaActiveLink: array[0..7] of TCircle;
begin
if not isNeedRepaint then exit; // потом подумать
 if (sender is TForm1) then
 begin
  Bagua:=TBagua.Create;
  num := Bagua.CalcGuaNum(self.DateEdit1.DateTime,
    self.RadioButton1.IsChecked);
  self.Label1.Text := inttostr(num);
  if num=9 then
    ClearNum:=4
  else
    ClearNum:=num-1;
 // Canvas.Clear(TalphaColors.Aliceblue);
  Canvas.Lock;
  //DrawBaGua1(self.Canvas);
  Bagua.DrawBaGua(Canvas,ClearNum );
  Bagua.DrawHanZi(Canvas,ClearNum );
  Canvas.Unlock;
  //-----------------------------------Tcircle

    for I:=0 to 7 do
  begin
      BaguaActiveLink[i] :=TCircle.Create(self);
      BaguaActiveLink[i].Parent:=self;
      BaguaActiveLink[i].Position.X:= Bagua.HanZi[i].Coord.X-15;
      BaguaActiveLink[i].Position.Y:= Bagua.HanZi[i].Coord.Y-15;
      BaguaActiveLink[i].Width:= 30;
      BaguaActiveLink[i].Height:= 30;
      BaguaActiveLink[i].Fill.Color:=TAlphaColors.Aqua;
      BaguaActiveLink[i].Visible:=true ;
      BaguaActiveLink[i].TagString:=CompassPoint[i];
      BaguaActiveLink[i].OnTap:= Circle1Tap ;
      BaguaActiveLink[i].OnClick:=Circle1Click ;
      BaguaActiveLink[i].BringToFront;
   end;

  //-----------------------------------

 // self.Invalidate; //repaint
  Bagua.DisposeOf;
  Bagua:=nil;
  self.IsNeedRepaint:=false;
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
   isNeedRepaint:=false;
end;
{$endregion }
end.
