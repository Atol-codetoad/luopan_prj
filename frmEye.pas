unit frmEye;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,System.Permissions,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Sensors,FMX.Media,
  FMX.DialogService{ShowMessage in Android},
  FMX.Platform, System.Sensors.Components, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls;

type
  TForm2 = class(TForm)
    OrientationSensor1: TOrientationSensor;
    Timer1: TTimer;
    CameraComponent1: TCameraComponent;
    Image1: TImage;
    Button1: TButton;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CameraComponent1SampleBufferReady(Sender: TObject;
      const ATime: TMediaTime);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
      const
        PermissionCamera = 'android.permission.CAMERA';
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
    clearNum:integer;
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}
//---------------------------------------------photocamera
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
    end)
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
    TThread.Synchronize(TThread.CurrentThread, GetImage);

end;
//-----------------------------------------------------------

procedure TForm2.FormCreate(Sender: TObject);
 var
  AppEventSvc: IFMXApplicationEventService;

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
end;

procedure TForm2.FormHide(Sender: TObject);
begin
  CameraComponent1.Active := False;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  PermissionsService.RequestPermissions([PermissionCamera],
   ActivateCameraPermissionRequestResult, DisplayRationale);

end;

procedure TForm2.Timer1Timer(Sender: TObject);
begin
  { get the data from the sensor }
 (* lbTiltX.Text := Format('Tilt X: %f', [OrientationSensor1.Sensor.TiltX]);
  lbTiltY.Text := Format('Tilt Y: %f', [OrientationSensor1.Sensor.TiltY]);
  lbTiltZ.Text := Format('Tilt Z: %f', [OrientationSensor1.Sensor.TiltZ]);
  lbHeadingX.Text := Format('Heading X: %f', [OrientationSensor1.Sensor.HeadingX]);
  lbHeadingY.Text := Format('Heading Y: %f', [OrientationSensor1.Sensor.HeadingY]);
  lbHeadingZ.Text := Format('Heading Z: %f', [OrientationSensor1.Sensor.HeadingZ]);
  *)


end;


procedure TForm2.Button1Click(Sender: TObject);
begin
 self.Close;
end;

end.
