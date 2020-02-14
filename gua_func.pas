unit gua_func;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, FMX.Graphics,
  FMX.Types;

type
 TCompasPoint =(N,NE,E,SE,S,SW,W,NW);

  TGuaProp = class(TObject)

    HaoSe, BuhaoSe: TAlphaColor;

  public
    Coord: Tpoint;
    isYin: Boolean; // def false ;
    isHao: Boolean;
    constructor Create;
  end;

  TBagua = class(TPersistent)
  private
   Zi_Radus:Integer ;
   BaguaFen: array [0 .. 2, 0 .. 7] of TGuaProp;
   HanZi:Array [0 .. 7] of TGuaProp;//времменно
   procedure createYuing(Canva: TCanvas; start, stop: TPointF);
  public
   constructor Create;
   function CalcGuaNum(DateBirth: TDateTime; sex: Boolean): Integer;
    // sex True=M
    Procedure DrawBaGua(Canva: TCanvas;GuaNum:Integer);
    Procedure DrawHanZi(Canva:TCanvas;GuaNum:Integer);
  end;

Const
  DEF_GOOD = TAlphaColorRec.Blueviolet;
  DEF_NOGOOD = TAlphaColorRec.Deeppink;
  BAGUA_YIN: array [0 .. 2, 0 .. 7] of boolean = (
  (true, false, true, false, false, true, true, false),
  (false, true, true, false, true, true, false, false),
  (true, true, false, true, false, true, false, false)
  );
  MAP_GOODSTATE_GUANUM: array [0..7,0..7] of boolean =(  //1 -PosNumGua,2GuaHao
   (true,false,true,true,true,false,false,false),
   (false,true,false,false,false,true,true,true),
   (true,false,true,true,true,false,false,false),
   (true,false,true,true,true,false,false,false),
   (false,true,false,false,false,true,true,true),
   (false,true,false,false,false,true,true,true),
   (false,true,false,false,false,true,true,true),
   (true,false,true,true,true,false,false,false)
   );
implementation

function TBagua.CalcGuaNum(DateBirth: TDateTime; sex: Boolean): Integer;
var
  myYear, myMonth, myDay: word;
  // ------------- inner func
  function Twoin1(digit: Integer): Integer;
  var
    tmp: Integer;
  begin
    // tmp:=digit div 10;
    if digit div 10 > 0 then
      tmp := (digit mod 10) + (digit div 10)
    else
      tmp := digit;
    // Todo: при сложении может возникнуть болше десяти тогда опять рекурсию!
    if tmp div 10 > 0 then
      result := Twoin1(tmp)
    else
      result := tmp;

  end;

  function Last2digit1(Year: word): Integer;
  var
    l2d: Integer;
  begin
    l2d := Year mod 100;
    result := Twoin1(l2d); // ?
  end;

  function res5(num: Integer; sex: Boolean): Integer;
  begin
    if num = 5 then
    begin
      if sex then
        result := 2
      else
        result := 8;
    end
    else
    begin
      if num = 0 then
        result := 9
      else
        result := num;
    end;
  end;

// -------------
begin
  DecodeDate(DateBirth, myYear, myMonth, myDay);
  if myYear < 2000 then
  begin
    if sex then
    begin
      result := res5(10 - Last2digit1(myYear), sex);
    end
    else
    begin
      result := res5(Twoin1(5 + Last2digit1(myYear)), sex);
    end;
  end
  else
  begin
    if sex then
    begin
      result := res5(10 - 1 - Last2digit1(myYear), sex);
    end
    else
    begin
      result := res5(Twoin1(5 + 1 + Last2digit1(myYear)), sex);
    end;
  end;

end;

constructor TBagua.Create;
var i,j:integer;
begin
  for I := 0 to 2 do
    for J := 0 to 7 do
     begin
       self.BaguaFen[i][j]:=TGuaProp.Create;
     end;
end;

procedure TBagua.DrawBaGua(Canva: TCanvas; GuaNum: Integer);
 var
  Centr_Point,slice,slice2: Tpoint;
  tmp_Point,tmp_Point2 : Tpoint;
  i, j,k,m, radius: integer;
  radian: real;
  DefColor: TAlphaColor; // ?
  DefThink:single;
const
  BaGuaYuing: array [0 .. 2, 0 .. 7] of boolean = ((true, false, true, false,
    false, true, true, false), (false, true, true, false, true, true, false,
    false), (true, true, false, true, false, true, false, false));

