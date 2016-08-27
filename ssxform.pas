{ Copyright (c) 2011-2015 by Alexandre Minoshi
   
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
unit ssxform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,  msegui, msegraphutils,mseevent,
 mseforms,msesimplewidgets, msedataedits, msestrings, msetypes,msegraphedits,
 msesplitter, inifiles, sysutils, mseterminal, msekeyboard,msetimer, aboutform,
 classes,msegraphics,msemenus,msewidgets,msetoolbar,mseificomp,mseificompglob,
 mseifiglob,msescrollbar;

type
 tssxfo = class(tmainform)
   trichbutton1: trichbutton;
   trichbutton2: trichbutton;
   trichbutton3: trichbutton;
   se_password: tstringedit;
   l_out: tlabel;
   ber1: tbooleaneditradio;
   ber2: tbooleaneditradio;
   ber3: tbooleaneditradio;
   term_cur: tterminal;
   term: tterminal;
   term2: tterminal;
   timer_move: ttimer;
   tfacecomp1: tfacecomp;
   tframecomp1: tframecomp;
   s_adds: tspacer;
   ie_: tintegeredit;
   tspacer1: tspacer;
   be_runutilsviadisplay: tbooleanedit;
   ber_rem: tbooleanedit;
   ber_locale: tbooleanedit;
   tspacer4: tspacer;
   dd_locale: tdropdownlistedit;
   ttoolbar1: ttoolbar;
   trichbutton4: trichbutton;
   tlabel1: tlabel;
   ber_xhost: tbooleanedit;
   tpopupmenu1: tpopupmenu;
   procedure on_closeform(const sender: TObject);
   procedure on_formclose(const sender: TObject);
   procedure on_formcreate(const sender: TObject);
   procedure on_run(const sender: TObject);
   procedure on_receive_text(const sender: TObject; var atext: AnsiString; const errorinput: Boolean);
   procedure on_prog_finush(const sender: TObject);
   procedure on_keyup(const sender: twidget; var ainfo: keyeventinfoty);
   procedure on_timer(const sender: TObject);
   procedure on_mouseevents(const sender: twidget; var ainfo: mouseeventinfoty);
   procedure on_showabout(const sender: TObject);
   procedure on_change_enter_method(const sender: TObject; var avalue: Boolean; var accept: Boolean);
   procedure on_set_locales_enabled(const sender: TObject; var avalue: Boolean;  var accept: Boolean);
   procedure showinfo(const msg : msestring; const clr : colorty);
 end;
var
 ssxfo: tssxfo;
 cmd,   //command
 cmdparams : msestring; //command params
 pass: string;  //password

 atxt : string; //for get locale list via tterminal
 __error, 
 __runok : boolean;
 att : integer;
 
 moveX, moveY,  //moving
 moveXX, moveYY : integer;

 sudopath,
 supath,
 xhost : msestring;
  
implementation

uses
  ssxform_mfm, shifr, functionsmse;

procedure tssxfo.on_formcreate(const sender: TObject);
var fi : tinifile;
     i : integer;
    sl : tstringlist;
begin
  sudopath := 'sudo';
  supath   := 'su';
  xhost    := 'xhost';
  
  if not FindFileBool(sudopath) then ber3.enabled := false;
  if not FindFileBool(supath) then begin 
                                     ber1.enabled := false;
                                     ber2.enabled := false;
                                     end;
  if not FindFileBool(xhost) then ber_xhost.enabled := false;

  sl := tstringlist.create;
  sl.text := getlocales;
  if trim(sl.text) = ''
  then begin 
       ber_locale.enabled := false;
       dd_locale.enabled  := false;
       end
  else begin
       dd_locale.dropdown.cols.clear;
       if sl.count > 0 then 
         for i := 0 to sl.count - 1 do
             dd_locale.dropdown.cols.addrow(msestring(sl[i]));
       if dd_locale.dropdown.cols.count > 0 then dd_locale.dropdown.itemindex := 0;
       end;
  sl.free;

  cmd := paramstr(1);
  cmdparams := '';
  if paramcount > 1 then
  for i := 2 to paramcount do
      cmdparams := cmdparams + ' '+ paramstr(i);

  caption := 'SSX runs ' + extractfilename(paramstr(1));  
  ttoolbar1.frame.caption := 'SSX runs ' + extractfilename(paramstr(1));  
  forcedirectories(gethomedir + '/.Almin-Soft/ssx');
  fi := tinifile.create(gethomedir + '/.Almin-Soft/ssx/ssx.conf');
  ber1.value := fi.readbool('passform', 'su', true);
  ber2.value := fi.readbool('passform', 'suenv', false);
  ber3.value := fi.readbool('passform', 'sudo', false);
  ber_rem.value := fi.readbool('passform', 'remember', false);
  ber_xhost.value := fi.readbool('passform', 'xhost', false);

  if ber_rem.value 
  then begin
       if ber1.value then se_password.value := decode(fi.readstring('passfr','su',    ''));
       if ber2.value then se_password.value := decode(fi.readstring('passfr','suenv', ''));
       if ber3.value then se_password.value := decode(fi.readstring('passfr','sudo',  ''));
       end
  else fi.erasesection('passfr');
  
  be_runutilsviadisplay.value := fi.readbool('passform', 'exportdisplay', false);
  ie_.value := fi.readinteger('passform', 'displaynum', 0);
  fi.free;  
end; 
 
procedure tssxfo.on_closeform(const sender: TObject);
begin
  close;
end;

procedure tssxfo.on_formclose(const sender: TObject);
var fi : tinifile;
begin
  forcedirectories(gethomedir + '/.Almin-Soft/ssx');
  fi := tinifile.create(gethomedir + '/.Almin-Soft/ssx/ssx.conf');
  fi.writebool('passform', 'su',       ber1.value);
  fi.writebool('passform', 'suenv',    ber2.value);
  fi.writebool('passform', 'sudo',     ber3.value);
  fi.writebool('passform', 'remember', ber_rem.value);
  fi.writebool('passform', 'xhost',    ber_xhost.value);

  if ber_rem.value 
  then begin
       if ber1.value then fi.writestring('passfr','su',    encode(se_password.value));
       if ber2.value then fi.writestring('passfr','suenv', encode(se_password.value));
       if ber3.value then fi.writestring('passfr','sudo',  encode(se_password.value));
       end
  else fi.erasesection('passfr');
  
  fi.writebool('passform', 'exportdisplay', be_runutilsviadisplay.value);
  fi.writeinteger('passform', 'displaynum', ie_.value);
  fi.free;  
end;

procedure tssxfo.on_change_enter_method(const sender: TObject; var avalue: Boolean; var accept: Boolean);
var fi : tinifile;
begin
  forcedirectories(gethomedir + '/.Almin-Soft/ssx');
  fi := tinifile.create(gethomedir + '/.Almin-Soft/ssx/ssx.conf');

  if sender = ber1 then se_password.value := decode(fi.readstring('passfr','su',    ''));
  if sender = ber2 then se_password.value := decode(fi.readstring('passfr','suenv', ''));
  if sender = ber3 then se_password.value := decode(fi.readstring('passfr','sudo',  ''));

  fi.free;  
end; 

procedure tssxfo.on_run(const sender: TObject);
begin
  if cmd = '' 
  then begin
       showinfo('Empty command',cl_red);
       exit;
       end
  else 
  begin
  if not FindFileBool(cmd)
  then begin
       showinfo('Command not found',cl_red);
       exit;
       end;
  end;
  
  on_formclose(sender);
  
  if sender = trichbutton2
  then begin
       term_cur.execprog(cmd);
       hide;
       exit;
       end;
       
  showinfo('Check password. Wait, please ... ',cl_black);
  PASS := se_password.value;
  att := 0;
  __error := false;
  __runok := false;
  //fake command
  writeln('run fake');
  if ber1.value then term.execprog(supath + ' -c "ls > /dev/null"');
  if ber2.value then term.execprog(supath + ' - -c "ls > /dev/null"');
  if ber3.value then term.execprog(sudopath + ' ls > /dev/null');   
  enabled := false;
  term.waitforprocess;  
  writeln('end fake');
end;

procedure tssxfo.on_receive_text(const sender: TObject; var atext: AnsiString; const errorinput: Boolean);
var s, s2 : string;
    b : boolean;
    i : integer;
begin
 if __runok then exit;
 s := trim(atext);
 if s = '' then exit; //if no errors 

 if length(s) > 0 then //prevent "wrong password" message if "Defaults pwfeedback" switch on in /etc/sudoers
    begin
      s2 := s[1];
      b := false;
      for i := 1 to length(s) do 
          if s[i] <> s2 then b := true;
      if b = false then exit;  
    end;
 case att of 
 0 : att := 1;
 1 : __error := true;
 end;//case

 (sender as tterminal).writestrln(pass);
 writeln('Send password ...');
 if (sender = term2) then __runok := true;
end;

procedure tssxfo.on_prog_finush(const sender: TObject);
begin
  enabled := true;
  if __error 
     then begin
          showinfo('Incorrect password',cl_red);
          se_password.setfocus;
          writeln('Incorrect password');
          end
     else begin
          writeln('Correct password. Continue ...');
          att := 0;
          if ber_xhost.value 
             then cmd := 'xhost local:root&' + cmd;
          if ber1.value 
             then begin
                  if be_runutilsviadisplay.value
                    then cmd := supath + ' -c "export DISPLAY=:' + inttostr(ie_.value) + ';' + cmd + ' ' + cmdparams + '"'
                    else cmd := supath + ' -c "' + cmd + ' ' + cmdparams + '"';
                  end
          else        
          if ber2.value 
             then begin
                  if be_runutilsviadisplay.value
                    then cmd := supath + ' - -c "export DISPLAY=:' + inttostr(ie_.value) + ';' + cmd + ' ' + cmdparams + '"'
                    else cmd := supath + ' - -c "' + cmd + ' ' + cmdparams + '"';
                  end
          else        
          if ber3.value 
             then cmd := sudopath + ' ' + cmd + ' ' + cmdparams;
             
          if ber_locale.value
             then cmd := 'LANG=' + dd_locale.value + ' ' + cmd;
                 
          writeln('Run command "' + cmd + '"');
          term2.execprog(cmd);
          hide;
          end;
end;

procedure tssxfo.on_keyup(const sender: twidget; var ainfo: keyeventinfoty);
begin
  if ainfo.key = key_return then on_run(sender);
end;
//moving
procedure tssxfo.on_timer(const sender: TObject);
begin
  left := gui_getpointerpos.x - moveXX;
  top := gui_getpointerpos.y - moveYY;
end;

procedure tssxfo.on_mouseevents(const sender: twidget;var ainfo: mouseeventinfoty);
begin
  if (ainfo.eventkind = ek_buttonpress) then 
  begin
    if 'ttoolbar1' = sender.name then 
     begin
       moveXX := gui_getpointerpos.x - left;
       moveYY := gui_getpointerpos.y - top;
       timer_move.enabled := true;
     end;
    if 'se_password' = sender.name then 
       se_password.setfocus;
    if 'ie_' = sender.name then 
       ie_.setfocus;
  end;
  if (ainfo.eventkind = ek_buttonrelease) then 
   if timer_move.enabled then timer_move.enabled := false;
end;

procedure tssxfo.on_showabout(const sender: TObject);
begin
 aboutfo.show(true);
end;

procedure tssxfo.on_set_locales_enabled(const sender: TObject; var avalue: Boolean; var accept: Boolean);
begin
  dd_locale.enabled := avalue;
end;

procedure tssxfo.showinfo(const msg : msestring; const clr : colorty);
begin
  l_out.caption := msg;
  l_out.font.color := clr;
  l_out.update;  
end;

end.
