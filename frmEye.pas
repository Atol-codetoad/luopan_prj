unit frmEye;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,System.Permissions,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Sensors,FMX.Media,
  FMX.DialogService{ShowMessage in Android},
  FMX.Platform, System.Sensors.Components, FMX.Objects,
  System.Math, //--28.03.2021
  gua_func,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts;

type
  TNamedCircle = class(TCircle)
  public
    LabelName:TLabel;
   constructor Create(AOwner: TComponent); override;
   destructor  Destroy; override;
  end;

  TForm2 = class(TForm)
    OrientationSensor1: TOrientationSensor;
    Timer1: TTimer;
    CameraComponent1: TCameraComponent;
    Image1: TImage;
    Button1: TButton;
    LayoutTop: TLayout;
    LayoutBody: TLayout;
    MotionSensor1: TMotionSensor;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CameraComponent1SampleBufferReady(Sender: TObject;
      const ATime: TMediaTime);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Circle1Tap(Sender: TObject; const Point: TPointF);
    procedure Circle1Click(Sender: TObject);

    procedure Image1Paint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
      const
        PermissionCamera = 'android.permission.CAMERA';
     var
     isNeedRepaint:Boolean;

     function AppEvent(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
     procedure AccessCameraPermissionRequestResult(Sender: TObject;
                                                  const APermissions: TArray<string>;
                                                  const AGrantResults: TArray<TPermissionStatus>);

     procedure ActivateCameraPermissionRequestResult(Sender: TObject; const APermissions: TArray<string>;
                                           const AGrantResults: TArray<TPermissionStatus>);
     procedure DisplayRationale(Sender: TObject; const APermissions: TArray<string>; const APostRationaleProc: TProc);
     procedure GetImage;
  public
    { Public declarations }
    Bagua:TBagua;
    clearNum:integer;
    angle:real;
    BaguaActiveLink: array[0..7] of TNamedCircle;  //13.11.2021
    //--------------------------28.03.2021
   function calcTiltCompensatedMagneticHeading(const {acel}aGx,aGy,aGz,{mag} aMx,aMy,aMz:double ):double;
   function IsLandscapeMode():boolean;
    //--------------------------28.03.2021
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.NmXhdpiPh.fmx ANDROID}
{$R *.LgXhdpiTb.fmx ANDROID}

//---------------------------------------------photocamera
{ TForm2 }
procedure TForm2.AccessCameraPermissionRequestResult(Sender: TObject;
  const APermissions: TArray<string>;
  const AGrantResults: TArray<TPermissionStatus>);
begin

  // 1 permission involved: CAMERA
  if (Length(AGrantResults) = 1) and (AGrantResults[0] = TPermissionStatus.Granted) then
    { Fill the resolutions. }
      CameraComponent1.CaptureSetting := CameraComponent1.AvailableCaptureSettings[0] ;
  //  else

   // TDialogService.ShowMessage('Cannot access the camera because the required permission has not been granted')
end;



function TForm2.AppEvent(AAppEvent: TApplicationEvent;
  AContext: TObject): Boolean;
begin
  Result := True;

  case AAppEvent of
    TApplicationEvent.WillBecomeInactive:
      CameraComponent1.Active := False;
    TApplicationEvent.EnteredBackground:
      CameraComponent1.Active := False;
    TApplicationEvent.WillTerminate:
      CameraComponent1.Active := False;
  end;
end;





// Optional rationale display routine to display permission requirement rationale to the user
procedure TForm2.DisplayRationale(Sender: TObject; const APermissions: TArray<string>; const APostRationaleProc: TProc);
begin
  // Show an explanation to the user *asynchronously* - don't block this thread waiting for the user's response!
  // After the user sees the explanation, invoke the post-rationale routine to request the permissions
  TDialogService.ShowMessage('The app needs to access the camera in order to work',
    procedure(const AResult: TModalResult)
    begin
      APostRationaleProc
    end) ;
end;

procedure TForm2.ActivateCameraPermissionRequestResult(Sender: TObject;
  const APermissions: TArray<string>;
  const AGrantResults: TArray<TPermissionStatus>);
begin
  // 1 permission involved: CAMERA
  if (Length(AGrantResults) = 1) and (AGrantResults[0] = TPermissionStatus.Granted) then

    { Turn on the Camera }
    CameraComponent1.Active := True
    else
    TDialogService.ShowMessage('Cannot start the camera');
