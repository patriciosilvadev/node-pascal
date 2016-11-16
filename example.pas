program example;

{$mode objfpc}
{$H+}

{$ifdef linux}
{$link toby.o}
{$Link libnode.so.48}
{$linklib c}
{$linklib stdc++}
{$LinkLib gcc_s}
{$LinkLib pthread}
{$LinkLib dl}
{$endif}

uses
  SysUtils, math;

{
extern "C" void toby(const char* nodePath, const char* processName, const char* userScript);
extern "C" char* tobyJSCompile(void* isolate, const char* source);
extern "C" char* tobyJSCall(void* isolate, const char* name, const char* value);
extern "C" bool tobyJSEmit(const char* name, const char* value);
}

procedure toby(nodePath, processName, userScript: PChar); cdecl; external;
function tobyJSCompile(isolate: Pointer; source: PChar):PChar; cdecl; external;
function tobyJSCall(isolate: Pointer; name,value: PChar):PChar; cdecl; external;
function tobyJSEmit(name, value: PChar):PChar; cdecl; external;


procedure tobyOnLoad(isolate: Pointer); cdecl; export;
begin
  writeln(':: tobyOnLoad called');
end;
function tobyHostCall(isolate: Pointer; key,value: PChar):PChar; cdecl; export;
begin
  writeln(':: tobyHostCall called');
  exit('from tobyHostCall');
end;

var
i : integer = 0;
begin
  writeln(':: example.pas main');

{$ifdef darwin}
  toby('./libnode.48.dylib', 'example', 'require("./app.js");');
{$else}
  // disable the floating point exceptions
  // otherwise, 'SIGFPE: invalid floating point operation' raises
  SetExceptionMask([exInvalidOp, exPrecision]); // exDenormalized, exZeroDivide, exOverflow, exUnderflow,
  toby('./libnode.so.48', 'example', 'require("./app.js");');
{$endif}

  while true do
  begin
    i:= i+1;
{$ifdef darwin}
    // FIXME : there's a c++ error in linux
    tobyJSEmit('test', PChar(IntToStr(i)));
{$endif}
    Sleep(1000);
  end;
end.