begin
 DefColor := Canva.Stroke.Color;
 DefThink:=Canva.Stroke.Thickness;

  //  Get Center
  Centr_Point.X := (Canva.Width - 100) div 2;
  Centr_Point.Y := (Canva.Height - 200) div 2;
  radius := (Canva.Height - 100) div 3;

  self.Zi_Radus:= radius + 20;
  // ----Set Coords Bagua Feng

  for i := 0 to 2 do
  begin

    radian := 49 * Pi / 36; // 245 градусов  отнимать от 270(3*pi/2)-25
    // radian := 3*pi/2; //radian :=grad*pi/180
    for j := 0 to 7 do
    begin
      self.BaguaFen[i][j].Coord.X := Centr_Point.X + round(radius * cos(radian));
      self.BaguaFen[i][j].Coord.Y := Centr_Point.X - round(radius * sin(radian));
      radian := radian + Pi / 4;
    end;
    //----------------Draw bagua----------------------------------
    for j := 0 to 7 do
    begin
     Canva.BeginScene();
     Canva.Stroke.Thickness := 6;
       if MAP_GOODSTATE_GUANUM [GuaNum][j] then
         Canva.Stroke.Color:= DEF_GOOD
       else
         Canva.Stroke.Color:= DEF_NOGOOD;
      //-----------------------------------------------------
        tmp_Point.X:=  self.BaguaFen[i][j].Coord.X;
        tmp_Point.Y:=  self.BaguaFen[i][j].Coord.Y;
       if j<7 then
        begin
        tmp_Point2.X:=  self.BaguaFen[i][j+1].Coord.X;
        tmp_Point2.Y:=  self.BaguaFen[i][j+1].Coord.Y;
        end
       else
        begin
        tmp_Point2.X:=  self.BaguaFen[i][0].Coord.X;
        tmp_Point2.Y:=  self.BaguaFen[i][0].Coord.Y;
        end;
      //============================================
         slice :=tmp_Point2 ;
         slice2 := tmp_Point;
         //--------------------14.02
         m:=2;
         if i>1 then   m:=3;
         //--------------------14.02
         for k := 0 to m do
          begin
           slice.X := round((tmp_Point.X+slice.X) /2) ;
           slice.Y := round((tmp_Point.Y+slice.Y) /2) ;
           slice2.x := round((slice2.x + tmp_Point2.x) /2) ;
           slice2.y := round((slice2.y + tmp_Point2.y) /2) ;
          end;
           tmp_Point:=slice;
           tmp_Point2:=slice2;
      //-----------------------------------------------------
       if BAGUA_YIN[i][j] then
        createYuing(Canva, tmp_Point, tmp_Point2)
       else
        Canva.DrawLine( tmp_Point, tmp_Point2, 100);

     Canva.EndScene;
    end;
     radius := radius - 20;
  end;
   //----------------------------------------------------------


  Canva.Stroke.Color := DefColor;
  Canva.Stroke.Thickness:= DefThink;
end;




procedure TBagua.createYuing(Canva: TCanvas; start, stop: TPointF);
  function HalfLine(p1, p2: TPointF): TPointF;
  begin
    result.X := (p1.X + p2.X) / 2;
    result.Y := (p1.Y + p2.Y) / 2;
  end;

var
  DefColor: TAlphaColor;
  qtr1, qtr3, half, qtr12, qtr32: TPointF;
begin
  // --------------------------------------------
  half := HalfLine(start, stop);
  qtr1 := HalfLine(start, half);
  qtr12 := HalfLine(qtr1, half);
  qtr3 := HalfLine(half, stop);
  qtr32 := HalfLine(half, qtr3);
  // ------------------------------
  Canva.DrawLine(start,qtr12, 100);
  Canva.DrawLine(qtr32,stop, 100);
  // -------------------------------------------
  Canva.Stroke.Color := DefColor;
end;

 procedure TBagua.DrawHanZi(Canva: TCanvas; GuaNum: Integer);
begin
{    radian := 49 * Pi / 36; // 245 градусов  отнимать от 270(3*pi/2)-25
    // radian := 3*pi/2; //radian :=grad*pi/180
    for j := 0 to 7 do
    begin
      self.HanZi[i][j].Coord.X := Centr_Point.X + round(radius * cos(radian));
      self.HanZi[i][j].Coord.Y := Centr_Point.X - round(radius * sin(radian));
      radian := radian + Pi / 4;
    end;

    Canva.TextToPath()  }
end;


{ TGuaProp }

constructor TGuaProp.Create;
begin
  self.Coord.X := 0;
  self.Coord.Y := 0;
  self.isYin := false;
  self.HaoSe := DEF_GOOD;
  self.BuhaoSe := DEF_NOGOOD;
end;



end.