end;

//------------------------------------------photocamera event
procedure TForm2.GetImage;
begin
  CameraComponent1.SampleBufferToBitmap(Image1.Bitmap, True);
end;



procedure TForm2.CameraComponent1SampleBufferReady(Sender: TObject;
  const ATime: TMediaTime);
begin
    TThread.Synchronize(TThread.CurrentThread, GetImage);   //временно для выяснения отрисовки
    self.Invalidate;
end;
//-----------------------------------------------------------

procedure TForm2.FormCreate(Sender: TObject);
 var
  AppEventSvc: IFMXApplicationEventService;
  i:integer;
begin
 PermissionsService.RequestPermissions([PermissionCamera], AccessCameraPermissionRequestResult, DisplayRationale);
  {
    Add platform service to see camera state. This is needed to enable or disable the camera when the application
    goes to background.
  }
  if TPlatformServices.Current.SupportsPlatformService(IFMXApplicationEventService, AppEventSvc)
  then
    AppEventSvc.SetApplicationEventHandler(AppEvent);
//-----------------------------
    CameraComponent1.Active := False;
    CameraComponent1.Kind := TCameraKind.BackCamera;
    CameraComponent1.Quality:= TVideoCaptureQuality.PhotoQuality;
    isNeedRepaint:=false;
    self.clearNum:=-1;
    for I := 0 to 7 do
       self.BaguaActiveLink[i]:=nil;
end;

procedure TForm2.FormDestroy(Sender: TObject);
var
  i:integer;
begin
     for I := 0 to 7 do
       self.BaguaActiveLink[i].DisposeOf;
end;

procedure TForm2.FormHide(Sender: TObject);
begin
  CameraComponent1.Active := False;
  isNeedRepaint:=false;
end;
{$region ShowGua}
procedure TForm2.Circle1Tap(Sender: TObject; const Point: TPointF);
begin
  if Sender is Tcircle then
  TDialogService.ShowMessage ((Sender as Tcircle).TagString)  ;
end;

procedure TForm2.Circle1Click(Sender: TObject);
begin
    if Sender is Tcircle then
  TDialogService.ShowMessage ((Sender as Tcircle).TagString)  ;
end;


 procedure TForm2.Image1Paint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
var
  num,i,j: integer;

 // ClearNum:integer;

  StrList,NameLst:TstringList;
  tmpStr:String;
  TmpBmp:TBitMap;
  P1,P2,P3,P4 : Tpoint;
  HouTianIdx:Integer;
