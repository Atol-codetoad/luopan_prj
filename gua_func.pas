unit gua_func;

interface

uses
  System.SysUtils, System.Math, System.Types, System.UITypes, System.Classes,
  System.Variants, FMX.Graphics,
  FMX.Controls,
  FMX.Objects,
  FMX.Types;

 //---12/01/2021-------------------------

 resourcestring
 ShengQi_RU = '����������� ����� - ����� ������������� ����������� � ��������� ����� �������. ��� ������������ ����� � ��������� ����� ����������, �������� ������, �����������, ���������. ������ ����������� ����� ����������� ������� ���� � ������� ����� � ���� �������.';
 TianYI_RU = '����������� ��������- ���� ������� ����� � ������� � ��������� ������� ����� ���������� � ��� �������, ��� �������� ����, �� ������ �������� ����� � ���, �� ��� ����� ������������ ������� �������� �� ����� �������� � �������� ��������� ����������.';
 YanNian_RU = '����������� �������� - �������� ������� ����������� ��������������� � ����� ��� ������ ���������� �����. ��� ���� ���� ���������� ������� ����������.';
 FuWei_RU = '����������� ������������ - ��������� �������� ��� ����, ����� ����������� ���������, ��� ���� ������� ��������. ��� ������������ ��������� ������������, � ��� ��������� - ���������� �����. � ��� ������� ����� ������ ��������� ���� ������� �����.';
 HuoHai_RU = '����������� ����������� - ����������, �� �� ������ ��� ����� ������. �������� "������ �������" � ��������� ��������. �� ��� �������, �� �� ����������� ����� ��������� ���.';
 LiuSha_RU = '����������� ����� ������� -  ���� � ��� ������� ������� ������� ���� ���� �������, �� � ����� � �� ������ ����� ��������� ��������� ���������, � � ������� ���������� ������� ����������� ��������.';
 WuGui_RU = '����������� ���� ��������� - ��� ����������� ������ ����������� �������� � �������� �����. �������� ������ � �����. ���� ����� ���������� � ��� �������, �� ����� �������� ��������� ��� ������ � ���������.';
 JueMing_RU = '����������� ������ ���� - ��� ����� ��������� � ����������� �����. ��������� ��� �� ����� �� �� �����, �� ������ ����� � ����. ������� �� ������ ���������� ������ � ���� ����� ����. ��� ������� ����� ��� ������������� �����.';
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

   fanMian: Tpoint; //�����������
   LineLst:TList; // ������ ����  ������������ TLine
   procedure createYuing(Canva: TCanvas; start, stop: TPoint;out End1Yin,Start2Yin:TPoint);
   procedure PrepareTLine(Line:TLine;start, stop: TPoint);
  public
   IsBaguaDraw:boolean;
   ownCtrl:TControl;
   StrLuckyOrder:String;
   HanZiName:String;
    HanZi:Array [0 .. 7] of TGuaProp;//���������
   constructor Create;
   destructor  Destroy; override;
   function CalcGuaNum(DateBirth: TDateTime; sex: Boolean): Integer;
    // sex True=M
    Procedure DrawBaGua(Canva: TCanvas;GuaNum:Integer; alfa:real=0);
    Procedure DrawHanZi(Canva:TCanvas;GuaNum:Integer; alfa:real=0);
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
   //Todo: �����������
   //---------------------------------------
   STATE_NAME_GUA: array [0..7,0..7] of integer =(
   //ShengQi,TianYI,YanNian,FuWei,HuoHai,LiuSha,WuGui,JueMing
   (ord(SE),ord(E),ord(S),ord(N),ord(W),ord(NW),ord(NE),ord(SW)),  {Gua1}
   (ord(NE),ord(W),ord(NW),ord(SW),ord(E),ord(S),ord(SE),ord(N)),  {Gua2}
   (ord(S),ord(N),ord(SE),ord(E),ord(SW),ord(NE),ord(NW),ord(W)),  {Gua3}
   (ord(N),ord(S),ord(E),ord(SE),ord(NW),ord(W),ord(SW),ord(NE)),  {Gua4}
   (ord(E),ord(SE),ord(N),ord(S),ord(NE),ord(SW),ord(W),ord(NW)),  {Gua9}
   (ord(W),ord(NE),ord(SW),ord(NW),ord(SE),ord(N),ord(E),ord(S)),  {Gua6}
   (ord(NW),ord(SW),ord(NE),ord(W),ord(N),ord(SE),ord(S),ord(E)),  {Gua7}
   (ord(SW),ord(NW),ord(W),ord(NE),ord(S),ord(E),ord(N),ord(SE))   {Gua8}
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

var
 O_Line:Tline;

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
    // Todo: ��� �������� ����� ���������� ����� ������ ����� ����� ��������!
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
     self.HanZiName:='';
     self.IsBaguaDraw:=false;
 //---------------------------------
     LineLst:=TList.Create;
     LineLst.Clear;
end;

destructor TBagua.Destroy;
var
  i:integer;
begin
for i := 0 to LineLst.Count-1 do
begin
  TLine(LineLst.Items[i]).DisposeOf;
end;

LineLst.DisposeOf;
//------------------------------------
  inherited;
end;

procedure TBagua.PrepareTLine(Line: TLine; start, stop: TPoint);
var
d,rAngle:Single;
tmpPoint : TPoint ;
begin
  if Stop.X<Start.X then
  begin
   tmpPoint:=start;
   start:=stop;
   stop:=tmpPoint;
  end;

  d := SQRT( Power( Stop.x-Start.X, 2 ) + Power( Stop.y-Start.Y, 2 ) );   // Uses System.Math
  rAngle := RadToDeg( ArcSin( (Stop.y-Start.Y)/d ));

  Line.Stroke.Thickness := 5;
  Line.LineLocation := TLineLocation.Inner;
  Line.LineType := TLineType.Bottom;
  Line.RotationCenter.X := 0;

  Line.RotationCenter.Y := 0;
  Line.Height := 1;
  Line.Width  := d;
  Line.Position.X := Start.x;
  Line.Position.Y := Start.y;
  Line.RotationAngle := rAngle;
end;



procedure TBagua.DrawBaGua(Canva: TCanvas; GuaNum: Integer; alfa:real=0);
 var
  Centr_Point,slice,slice2: Tpoint;
  tmp_Point,tmp_Point2 : Tpoint;
  End1Yin,Start2Yin: Tpoint;
  i, j,k,m, radius: integer;
  radian: real;
  DefColor: TAlphaColor; // ?
  DefThink:single;
//--------------------------------
tmp1x,tmp1y,tmp2x,tmp2y:integer;
{const
  BaGuaYuing: array [0 .. 2, 0 .. 7] of boolean = ((true, false, true, false,
    false, true, true, false), (false, true, true, false, true, true, false,
    false), (true, true, false, true, false, true, false, false)); }

begin
 DefColor := Canva.Stroke.Color;
 DefThink:=Canva.Stroke.Thickness;

  //  Get Center
  Centr_Point.X := (Canva.Width {- 100} div 2)-10; //15 radius circle
  Centr_Point.Y := (Canva.Height div 2)-52;//z_radius + 12 size
  radius := (Canva.Height - 200) div 3;

  self.Zi_Radius:= radius + 10;
  // ----Set Coords Bagua Feng

  for i := 0 to 2 do
  begin
    //��� alfa ����� ���� �����������  �� ������� ��� ��������� � ���������
    radian := alfa+22 * Pi / 180; // 245 ��������  �������� �� 270(3*pi/2)-25
    // radian := 3*pi/2; //radian :=grad*pi/180
    for j := 0 to 7 do
    begin
      self.BaguaFen[i][j].Coord.X := Centr_Point.X + round(radius * sin(radian));
      self.BaguaFen[i][j].Coord.Y := Centr_Point.Y - round(radius * cos(radian));
      radian := radian + Pi / 4;
    end;
    //----------------Draw bagua----------------------------------
    for j := 0 to 7 do
    begin
    // Canva.BeginScene();
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
      End1Yin.x:=0;
      End1Yin.y:=0;
      Start2Yin.x:=0;
      Start2Yin.y:=0;

       if BAGUA_YIN[i][j] then
       begin
        createYuing(Canva, tmp_Point, tmp_Point2,End1Yin,Start2Yin);
         O_Line:=Tline.Create(self.ownCtrl);
         PrepareTLine(O_Line,tmp_Point, End1Yin);
         O_Line.Stroke.Kind:= TBrushKind.Solid;
          O_line.Stroke.Cap:= TStrokeCap.Round;
          O_Line.Stroke.Thickness:=3;
           if MAP_GOODSTATE_GUANUM [GuaNum][j] then
           O_Line.Stroke.Color:= DEF_GOOD
           else
           O_Line.Stroke.Color:= DEF_NOGOOD;
         // O_Line.Stroke.Color:=TAlphaColors.Aquamarine;
          O_Line.Visible:=true;
          O_Line.BringToFront;
          O_Line.Parent:=self.ownCtrl;
          self.LineLst.Add(O_Line);
          tmp_Point:=Start2Yin;
       end;
       // Canva.DrawLine( tmp_Point, tmp_Point2, 100);

       begin
          O_Line:=Tline.Create(self.ownCtrl);
          PrepareTLine(O_Line,tmp_Point, tmp_Point2);
          O_Line.Stroke.Kind:= TBrushKind.Solid;
          O_line.Stroke.Cap:= TStrokeCap.Round;
          O_Line.Stroke.Thickness:=3;
          if MAP_GOODSTATE_GUANUM [GuaNum][j] then
           O_Line.Stroke.Color:= DEF_GOOD
           else
           O_Line.Stroke.Color:= DEF_NOGOOD;
         // O_Line.Stroke.Color:=TAlphaColors.Aquamarine;
          O_Line.Visible:=true;
          O_Line.BringToFront;
          O_Line.Parent:=self.ownCtrl;
          self.LineLst.Add(O_Line);
       end;

     //Canva.EndScene;
    end;
     radius := radius - 20;
  end;
   //----------------------------------------------------------


  Canva.Stroke.Color := DefColor;
  Canva.Stroke.Thickness:= DefThink;
end;




procedure TBagua.createYuing(Canva: TCanvas; start, stop: TPoint;out End1Yin,Start2Yin:TPoint);
  function HalfLine(p1, p2: TPoint): TPoint;
  begin
    result.X := round((p1.X + p2.X) / 2);
    result.Y := round((p1.Y + p2.Y) / 2);
  end;

var
  DefColor: TAlphaColor;
  qtr1, qtr3, half, qtr12, qtr32: TPoint;
begin
      End1Yin.x:=0;
      End1Yin.y:=0;
      Start2Yin.x:=0;
      Start2Yin.y:=0;
  // --------------------------------------------
  half := HalfLine(start, stop);
  qtr1 := HalfLine(start, half);
  qtr12 := HalfLine(qtr1, half);
  qtr3 := HalfLine(half, stop);
  qtr32 := HalfLine(half, qtr3);
  // ------------------------------
 { Canva.DrawLine(start,qtr12, 100);
  Canva.DrawLine(qtr32,stop, 100); }
   End1Yin:= qtr12;
   Start2Yin:=qtr32;
  // -------------------------------------------
  Canva.Stroke.Color := DefColor;
end;




 procedure TBagua.DrawHanZi(Canva: TCanvas; GuaNum: Integer; alfa:real=0);
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
 //---------------------------------------------01.05.2021
  for i := 0 to 7 do
     self.HanZiName:=self.HanZiName+aNameGua[i]+',';
   delete(self.HanZiName,self.HanZiName.Length,1);
 //---------------------------------------------
  Centr_Point.X := (Canva.Width {- 100)} div 2);
  Centr_Point.Y := (Canva.Height div 2);

    radian :=alfa*pi/180; // 245 ��������  �������� �� 270(3*pi/2)-25
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
