{ Copyright (c) 2011-2014 by Alexandre Minoshi
   
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; version 2 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
program ssx;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifdef FPC}
 {$ifdef mswindows}{$apptype gui}{$endif}
{$endif}
uses
 {$ifdef FPC}{$ifdef unix}cthreads,{$endif}{$endif}
 msegui, mseforms, ssxform, baseunix, mseprocutils, aboutform, skinsupport;
 
const helpstr = #10+'SSX - The graphical frontend for su and sudo'+#10+
              '    Depends neither GTK nor Qt, only X11.'+#10+
              #10+
              'Version : 3.0'+#10+
              #10+
              'USAGE:'+#10+
              '       ssx <command> [command params]'+#10+
              #10+
              'Examples:'+#10+
              '       ssx pacmanxg'+#10+
              '       ssx ./pacmanexpress'+#10+
              '       ssx ../pacmanexpress'+#10+
              '       ssx /opt/pacmanexpress'+#10+
              '       ssx pacmanxg --exec "pacman -S opera"'+#10+
              #10+
              'Attention!'+#10+
              'SSX checks first parameter, if it available via PATH,'+#10+
              'so next command line will return an error:'+#10+
              '       ssx LANG=en_US.UTF8 pacmanexpress'+#10+
              #10+
              #10+
              'Copyright@Alexandre Minoshi (AlminSoft Group)'+#10+
              '2011-2015'+#10+
              'http://almin-soft.ru'+#10+
              ''+#10+
              'All bugs send to almin-soft@yandex.ru'+#10;
              
var __param : string;
    i : integer;
 
begin
 if (paramstr(1) = '--help')or(paramstr(1) = '-h')or(paramstr(1) = '/h')
 then begin
      writeln(helpstr);
      exit;
      end;

 if (FpGetgid=0) and (FpGetuid=0) 
 then begin
      __param := '';
      for i := 1 to paramcount do 
             __param := __param + ' '+ paramstr(i);
      execwaitmse(__param);
      exit;
      end;  
      
  application.createform(tssxfo,ssxfo);
  application.createform(taboutfo,aboutfo);
  aboutfo.tlabel1.caption := helpstr;
  initskinsupport;
  application.run;
end.