begin
 if not isNeedRepaint then exit; // потом подумать
 if (self.clearNum<0) then  exit;

 if (sender is TImage) then
 begin
  if  not assigned(Bagua)then
   Bagua:=TBagua.Create
   else
   if Bagua.IsBaguaDraw then exit;

 // Canvas.Clear(TalphaColors.Aliceblue);
 // if  not self.Image1.Bitmap.HandleAllocated  then
 //   Image1.Bitmap.Canvas.Create;
  TmpBmp:=TBitMap.Create;
  TmpBmp.Height:=round(Image1.Height);
  TmpBmp.Width:=round(Image1.Width);
  TmpBmp.Clear(TalphaColors.Goldenrod);
  (Sender as TImage).Bitmap.Assign(TmpBmp);

   (Sender as TImage).Bitmap.Canvas.BeginScene;
  //DrawBaGua1(self.Canvas);
  Bagua.ownCtrl:= Image1;  //bagua3
  Bagua.DrawBaGua({ (Sender as TImage).Bitmap.}Canvas,self.ClearNum,self.angle );
  Bagua.DrawHanZi( Canvas,self.ClearNum,self.angle ); //11.04.2021
  Canvas.Stroke.Color:=TAlphacolors.Red;
  Canvas.DrawLine( P3, P4, 1);
  Bagua.IsBaguaDraw:=true;
  (Sender as TImage).Bitmap.Canvas.EndScene;
  //-----------------------------------Tcircle
    //------------------------------------------
    StrList:=TstringList.Create;
    StrList.StrictDelimiter:=true;
    StrList.Delimiter:=',';
    StrList.DelimitedText:=Bagua.StrLuckyOrder;
    //------------------------------------------01.05.2021
    NameLst :=TstringList.Create;
    NameLst.StrictDelimiter:=true;
    NameLst.Delimiter :=',';
    NameLst.DelimitedText:=Bagua.HanZiName;
    NameLst.Count;
    //------------------------------------------
    for I:=0 to 7 do
  begin
      HouTianIdx:=i-1;
      if HouTianIdx =-1 then
         HouTianIdx:=7;
      if  not assigned(BaguaActiveLink[i]) then
      begin
        BaguaActiveLink[i] :=TNamedCircle.Create(self);
        BaguaActiveLink[i].Parent:=self;

        BaguaActiveLink[i].Position.X:= Bagua.HanZi[i].Coord.X-16;
        BaguaActiveLink[i].Position.Y:= Bagua.HanZi[i].Coord.Y-16;
        BaguaActiveLink[i].Width:= 32;
        BaguaActiveLink[i].Height:= 32;
        if MAP_GOODSTATE_GUANUM [self.clearNum][HouTianIdx] then
        begin
             BaguaActiveLink[i].Stroke.Color:= DEF_GOOD;
             BaguaActiveLink[i].Fill.Color:= DEF_GOOD;
        end
        else
        begin
             BaguaActiveLink[i].Stroke.Color:= DEF_NOGOOD;
             BaguaActiveLink[i].Fill.Color:= DEF_NOGOOD;
        end;
        //--------------------------------------

        BaguaActiveLink[i].LabelName.Text:= NameLst.Strings[i] ;
        BaguaActiveLink[i].LabelName.TextSettings.BeginUpdate ;
        try
         BaguaActiveLink[i].LabelName.TextSettings.Font.Size:=14;
         BaguaActiveLink[i].LabelName.TextSettings.FontColor:= TAlphacolors.Aquamarine;
         BaguaActiveLink[i].LabelName.StyledSettings  := BaguaActiveLink[i].LabelName.StyledSettings -[TStyledSetting.ssFontColor,TStyledSetting.Size]  ;
        finally
            BaguaActiveLink[i].LabelName.TextSettings.EndUpdate;
        end;
        BaguaActiveLink[i].LabelName.Position.y:= BaguaActiveLink[i].LabelName.Position.Y+5;
        BaguaActiveLink[i].LabelName.Position.x:= BaguaActiveLink[i].LabelName.Position.x+2;
        //--------------------------------------
        BaguaActiveLink[i].Visible:=true ;
        BaguaActiveLink[i].OnTap:= Circle1Tap ;
        BaguaActiveLink[i].OnClick:=Circle1Click ;
        BaguaActiveLink[i].BringToFront;
        BaguaActiveLink[i].BringChildToFront(BaguaActiveLink[i].LabelName);
      end;
   end;
   //------------------------01.05.2021   error!!!  not create label and position!!! debug
   { for I := 0 to NameLst.Count-1 do
     Begin

     // BaguaActiveLink[i].LabelName.Position:= BaguaActiveLink[i].Position;
     // BaguaActiveLink[i].LabelName.Position.Y:= BaguaActiveLink[i].Position.y;
     // BaguaActiveLink[i].LabelName.SIZE := BaguaActiveLink[i].SIZE;
      BaguaActiveLink[i].LabelName.font.Size:=10;
      BaguaActiveLink[i].LabelName.Visible:=true;
      BaguaActiveLink[i].LabelName.Text:= NameLst.Strings[i] ;
      BaguaActiveLink[i].LabelName.FontColor :=TAlphaColors.Aqua;
      BaguaActiveLink[i].LabelName.BringToFront;
     end;  }
   //---------------------------------
  for I:=0 to StrList.Count-1 do
  begin
     j:= strtoint(strList.Strings[i]);
     BaguaActiveLink[j].TagString:= TXT_GUA_RU[i] ;
  end;
  //-----------------------------------
  StrList.DisposeOf;
  NameLst.DisposeOf;
  self.Invalidate; //repaint
 // Image1.Release;
  //Bagua.DisposeOf;
  //Bagua:=nil;
  //self.IsNeedRepaint:=false; //16.01.2021
  end;
end;






{$endRegion}

procedure TForm2.FormShow(Sender: TObject);
begin

  PermissionsService.RequestPermissions([PermissionCamera],
   ActivateCameraPermissionRequestResult, DisplayRationale);

   isNeedRepaint:=true;
