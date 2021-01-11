program BaGua_LuoPan;

uses
  System.StartUpCopy,
  FMX.Forms,
  Window_test in 'Window_test.pas' {Form1},
  gua_func in 'gua_func.pas',
  frmEye in 'frmEye.pas' {Form2},
  AndMain in 'AndMain.pas' {Form3},
  tmpLine in 'tmpLine.pas' {Form4};

{$R *.res}

begin
  Application.Initialize;
  {$IFDEF MSWINDOWS}

  Application.CreateForm(TForm1, Form1);
  {$ELSE}
  Application.CreateForm(TForm3, Form3);
  {$ENDIF}
  Application.Run;

end.
