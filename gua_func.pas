unit gua_func;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, FMX.Graphics,
  FMX.Types;

 //---12/01/2021-------------------------

 resourcestring
 ShengQi_RU = 'направление Успех - самое благоприятное направление с наилучшим видом энергии. Оно обеспечивает успех в абсолютно любых начинаниях, приносит деньги, известность, положение. Лучшее направление чтобы расположить рабочий стол и входную дверь в этой стороне.';
 TianYI_RU = 'направление Здоровье- Если входная дверь в спальню и изголовье кровати будут направлены в эту сторону, или принимая пищу, вы будете обращены лицом к ней, то это самым благотворным образом скажется на вашем здоровье и прибавит жизненной активности.';
 YanNian_RU = 'направление Гармония - помогает создать гармоничные взаимоотношения в семье для долгой совместной жизни. Для этой цели установить кровать изголовьем.';
 FuWei_RU = 'направление Стабильность - прекрасно подходит для того, чтобы развиваться внутренне, оно дает ясность мышления. Это способствует повышению квалификации, и как следствие - карьерному росту. В эту сторону будет хорошо направить свое рабочее место.';
 HuoHai_RU = 'направление Препятствия - неприятное, но из плохих оно самое слабое. Означает "мелкие неудачи" и небольшие проблемы. Не так страшно, но по возможности лучше избегайте его.';
 LiuSha_RU = 'направление Шесть злодеев -  Если в эту сторону смотрит рабочий стол либо кровать, то в семье и на работе могут появиться серьезные конфликты, а в бизнесе неожиданно всплыть юридические проблемы.';
 WuGui_RU = 'направление Пять Призраков - это направление грозит несчастными случаями и потерями денег. Возможны пожары и кражи. Если спать изголовьем в эту сторону, то можно серьезно захворать или впасть в депрессию.';
 JueMing_RU = 'направление Полный крах - Это самое неудачное и вредоносное место. Избегайте его во чтобы то ни стало, не сидите лицом к нему. Кровать не должна изголовьем стоять в этой части дома. Для входной двери это нежелательное место.';