end;

(*
procedure TForm2.Timer1Timer(Sender: TObject);
begin
 // get the data from the sensor
 (* lbTiltX.Text := Format('Tilt X: %f', [OrientationSensor1.Sensor.TiltX]);
  lbTiltY.Text := Format('Tilt Y: %f', [OrientationSensor1.Sensor.TiltY]);
  lbTiltZ.Text := Format('Tilt Z: %f', [OrientationSensor1.Sensor.TiltZ]);
  lbHeadingX.Text := Format('Heading X: %f', [OrientationSensor1.Sensor.HeadingX]);
  lbHeadingY.Text := Format('Heading Y: %f', [OrientationSensor1.Sensor.HeadingY]);
  lbHeadingZ.Text := Format('Heading Z: %f', [OrientationSensor1.Sensor.HeadingZ]);

(y>0) heading = 90 - atan2(x,y)*180 / pi
(y<0) heading = 270 - atan2(x,y)*180 / pi
(y=0, x<0) heading = 180.0
(y=0, x>0) heading = 0.0
 //------------------------https://stackoverflow.com/questions/52878520/how-to-make-tilt-compensated-magnetic-heading-using-firemonkey
 // this function x,y,z axis for the phone in vertical orientation (portrait)
function calcTiltCompensatedMagneticHeading(const {acel}aGx,aGy,aGz,{mag} aMx,aMy,aMz:double ):double; //return heading in degrees
var Phi,Theta,cosPhi,sinPhi,Gz2,By2,Bz2,Bx3:Double;
begin
  Result := NaN;   //=invalid
  // https://www.st.com/content/ccc/resource/technical/document/design_tip/group0/56/9a/e4/04/4b/6c/44/ef/DM00269987/files/DM00269987.pdf/jcr:content/translations/en.DM00269987.pdf
  Phi := ArcTan2(aGy,aGz);    //calc Roll (Phi)
  cosPhi := Cos(Phi);         //memoise phi trigs
  sinPhi := Sin(Phi);

  Gz2 := aGy*sinPhi+aGz*cosPhi;
  if (Gz2<>0) then
    begin
      Theta := Arctan(-aGx/Gz2);                 // Theta = Pitch
      By2 := aMz * sinPhi - aMy * cosPhi;
      Bz2 := aMy * sinPhi + aMz * cosPhi;
      Bx3 := aMx * Cos(Theta) + Bz2 * Sin(Theta);
      Result := ArcTan2(By2,Bx3)*180/Pi-90;      //convert to degrees and then add   90 for North based heading  (Psi)
    end;
end;

  //usage

  {$IFDEF ANDROID}
  mx := MagSensor1.HeadingX;  //in mTeslas
  my := MagSensor1.HeadingY;
  mz := MagSensor1.HeadingZ;

  aGx := MotionSensor1.Sensor.AccelerationX;  //get acceleration sensor
  aGy := MotionSensor1.Sensor.AccelerationY;
  aGz := MotionSensor1.Sensor.AccelerationZ;

  aMagHeading:=0;
  if IsLandscapeMode then  //landscape phone orientation
    begin
      aMagHeading := calcTiltCompensatedMagneticHeading({acel}aGy,-aGx,aGz,{mag} my,-mx,mz); //rotated 90 in z axis
    end
    else begin  //portrait orientation
      aMagHeading := calcTiltCompensatedMagneticHeading({acel}aGx,aGy,aGz,{mag} mx,my,mz);  // normal portrait orientation
    end;
  {$ENDIF ANDROID}
  //----------------------------------



end;  *)



//------------------------------------------------------------------28.03.2021
 {$IFDEF ANDROID}
function TForm2.calcTiltCompensatedMagneticHeading(const {acel}aGx,aGy,aGz,{mag} aMx,aMy,aMz:double ):double; //return heading in degrees
var Phi,Theta,cosPhi,sinPhi,Gz2,By2,Bz2,Bx3:Double;
begin
  Result := NaN;   //=invalid
  // https://www.st.com/content/ccc/resource/technical/document/design_tip/group0/56/9a/e4/04/4b/6c/44/ef/DM00269987/files/DM00269987.pdf/jcr:content/translations/en.DM00269987.pdf
  Phi := ArcTan2(aGy,aGz);    //calc Roll (Phi)
  cosPhi := Cos(Phi);         //memoise phi trigs
  sinPhi := Sin(Phi);

  Gz2 := aGy*sinPhi+aGz*cosPhi;
  if (Gz2<>0) then
    begin
      Theta := Arctan(-aGx/Gz2);                 // Theta = Pitch
      By2 := aMz * sinPhi - aMy * cosPhi;
      Bz2 := aMy * sinPhi + aMz * cosPhi;
      Bx3 := aMx * Cos(Theta) + Bz2 * Sin(Theta);
      Result := ArcTan2(By2,Bx3)*180/Pi-90;      //convert to degrees and then add   90 for North based heading  (Psi)
    end;
end;

procedure TForm2.Timer1Timer(Sender: TObject);
var
{acel}aGx,aGy,aGz,{mag} Mx,My,Mz, aMagHeading:double ;


begin
  { get the data from the sensor }
(*  lbTiltX.Text := Format('Tilt X: %f', [OrientationSensor1.Sensor.TiltX]);
  lbTiltY.Text := Format('Tilt Y: %f', [OrientationSensor1.Sensor.TiltY]);
  lbTiltZ.Text := Format('Tilt Z: %f', [OrientationSensor1.Sensor.TiltZ]);
  lbHeadingX.Text := Format('Heading X: %f', [OrientationSensor1.Sensor.HeadingX]);
  lbHeadingY.Text := Format('Heading Y: %f', [OrientationSensor1.Sensor.HeadingY]);
  lbHeadingZ.Text := Format('Heading Z: %f', [OrientationSensor1.Sensor.HeadingZ]);  *)
  //-----------------------------------------------28.03.2021
  OrientationSensor1.Active:=true;
  MotionSensor1.Active:=true;
  mx := OrientationSensor1.Sensor.HeadingX;  //in mTeslas OrientationSensor1.Sensor.HeadingX
  my := OrientationSensor1.Sensor.HeadingY;
  mz := OrientationSensor1.Sensor.HeadingZ;
  if (mx = -nan) or (my = -nan) or (mz = -nan) then
    begin
     MotionSensor1.Active:=false;
     OrientationSensor1.Active:=false;
     exit;
    end;

  aGx := MotionSensor1.Sensor.AccelerationX;  //get acceleration sensor
  aGy := MotionSensor1.Sensor.AccelerationY;
  aGz := MotionSensor1.Sensor.AccelerationZ;

  aMagHeading:=0;
  if IsLandscapeMode then  //landscape phone orientation
    begin
      aMagHeading := calcTiltCompensatedMagneticHeading({acel}aGy,-aGx,aGz,{mag} my,-mx,mz); //rotated 90 in z axis
    end
    else begin  //portrait orientation
      aMagHeading := calcTiltCompensatedMagneticHeading({acel}aGx,aGy,aGz,{mag} mx,my,mz);  // normal portrait orientation
    end;
      OrientationSensor1.Active:=false;
      MotionSensor1.Active:=false;
      if  aMagHeading <> -nan  then
        self.angle := aMagHeading; // Format('Angle in degree: %f',[aMagHeading]);
      //-----------------01.05.2021  !!error float point debug!!!
     { if assigned(Bagua) then
            Bagua.IsBaguaDraw:=false; }
      self.Updated;



end;

function TForm2.IsLandscapeMode: boolean;
var
  ScreenService: IFMXScreenService;
begin
 if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, IInterface(ScreenService)) then
  begin
  if ScreenService.GetScreenOrientation in [TScreenOrientation.Landscape,TScreenOrientation.InvertedLandscape] then
    result:=true
  else
    result:=false;
  end
  else
    result:=false;
end;
     {$ENDIF ANDROID}
//--------------------------------------------------28.03.2021


procedure TForm2.Button1Click(Sender: TObject);
begin
 self.Close;
end;
{ TForm2 end }

{ TNamedCircle }

constructor TNamedCircle.Create(AOwner: TComponent);
begin
 inherited;
 if not assigned(self.LabelName) then
     LabelName:=TLabel.Create(self);
 LabelName.Parent:=self;


 LabelName.Visible:=true;

end;

destructor TNamedCircle.Destroy;
begin
  freeandnil(LabelName);
  inherited;
end;
{ TNamedCircle End }

end.
