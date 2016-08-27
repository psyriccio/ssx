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
unit aboutform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msesplitter,
 msesimplewidgets,msewidgets,msetimer,msetoolbar;
type
 taboutfo = class(tmseform)
   tlabel1: tlabel;
   trichbutton3: trichbutton;
   timer_move: ttimer;
   ttoolbar1: ttoolbar;
   procedure on_close(const sender: TObject);
   procedure on_mouseevents(const sender: twidget; var ainfo: mouseeventinfoty);
   procedure on_timer(const sender: TObject);
 end;
var
 aboutfo: taboutfo;
 moveXX, moveYY : integer;
  
implementation
uses
 aboutform_mfm;
procedure taboutfo.on_close(const sender: TObject);
begin
  close;
end;

procedure taboutfo.on_mouseevents(const sender: twidget; var ainfo: mouseeventinfoty);
begin
  if (ainfo.eventkind = ek_buttonpress) then 
  begin
    if 'ttoolbar1' = sender.name then 
     begin
       moveXX := gui_getpointerpos.x - left;
       moveYY := gui_getpointerpos.y - top;
       timer_move.enabled := true;
     end;
  end;
  if (ainfo.eventkind = ek_buttonrelease) then 
   if timer_move.enabled then timer_move.enabled := false;
end;

procedure taboutfo.on_timer(const sender: TObject);
begin
  left := gui_getpointerpos.x - moveXX;
  top := gui_getpointerpos.y - moveYY;
end;

end.
