unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  Tmetrick = class(TForm)
    butforopenfile: TButton;
    OpenDialog1: TOpenDialog;
    start: TButton;
    winforcode: TMemo;
    Changethecode: TButton;
    procedure butforopenfileClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure startClick(Sender: TObject);
    procedure ChangethecodeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  Typelistofvariables = ^listofvariables;

  listofvariables = record
    thevariables: string;
    next: Typelistofvariables;
  end;

  Typelistofsubroutinsvariables = ^listofsubroutinsvariables;

  listofsubroutinsvariables = record
    thevariables: string;
    next: Typelistofsubroutinsvariables;
  end;

  Typesetofchar = set of char;

const
  const_number0 = 0;
  const_number1 = 1;
  const_number2 = 2;
  const_number3 = 3;
  const_number4 = 4;
  const_number5 = 5;
  const_number6 = 6;
  const_number7 = 7;
  const_number8 = 8;
  const_number9 = 9;
  const_php = '<?php';
  const_phpwithspace = '<?php ';
  const_thestartofprogrammbody = '{';
  const_theendofprogrammbody = '}';
  const_thestartofcomments = '/*';
  const_theendofcomments = '*/';
  const_thedollar = '$';
  const_theendofoperator = ';';
  const_theendofline = '#13#10';
  const_thelineofcomments = '//';
  const_thespace = ' ';
  const_thenull = '';
  const_thequote = '''';
  const_thedoublequote = '"';
  const_theglobals = 'globals[';
  const_theglobal = 'global';
  const_theprocedure = 'procedure';
  const_thefunction = 'function';
  const_theecho = 'echo';
  const_theif = 'if';
  const_theclass = 'class';
  const_thefor = 'for';
  const_thetextforwindowsforcode = 'The code:';

var
  metrick: Tmetrick;
  waytofile, phpcode: string;
  fileofphpcode: textfile;
  thevariables, thefirstvariables: Typelistofvariables;
  setofsymbols: Typesetofchar = ['=', ' ', ')', '(', '[', ']', '<', '>', ';',
    ',', '+', '-'];
  subroutinevariables, firstofsubroutinevariables
    : Typelistofsubroutinsvariables;

implementation

{$R *.dfm}

procedure skipthealgorithm(phpcode: string; nameofcycle: string;
  sizeofcycle: integer; var index: integer);
var
  index3: integer;
begin
  if ansilowercase(copy(phpcode, index, sizeofcycle)) = nameofcycle then
  begin
    while (copy(phpcode, index, const_number1) <> const_theendofoperator) and
      (copy(phpcode, index, const_number1) <> const_thestartofprogrammbody) do
      inc(index);
    if copy(phpcode, index, const_number1) = const_thestartofprogrammbody then
    begin
      inc(index3);
    end;
    while index3 <> const_number0 do
    begin
      inc(index);
      if (copy(phpcode, index, const_number1) = const_thestartofprogrammbody)
      then
        inc(index3);
      if (copy(phpcode, index, const_number1) = const_theendofprogrammbody) then
        dec(index3);
    end;
  end;
end;

function findinlistofvariables(thevariables, thefirstvariables
  : Typelistofvariables; the_variables: string): boolean;
begin
  thevariables := thefirstvariables;
  if thevariables^.next <> nil then
    while (thevariables^.next <> nil) and
      (thevariables^.thevariables <> the_variables) do
      thevariables := thevariables^.next;
  if (thevariables = nil) or (thevariables^.thevariables <> the_variables) then
    result := true;
end;

procedure addtolistofvariables(var thevariables: Typelistofvariables;
  the_variables: string);
begin
  new(thevariables^.next);
  thevariables := thevariables^.next;
  thevariables.thevariables := the_variables;
  thevariables^.next := nil;
end;

function findinlistofsubroutinevariables(thevariables, thefirstvariables
  : Typelistofsubroutinsvariables; the_variables: string): boolean;
begin
  thevariables := thefirstvariables;
  if thevariables <> nil then
    while (thevariables <> nil) and
      (thevariables^.thevariables <> the_variables) do
      thevariables := thevariables^.next;
  if (thevariables = nil) or (thevariables^.thevariables <> the_variables) then
    result := true;
end;

procedure addtolistofsubroutinevariables(var thevariables
  : Typelistofsubroutinsvariables; the_variables: string);
begin
  new(thevariables^.next);
  thevariables := thevariables^.next;
  thevariables.thevariables := the_variables;
  thevariables^.next := nil;
end;

procedure skipthesubroutine(phpcode: string; nameofsubroutine: string;
  sizeofsubroutine: integer; var index: integer; setofsymbols: Typesetofchar;
  var index4, index5: integer);
var
  index3, index2: integer;
begin
  if ansilowercase(copy(phpcode, index, sizeofsubroutine)) = nameofsubroutine
  then
  begin
    inc(index4);
    while (copy(phpcode, index, const_number1) <> const_theendofoperator) and
      (copy(phpcode, index, const_number1) <> const_thestartofprogrammbody) do
      inc(index);
    if copy(phpcode, index, const_number1) = const_thestartofprogrammbody then
    begin
      inc(index3);
    end;
    while index3 <> const_number0 do
    begin
      inc(index);
      if ansilowercase(copy(phpcode, index, const_number6)) = const_theglobal
      then
      begin
        index2 := index + const_number5;
        while copy(phpcode, index2, const_number1) <> const_theendofoperator do
        begin
          if copy(phpcode, index2, const_number1) = const_thedollar then
          begin
            index := index2;
            while not(phpcode[index2] in setofsymbols) do
              inc(index2);
            if firstofsubroutinevariables = nil then
            begin
              new(subroutinevariables);
              subroutinevariables^.thevariables :=
                copy(phpcode, index, index2 - index);
              subroutinevariables^.next := nil;
              firstofsubroutinevariables := subroutinevariables;
            end
            else if findinlistofsubroutinevariables(subroutinevariables,
              firstofsubroutinevariables, copy(phpcode, index, index2 - index))
            then
              addtolistofsubroutinevariables(subroutinevariables,
                copy(phpcode, index, index2 - index));
            index := index2 - const_number1;
          end
          else
            inc(index2);
        end;
      end;
      if copy(phpcode, index, const_number1) = const_thedollar then
      begin
        index2 := index;
        while not(phpcode[index2] in setofsymbols) do
          inc(index2);
        if not(findinlistofsubroutinevariables(subroutinevariables,
          firstofsubroutinevariables, copy(phpcode, index, index2 - index)))
        then
          inc(index5);
        index := index2;
      end;
      if (copy(phpcode, index, const_number1) = const_thestartofprogrammbody)
      then
        inc(index3);
      if (copy(phpcode, index, const_number1) = const_theendofprogrammbody) then
        dec(index3);
    end;
  end;
end;

procedure writetowindowsforcode(text: string; winforcode: TMemo);

var
  index1, index2: integer;
  flag: boolean;
  textfromcode: string;
begin
  index2 := const_number1;
  index1 := const_number1;
  flag := true;
  winforcode.text := const_thetextforwindowsforcode;
  while flag do
  begin
    textfromcode := copy(text, index1, const_number6);
    while (textfromcode <> const_theendofline) and
      (index1 <= length(text) - const_number5) do
    begin
      inc(index1);
      textfromcode := copy(text, index1, const_number6);
    end;
    if index1 <= length(text) then
      winforcode.lines.Add(copy(text, index2, index1 - index2))
    else
      flag := false;
    index2 := index1 + const_number6;
    index1 := index2;
  end;
end;

procedure Tmetrick.butforopenfileClick(Sender: TObject);
var
  linefromcode: string;
begin
  winforcode.text := const_thenull;
  linefromcode := const_thenull;
  phpcode := const_thenull;
  if OpenDialog1.execute then
    waytofile := OpenDialog1.FileName;
  if waytofile <> const_thenull then
  begin
    assignfile(fileofphpcode, waytofile);
    reset(fileofphpcode);
    while not(eof(fileofphpcode)) do
    begin
      readln(fileofphpcode, linefromcode);
      phpcode := phpcode + linefromcode + const_theendofline;
      if winforcode.text = '' then
        winforcode.text := linefromcode + const_theendofline
      else
        winforcode.lines.Add(linefromcode + const_theendofline);
    end;
    closefile(fileofphpcode);
    winforcode.ReadOnly := false;
  end
  else
    showmessage('Choose the file for metricks calculation');

end;

procedure Tmetrick.ChangethecodeClick(Sender: TObject);
begin
  phpcode := winforcode.text;
end;

procedure Tmetrick.FormCreate(Sender: TObject);
begin
  waytofile := const_thenull;
  winforcode.text := const_thenull;
end;

procedure Tmetrick.startClick(Sender: TObject);
var
  linefromcode, linefromcode2, textfromphpcode, fivesymbolsfromcode: string;
  index, index2, index3, index4, index5, index6, numoflines,
    lengthofrubbish: integer;
  flag: boolean;
begin
  new(thefirstvariables);
  thefirstvariables := nil;
  new(thevariables);
  thevariables := nil;
  winforcode.text := const_thenull;
  index := const_number1;
  index4 := const_number0;
  index5 := const_number0;
  index6 := const_number0;
  index := const_number1;
  textfromphpcode := copy(phpcode, index, const_number6);
  fivesymbolsfromcode := copy(phpcode, index, const_number5);
  while ((textfromphpcode <> const_phpwithspace) and
    (index <= (length(phpcode) - const_number5))) and
    ((fivesymbolsfromcode <> const_php) or (copy(phpcode, index + const_number5,
    const_number6) <> const_theendofline)) do
  begin
    inc(index);
    textfromphpcode := copy(phpcode, index, const_number6);
    fivesymbolsfromcode := copy(phpcode, index, const_number5);
  end;
  if (textfromphpcode = const_phpwithspace) or
    ((fivesymbolsfromcode = const_php) and (copy(phpcode, index + const_number5,
    const_number6) = const_theendofline)) then
  begin
    index2 := const_number1;
    delete(phpcode, const_number1, index - const_number1);
    index := const_number1;
    while index <= (length(phpcode) - const_number7) do
    begin
      linefromcode := copy(phpcode, index, const_number2);
      while ((linefromcode <> const_thestartofcomments) and
        ((length(phpcode) - const_number1) >= index)) do
      begin
        inc(index);
        linefromcode := copy(phpcode, index, const_number2);
      end;
      index2 := index + const_number2;
      if ((linefromcode = const_thestartofcomments) and
        ((length(phpcode) - const_number1) >= index)) then
      begin
        linefromcode2 := copy(phpcode, index2, const_number2);
        while ((linefromcode2 <> const_theendofcomments) and
          ((length(phpcode) - const_number1) >= index2)) do
        begin
          inc(index2);
          linefromcode2 := copy(phpcode, index2, const_number2);
        end;
        delete(phpcode, index, index2 - index + const_number2);
      end;
    end;
    index := const_number1;
    index2 := const_number1;
    while index <= (length(phpcode) - const_number7) do
    begin
      linefromcode := copy(phpcode, index, const_number2);
      if linefromcode = const_thelineofcomments then
      begin
        index2 := index;
        linefromcode := copy(phpcode, index2, const_number6);
        while linefromcode <> const_theendofline do
        begin
          inc(index2);
          linefromcode := copy(phpcode, index2, const_number6);
        end;
        delete(phpcode, index, index2 - index);
        index2 := index;
        dec(index2);
        while (copy(phpcode, index2, const_number1) = const_thespace) or
          (copy(phpcode, index2 - const_number5, const_number6) <>
          const_theendofline) do
          dec(index2);
        if (copy(phpcode, index2 - const_number5, const_number6)
          = const_theendofline) then
          delete(phpcode, index2, index - index2 + const_number5);
      end;
      if copy(phpcode, index, const_number2) <> const_thelineofcomments then
        inc(index);
    end;
    index := const_number1;
    index2 := const_number1;
    flag := false;;
    while index <= (length(phpcode) - const_number7) do
    begin
      linefromcode := copy(phpcode, index, const_number1);
      if linefromcode = const_thedoublequote then
      begin
        inc(index);
        index2 := index;
        linefromcode := copy(phpcode, index2, const_number1);
        while (linefromcode <> const_thedoublequote) and
          (index2 <= length(phpcode)) do
        begin
          inc(index2);
          linefromcode := copy(phpcode, index2, const_number1);
        end;

        delete(phpcode, index, index2 - index);
      end;
      inc(index);
    end;
    index := const_number1;
    index2 := const_number1;
    while index <= (length(phpcode) - const_number7) do
    begin
      if ansilowercase(copy(phpcode, index, const_number8)) = const_theglobals
      then
      begin
        delete(phpcode, index, const_number8);
        flag := true;
        while copy(phpcode, index, const_number1) <> const_thequote do
          inc(index);
      end;
      linefromcode := copy(phpcode, index, const_number1);
      if linefromcode = const_thequote then
      begin
        inc(index);
        index2 := index;
        while (copy(phpcode, index2, const_number1) <> const_thequote) and
          (index2 <= length(phpcode)) do
          inc(index2);
        if flag then
        begin
          if firstofsubroutinevariables = nil then
          begin
            new(subroutinevariables);
            subroutinevariables^.thevariables := const_thedollar +
              copy(phpcode, index, index2 - index);
            subroutinevariables^.next := nil;
            firstofsubroutinevariables := subroutinevariables;
          end
          else if findinlistofsubroutinevariables(subroutinevariables,
            firstofsubroutinevariables, copy(phpcode, index, index2 - index))
          then
            addtolistofsubroutinevariables(subroutinevariables,
              const_thedollar + copy(phpcode, index, index2 - index));
          while copy(phpcode, index2, const_number6) <> const_theendofline do
            inc(index2);
          flag := false;
        end;
        delete(phpcode, index, index2 - index);
      end;
      inc(index);
    end;
    writetowindowsforcode(phpcode, winforcode);
    index := const_number1;
    index2 := index;
    while index <= (length(phpcode) - const_number6) do
    begin
      index3 := const_number0;
      skipthesubroutine(phpcode, const_theprocedure, const_number9, index,
        setofsymbols, index4, index5);
      skipthesubroutine(phpcode, const_thefunction, const_number8, index,
        setofsymbols, index4, index5);
      skipthealgorithm(phpcode, const_thefor, const_number3, index);
      skipthealgorithm(phpcode, const_theif, const_number2, index);
      skipthealgorithm(phpcode, const_theecho, const_number4, index);
      skipthealgorithm(phpcode, const_theclass, const_number5, index);
      if copy(phpcode, index, const_number1) = const_thedollar then
      begin
        index2 := index;
        while not(phpcode[index2] in setofsymbols) do
          inc(index2);
        if thefirstvariables = nil then
        begin
          new(thevariables);
          thevariables^.thevariables := copy(phpcode, index, index2 - index);
          thevariables^.next := nil;
          thefirstvariables := thevariables;
          inc(index6);
        end
        else
        begin
          if findinlistofvariables(thevariables, thefirstvariables,
            copy(phpcode, index, index2 - index)) then
          begin
            addtolistofvariables(thevariables,
              copy(phpcode, index, index2 - index));
            inc(index6);
          end;
        end;
        index := index2;
      end
      else
        inc(index);
    end;
    thevariables := thefirstvariables;
    winforcode.text := 'The vars in main body of programm:';
    while thevariables <> nil do
    begin
      winforcode.lines.Add(thevariables^.thevariables);
      thevariables := thevariables^.next;
    end;
    winforcode.lines.Add('The global vars in subroutines are:');
    subroutinevariables := firstofsubroutinevariables;
    while subroutinevariables <> nil do
    begin
      winforcode.lines.Add(subroutinevariables^.thevariables);
      subroutinevariables := subroutinevariables^.next;
    end;
    winforcode.lines.Add('The number of vars in main body of programm is:');
    winforcode.lines.Add(inttostr(index6));
    winforcode.lines.Add('The number of subroutins is:');
    winforcode.lines.Add(inttostr(index4));
    winforcode.lines.Add('The number of applies to global vars is :');
    winforcode.lines.Add(inttostr(index5));
    winforcode.lines.Add
      ('The result of metricks of applies to global vars is:');
    if index4 = const_number0 then
      showmessage('The subroutines not founded')
    else if index6 = const_number0 then
      showmessage('The vars in main body of programm not founded')
    else
      winforcode.lines.Add(floattostr(index5 / (index4 * index6)));
  end
  else
  begin
    showmessage('PHP code did not found');
    exit;
  end;
end;

end.