//---------------------------------------------------------------------------------
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
   Zi_Radius:Integer ;
   BaguaFen: array [0 .. 2, 0 .. 7] of TGuaProp;

   fanMian: Tpoint; //направление
   procedure createYuing(Canva: TCanvas; start, stop: TPointF);
  public
   StrLuckyOrder:String;
    HanZi:Array [0 .. 7] of TGuaProp;//времменно
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
  ( false, true, false, false, true, true, false,true),
  ( true, true, false, true, true, false, false,false),
  ( true, false, true, false, true, false, false,true)
  );
  MAP_GOODSTATE_GUANUM: array [0..7,0..7] of boolean =(  //1 -PosNumGua,2GuaHao
    {N,   NE,   E,   SE,  S,   SW,   W,    NW}
   (true,false,true,true,true,false,false,false),  {Gua1}
   (false,true,false,false,false,true,true,true),  {Gua2}
   (true,false,true,true,true,false,false,false),  {Gua3}
   (true,false,true,true,true,false,false,false),  {Gua4}
   (true,false,true,true,true,false,false,false),  {Gua9}
   (false,true,false,false,false,true,true,true),  {Gua6}
   (false,true,false,false,false,true,true,true),  {Gua7}
   (false,true,false,false,false,true,true,true)   {Gua8}
   );
   //Todo: Пересчитать
   //---------------------------------------
   STATE_NAME_GUA: array [0..7,0..7] of integer =(
   //ShengQi,TianYI,YanNian,FuWei,HuoHai,LiuSha,WuGui,JueMing
   (ord(SE),ord(E),ord(S),ord(N),ord(W),ord(NW),ord(NE),ord(SW)),  {Gua1}
   (ord(NE),ord(W),ord(NW),ord(SW),ord(N),ord(S),ord(SE),ord(E)),  {Gua2}
   (ord(S),ord(N),ord(SE),ord(E),ord(SW),ord(NE),ord(NW),ord(W)),  {Gua3}
   (ord(N),ord(S),ord(E),ord(SE),ord(NE),ord(W),ord(SW),ord(NW)),  {Gua4}
   (ord(E),ord(SE),ord(N),ord(S),ord(NW),ord(SW),ord(W),ord(NE)),  {Gua9}
   (ord(W),ord(NE),ord(SW),ord(NW),ord(S),ord(N),ord(E),ord(SE)),  {Gua6}
   (ord(NW),ord(SW),ord(NE),ord(W),ord(E),ord(SE),ord(S),ord(N)),  {Gua7}
   (ord(SW),ord(NW),ord(W),ord(NE),ord(SE),ord(E),ord(N),ord(S))   {Gua8}
   );
   //---------------------------------------
  NAME_GUA: array [0..7] of string  = (
   chr(29983)+chr(12115),chr(12701)+chr(21307),chr(24310)+chr(63886),chr(20239)+chr(20301),
   chr(31096)+chr(23475),chr(63953)+chr(29022),chr(20116)+chr(39740),chr(32477)+chr(21629)
   );

  {     NAME_GUA: array [0..7] of string  = ('N','NE','E','SE','S','SW','W','NW'
   );  }
 TXT_GUA_RU:  array [0..7] of string =(
   ShengQi_RU,
   TianYI_RU,
   YanNian_RU,
   FuWei_RU,
   HuoHai_RU,
   LiuSha_RU,
   WuGui_RU,
   JueMing_RU
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
  //This calc china year (if day, month,year<china year then myyear -1)
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
       if i=0 then
         HanZi [j]:=TGuaProp.Create;
     end;
     self.StrLuckyOrder:='';
end;

procedure TBagua.DrawBaGua(Canva: TCanvas; GuaNum: Integer);
 var
  Centr_Point,slice,slice2: Tpoint;
  tmp_Point,tmp_Point2 : Tpoint;
  i, j,k,m, radius: integer;
  radian: real;
  DefColor: TAlphaColor; // ?
  DefThink:single;
{const
  BaGuaYuing: array [0 .. 2, 0 .. 7] of boolean = ((true, false, true, false,
    false, true, true, false), (false, true, true, false, true, true, false,
    false), (true, true, false, true, false, true, false, false)); }

begin
 DefColor := Canva.Stroke.Color;
 DefThink:=Canva.Stroke.Thickness;

  //  Get Center
  Centr_Point.X := (Canva.Width - 100) div 2;
  Centr_Point.Y := (Canva.Height - 200) div 2;
  radius := (Canva.Height - 100) div 3;

  self.Zi_Radius:= radius + 10;
  // ----Set Coords Bagua Feng

  for i := 0 to 2 do
  begin
    //где 0 будет угол вычисленный  по формуле для телефонов в закладках
    radian := 0+22 * Pi / 180; // 245 градусов  отнимать от 270(3*pi/2)-25
    // radian := 3*pi/2; //radian :=grad*pi/180
    for j := 0 to 7 do
    begin
      self.BaguaFen[i][j].Coord.X := Centr_Point.X + round(radius * sin(radian));
      self.BaguaFen[i][j].Coord.Y := Centr_Point.X - round(radius * cos(radian));
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
        { m:=2;
         if i>1 then   m:=3; }
         //--------------------14.02
         for k := 0 to 2 do
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
var
 Centr_Point: Tpoint;
 i:Integer;
 radian: real;
 Rect:TRectF;
 aTypeGua:array [0..7] of integer ;
 aNameGua:array [0..7] of string ;
begin
 for i := 0 to 7 do
   aTypeGua[i]:=STATE_NAME_GUA[GuaNum][i];


  for i := 0 to 7 do
  begin
   aNameGua[aTypeGua[i]] := NAME_GUA[i];
   self.StrLuckyOrder:=self.StrLuckyOrder + System.SysUtils.IntToStr(aTypeGua[i]) + ',' ;

  end;
  delete(self.StrLuckyOrder,self.StrLuckyOrder.Length,1);
 //---------------------------------------------
  Centr_Point.X := (Canva.Width - 100) div 2;
  Centr_Point.Y := (Canva.Height+60) div 2;

    radian :=0*pi/180; // 245 градусов  отнимать от 270(3*pi/2)-25
    // radian := 3*pi/2; //radian :=grad*pi/180
    for i := 0 to 7 do
    begin
     //----------------------------
      if i=0 then
       begin
         self.fanMian.X :=Centr_Point.X + round((self.Zi_radius +20)* sin(radian));
         self.fanMian.Y := Centr_Point.Y - round((self.Zi_radius+20) * cos(radian));
         Rect:=TRectF.Create(fanMian.X-7,fanMian.Y-7,fanMian.X+7,fanMian.Y+7);
         Canva.BeginScene();
         Canva.Font.Style := [TFontStyle.fsBold];
         Canva.Font.Size := 10;
         Canva.Fill.Color:= TAlphaColors.Green ;
         Canva.FillText(Rect, chr(21271) , false, 1,         //chr(21271) bei  https://web-shpargalka.ru/spets-simvoli-utf-8.php
               [TFillTextFlag.RightToLeft], TTextAlign.Center,
                TTextAlign.Center);
         Canva.EndScene;
       end;
     //----------------------------
      self.HanZi[i].Coord.X := Centr_Point.X + round(self.Zi_radius * sin(radian));
      self.HanZi[i].Coord.Y := Centr_Point.Y - round(self.Zi_radius * cos(radian));
      radian := radian + Pi / 4;
      Rect:=TRectF.Create(HanZi[i].Coord.X-12,HanZi[i].Coord.Y-12,HanZi[i].Coord.X+12,HanZi[i].Coord.Y+12);
      Canva.BeginScene();
      Canva.Font.Style := [TFontStyle.fsBold];
      Canva.Font.Size := 12;
      Canva.Stroke.Color:=TAlphaColors.Greenyellow;
      //--------------------------------------

      //-------------------------------------
      Canva.Fill.Color:=TAlphaColors.red;
      Canva.FillText(Rect, aNameGua[i] , false, 1,
               [], TTextAlign.Center,
                TTextAlign.Center);

      //Canva.FillRect(Rect, 0, 0, AllCorners, 100);

      Canva.EndScene;
     end;
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
