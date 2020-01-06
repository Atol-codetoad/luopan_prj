program BaGua_LuoPan;

uses
  System.StartUpCopy,
  FMX.Forms,
  Window_test in 'Window_test.pas' {Form1} ,
  gua_func in 'gua_func.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;

end.
