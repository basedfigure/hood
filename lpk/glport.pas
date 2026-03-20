unit glport;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, gl, OpenGLContext,
  // Juju:
  typutil;

var
  // hood/gl - game viewport, main window
  hood_port:  TOpenGLControl;


  procedure gl_port_draw (var win:  TOpenGLControl);

implementation

procedure gl_port_draw (var win:  TOpenGLControl);
var
  bg: rgba_t;
begin
  bg:=g_view.bg;
  glClearColor (bg.r, bg.g, bg.b, bg.a);
  glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  win.SwapBuffers ();
end;

end.

