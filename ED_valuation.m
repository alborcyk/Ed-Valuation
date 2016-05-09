function ED_valuation()
% Rate all images, choose top X picsn
% fMRI commented out.

global wRect w XCENTER rects mids COLORS KEYS 

prompt={'SUBJECT ID' 'Session' 'MRI (1 = Y, 0 = N)'};
defAns={'4444' '1' '0'};

prompt2={'Binges' 'Sick' 'Laxatives/diruretics' 'Diet pills' 'Fasting' 'Exercise'};
behaviors={'0' '0' '0' '0' '0' '0'};


answer=inputdlg(prompt,'Please input subject info',1,defAns);

negbehav= inputdlg(prompt2,'Please input behaviors',1,behaviors);

ID=str2double(answer{1});
SESS=str2double(answer{2});
MRI = str2double(answer{3});

binge=strdouble(negbehav{1});
sick=str2double(negbehav{2});
lax=str2double(negbehav{3});
dietpills=str2double(negbehav{4});
fast=str2double(negbehav{5});
exercise=str2double(negbehav{6});

COLORS = struct;
COLORS.BLACK = [0 0 0];
COLORS.WHITE = [255 255 255];
COLORS.RED = [255 0 0];
COLORS.BLUE = [0 0 255];
COLORS.GREEN = [0 255 0];
COLORS.YELLOW = [255 255 0];
COLORS.rect = COLORS.GREEN;

KbName('UnifyKeyNames');

KEYS = struct;
% KEYS.LEFT=KbName('leftarrow');
% KEYS.RIGHT=KbName('rightarrow');
KEYS.ONE= KbName('1!');
KEYS.TWO= KbName('2@');
KEYS.THREE= KbName('3#');
KEYS.FOUR= KbName('4$');
KEYS.FIVE= KbName('5%');
KEYS.SIX= KbName('6^');
KEYS.SEVEN= KbName('7&');
KEYS.EIGHT= KbName('8*');
KEYS.NINE= KbName('9(');
% KEYS.TEN= KbName('0)');
rangetest = cell2mat(struct2cell(KEYS));
KEYS.all = min(rangetest):max(rangetest);
% KEYS.trigger = KbName('''"');

%%
[mfilesdir,~,~] = fileparts(which('ED_valuation.m'));
outputdir = [mfilesdir '/Results'];

%Load in sentence strings
scenarios = importdata('scenarios.txt');
neutrals = importdata('neutral_behav.txt');

if (binge==1);
    bingebehav = importdata('binge.txt');
end
    
if (sick==1);
    sickbehav = importdata('sick.txt');
end

if (lax==1);
    laxbehav = importdata('lax.txt');
end

if (dietpills==1);
    dietpillbehav = importdata('dietpills.txt');
end

if (fast==1);
    fastbehav = importdata('fast.txt');
end

if (exercise==1);
    exercisebehav = importdata('exercise.txt');
end


%%
commandwindow;

%%
%change this to 0 to fill whole screen
DEBUG=0;

%set up the screen and dimensions

%list all the screens, then just pick the last one in the list (if you have
%only 1 monitor, then it just chooses that one)
Screen('Preference', 'SkipSyncTests', 1);

screenNumber=max(Screen('Screens'));

if DEBUG==1;
    %create a rect for the screen
    winRect=[0 0 640 480];
    %establish the center points
    XCENTER=320;
    YCENTER=240;
else
    %change screen resolution
%     Screen('Resolution',0,1024,768,[],32);
    
    %this gives the x and y dimensions of our screen, in pixels.
    [swidth, sheight] = Screen('WindowSize', screenNumber);
    XCENTER=fix(swidth/2);
    YCENTER=fix(sheight/2);
    %when you leave winRect blank, it just fills the whole screen
    winRect=[];
end

%open a window on that monitor. 32 refers to 32 bit color depth (millions of
%colors), winRect will either be a 1024x768 box, or the whole screen. The
%function returns a window "w", and a rect that represents the whole
%screen. 
[w, wRect]=Screen('OpenWindow', screenNumber, 0,winRect,32,2);

%%
%you can set the font sizes and styles here
Screen('TextFont', w, 'Arial');
%Screen('TextStyle', w, 1);
Screen('TextSize',w,35);

%% Dat Grid
[rects,mids] = DrawRectsGrid();
verbage = 'How much do you want to...';
verbage2 = 'Which do you want to do more?';

%% Intro

DrawFormattedText(w,'You are going to imagine yourself in scenarios, then rate how likely you are to engage in a behavior.\n\n You will use a scale from 1 to 9, where 1 is "Not at all likely" and 9 is "Extremely likely."\n\nPress any key to continue.','center','center',COLORS.WHITE,50,[],[],1.5);
Screen('Flip',w);
KbWait([],3);

DrawFormattedText(w,'You will use the numbers along the top of the keyboard to select your rating.\n\nPress any key to continue.','center','center',COLORS.WHITE,50,[],[],1.5);
Screen('Flip',w);
KbWait([],3);

%% fMRI synch w/trigger
% if fmri == 1;
%     DrawFormattedText(w,'Synching with fMRI: Waiting for trigger','center','center',COLORS.WHITE);
%     Screen('Flip',w);
%     
%     scan_sec = KbTriggerWait(KEYS.trigger,xkeys);
% else
%     scan_sec = GetSecs();
% end

%%
DrawFormattedText(w,'The rating task will now begin.\n\nPress any key to continue.','center','center',COLORS.WHITE,50,[],[],1.5);
Screen('Flip',w);
KbWait([],3);
WaitSecs(1);

num_blocks = 2;
n_stim = 20;
n_ed = length(eds);
n_neutral = length(neutrals);

for block = 1:num_blocks
    stim_index = randperm(n_stim);
    ed_index = randperm(n_ed);
    neutral_index = randperm(n_neutral);

    %These are catches to make sure that there are at least as many behaviors
    %as there are scenarios. 
    while length(ed_index)<length(stim_index)
        ed_index = [ed_index, randperm(n_ed)];
    end

    while length(neutral_index)<length(stim_index)
        neutral_index = [neutral_index, randperm(n_neutral)];
    end
    
    for trial = 1:n_stim
        trialN = (block-1)+trial;
        scenario = scenarios{stim_index(trial)};
        ed = eds{ed_index(trial)};
        neutral = neutrals{neutral_index(trial)};
        joined = strcat(ed,{'                                '},neutral);
        join = joined{1};   %Embarrassing. But functional. 

        DrawFormattedText(w,'+','center','center',COLORS.WHITE);
        Screen('Flip',w);
        WaitSecs(2);

        %Display scenario
        DrawFormattedText(w,scenario,'center','center',COLORS.WHITE,50,[],[],1.5);
        Screen('Flip',w);
        WaitSecs(2);

        %Probe ED behavior
        drawRatings([],w);
        DrawFormattedText(w,verbage,'center','center',COLORS.WHITE);
        DrawFormattedText(w,ed,'center',(wRect(4)*.75),COLORS.WHITE);
        Screen('Flip',w);

        FlushEvents();
        while 1
            [keyisdown, ed_rt, keycode] = KbCheck();
            if (keyisdown==1 && any(keycode(KEYS.all)))
    %                     PicRating_U4ED(xy).RT = rt - rateon;

                ed_rating = KbName(find(keycode));
                ed_rating = str2double(ed_rating(1));

    %                 Screen('DrawTexture',w,tpx);
                drawRatings(keycode,w);
                DrawFormattedText(w,verbage,'center','center',COLORS.WHITE);
                DrawFormattedText(w,ed,'center',(wRect(4)*.75),COLORS.WHITE);
                Screen('Flip',w);
                WaitSecs(.25);
                break;
            end
        end

        %Record response here.
        if ed_rating == 0; %Zero key is used for 10. Thus check and correct for when they press 0.
            ed_rating = 10;
        end

        ed_rating

        DrawFormattedText(w,'+','center','center',COLORS.WHITE);
        Screen('Flip',w);
        WaitSecs(2);

       Screen('Flip',w);
       FlushEvents();
       WaitSecs(.25);


       %Probe neutral behavior
       drawRatings([],w);
       DrawFormattedText(w,verbage,'center','center',COLORS.WHITE);
       DrawFormattedText(w,neutral,'center',(wRect(4)*.75),COLORS.WHITE);
       Screen('Flip',w);

       FlushEvents();
        while 1
            [keyisdown, n_rt, keycode] = KbCheck();
            if (keyisdown==1 && any(keycode(KEYS.all)))
    %                     PicRating_U4ED(xy).RT = rt - rateon;

                n_rating = KbName(find(keycode));
                n_rating = str2double(n_rating(1));

    %                 Screen('DrawTexture',w,tpx);
                drawRatings(keycode,w);
                DrawFormattedText(w,verbage,'center','center',COLORS.WHITE);
                DrawFormattedText(w,neutral,'center',(wRect(4)*.75),COLORS.WHITE);
                Screen('Flip',w);
                WaitSecs(.25);
                break;
            end
        end

        if n_rating == 0; %Zero key is used for 10. Thus check and correct for when they press 0.
            n_rating = 10;
        end

        DrawFormattedText(w,'+','center','center',COLORS.WHITE);
        Screen('Flip',w);
        WaitSecs(2);

        %ED vs neutral beahvior valuation
        drawRatings([],w);
        DrawFormattedText(w,verbage2,'center','center',COLORS.WHITE);
        DrawFormattedText(w,join,'center',(wRect(4)*.75),COLORS.WHITE);
        Screen('Flip',w);

        FlushEvents();
        while 1
            [keyisdown, v_rt, keycode] = KbCheck();
            if (keyisdown==1 && any(keycode(KEYS.all)))

                v_rating = KbName(find(keycode));
                v_rating = str2double(v_rating(1));

                drawRatings(keycode,w);
                DrawFormattedText(w,verbage2,'center','center',COLORS.WHITE);
                DrawFormattedText(w,join,'center',(wRect(4)*.75),COLORS.WHITE);
                Screen('Flip',w);
                WaitSecs(.25);
                break;
            end
        end

        DrawFormattedText(w,'+','center','center',COLORS.WHITE);
        Screen('Flip',w);
        WaitSecs(2);


        data{trial,1}=trialN;
        data{trial,2}=ed;
        data{trial,3}=ed_rating;
        data{trial,4}=ed_rt;
        data{trial,5}=neutral;
        data{trial,6}=n_rating;
        data{trial,7}=n_rt;
        data{trial,8}=v_rating;
        data{trial,9}=v_rt;


    end
        %     %Take a break every 20 pics.
        Screen('Flip',w);
        DrawFormattedText(w,'Press any key when you are ready to continue','center','center',COLORS.WHITE);
        Screen('Flip',w);
        KbWait([],3);
end
filename = ['ED_valuation' '_sub' answer{1} '.mat'];
cd(outputdir);
save(filename,'data');

Screen('Flip',w);
WaitSecs(.5);


%% Sort & Save List of Foods.


DrawFormattedText(w,'That concludes this task. The assessor will be with you soon.','center','center',COLORS.WHITE);
Screen('Flip', w);
WaitSecs(4);

sca

end


function [ rects,mids ] = DrawRectsGrid(varargin)
%DrawRectGrid:  Builds a grid of squares with gaps in between.

global wRect XCENTER

%Size of image will depend on screen size. First, an area approximately 80%
%of screen is determined. Then, images are 1/4th the side of that square
%(minus the 3 x the gap between images.

num_rects = 9;                 %How many rects?
xlen = wRect(3)*.8;           %Make area covering about 90% of vertical dimension of screen.
gap = 10;                       %Gap size between each rect
square_side = fix((xlen - (num_rects-1)*gap)/num_rects); %Size of rect depends on size of screen.

squart_x = XCENTER-(xlen/2);
squart_y = wRect(4)*.8;         %Rects start @~80% down screen.

rects = zeros(4,num_rects);

% for row = 1:DIMS.grid_row;
    for col = 1:num_rects;
%         currr = ((row-1)*DIMS.grid_col)+col;
        rects(1,col)= squart_x + (col-1)*(square_side+gap);
        rects(2,col)= squart_y;
        rects(3,col)= squart_x + (col-1)*(square_side+gap)+square_side;
        rects(4,col)= squart_y + square_side;
    end
% end
mids = [rects(1,:)+square_side/2; rects(2,:)+square_side/2+5];

end

%%
function drawRatings(varargin)

global w KEYS COLORS rects mids

colors=repmat(COLORS.WHITE',1,9);
% rects=horzcat(allRects.rate1rect',allRects.rate2rect',allRects.rate3rect',allRects.rate4rect');

%Needs to feed in "code" from KbCheck, to show which key was chosen.
if nargin >= 1 && ~isempty(varargin{1})
    response=varargin{1};
    
    key=find(response);
    if length(key)>1
        key=key(1);
    end;
    
    switch key
        
        case {KEYS.ONE}
            choice=1;
        case {KEYS.TWO}
            choice=2;
        case {KEYS.THREE}
            choice=3;
        case {KEYS.FOUR}
            choice=4;
        case {KEYS.FIVE}
            choice=5;
        case {KEYS.SIX}
            choice=6;
        case {KEYS.SEVEN}
            choice=7;
        case {KEYS.EIGHT}
            choice=8;
        case {KEYS.NINE}
            choice=9;
%         case {KEYS.TEN}
%             choice = 10;
    end
    
    if exist('choice','var')
        
        
        colors(:,choice)=COLORS.GREEN';
        
    end
end

if nargin>=2
    
    window=varargin{2};
    
else
    
    window=w;
    
end
   

Screen('TextFont', window, 'Arial');
Screen('TextStyle', window, 1);
oldSize = Screen('TextSize',window,35);

% Screen('TextFont', w2, 'Arial');
% Screen('TextStyle', w2, 1)
% Screen('TextSize',w2,60);



%draw all the squares
Screen('FrameRect',window,colors,rects,1);


% Screen('FrameRect',w2,colors,rects,1);


%draw the text (1-10)
for n = 1:9;
    numnum = sprintf('%d',n);
    CenterTextOnPoint(window,numnum,mids(1,n),mids(2,n),COLORS.WHITE);
end


Screen('TextSize',window,oldSize);

end


%%
function [nx, ny, textbounds] = CenterTextOnPoint(win, tstring, sx, sy,color)
% [nx, ny, textbounds] = DrawFormattedText(win, tstring [, sx][, sy][, color][, wrapat][, flipHorizontal][, flipVertical][, vSpacing][, righttoleft])
%
% 

numlines=1;

if nargin < 1 || isempty(win)
    error('CenterTextOnPoint: Windowhandle missing!');
end

if nargin < 2 || isempty(tstring)
    % Empty text string -> Nothing to do.
    return;
end

% Store data class of input string for later use in re-cast ops:
stringclass = class(tstring);

% Default x start position is left border of window:
if isempty(sx)
    sx=0;
end

% if ischar(sx) && strcmpi(sx, 'center')
%     xcenter=1;
%     sx=0;
% else
%     xcenter=0;
% end

xcenter=0;

% No text wrapping by default:
% if nargin < 6 || isempty(wrapat)
    wrapat = 0;
% end

% No horizontal mirroring by default:
% if nargin < 7 || isempty(flipHorizontal)
    flipHorizontal = 0;
% end

% No vertical mirroring by default:
% if nargin < 8 || isempty(flipVertical)
    flipVertical = 0;
% end

% No vertical mirroring by default:
% if nargin < 9 || isempty(vSpacing)
    vSpacing = 1.5;
% end

% if nargin < 10 || isempty(righttoleft)
    righttoleft = 0;
% end

% Convert all conventional linefeeds into C-style newlines:
newlinepos = strfind(char(tstring), '\n');

% If '\n' is already encoded as a char(10) as in Octave, then
% there's no need for replacemet.
if char(10) == '\n' %#ok<STCMP>
   newlinepos = [];
end

% Need different encoding for repchar that matches class of input tstring:
if isa(tstring, 'double')
    repchar = 10;
elseif isa(tstring, 'uint8')
    repchar = uint8(10);    
else
    repchar = char(10);
end

while ~isempty(newlinepos)
    % Replace first occurence of '\n' by ASCII or double code 10 aka 'repchar':
    tstring = [ tstring(1:min(newlinepos)-1) repchar tstring(min(newlinepos)+2:end)];
    % Search next occurence of linefeed (if any) in new expanded string:
    newlinepos = strfind(char(tstring), '\n');
end

% % Text wrapping requested?
% if wrapat > 0
%     % Call WrapString to create a broken up version of the input string
%     % that is wrapped around column 'wrapat'
%     tstring = WrapString(tstring, wrapat);
% end

% Query textsize for implementation of linefeeds:
theight = Screen('TextSize', win) * vSpacing;

% Default y start position is top of window:
if isempty(sy)
    sy=0;
end

winRect = Screen('Rect', win);
winHeight = RectHeight(winRect);

% if ischar(sy) && strcmpi(sy, 'center')
    % Compute vertical centering:
    
    % Compute height of text box:
%     numlines = length(strfind(char(tstring), char(10))) + 1;
    %bbox = SetRect(0,0,1,numlines * theight);
    bbox = SetRect(0,0,1,theight);
    
    
    textRect=CenterRectOnPoint(bbox,sx,sy);
    % Center box in window:
    [rect,dh,dv] = CenterRect(bbox, textRect);

    % Initialize vertical start position sy with vertical offset of
    % centered text box:
    sy = dv;
% end

% Keep current text color if noone provided:
if nargin < 5 || isempty(color)
    color = [];
end

% Init cursor position:
xp = sx;
yp = sy;

minx = inf;
miny = inf;
maxx = 0;
maxy = 0;

% Is the OpenGL userspace context for this 'windowPtr' active, as required?
[previouswin, IsOpenGLRendering] = Screen('GetOpenGLDrawMode');

% OpenGL rendering for this window active?
if IsOpenGLRendering
    % Yes. We need to disable OpenGL mode for that other window and
    % switch to our window:
    Screen('EndOpenGL', win);
end

% Disable culling/clipping if bounding box is requested as 3rd return
% % argument, or if forcefully disabled. Unless clipping is forcefully
% % enabled.
% disableClip = (ptb_drawformattedtext_disableClipping ~= -1) && ...
%               ((ptb_drawformattedtext_disableClipping > 0) || (nargout >= 3));
% 

disableClip=1;

% Parse string, break it into substrings at line-feeds:
while ~isempty(tstring)
    % Find next substring to process:
    crpositions = strfind(char(tstring), char(10));
    if ~isempty(crpositions)
        curstring = tstring(1:min(crpositions)-1);
        tstring = tstring(min(crpositions)+1:end);
        dolinefeed = 1;
    else
        curstring = tstring;
        tstring =[];
        dolinefeed = 0;
    end

    if IsOSX
        % On OS/X, we enforce a line-break if the unwrapped/unbroken text
        % would exceed 250 characters. The ATSU text renderer of OS/X can't
        % handle more than 250 characters.
        if size(curstring, 2) > 250
            tstring = [curstring(251:end) tstring]; %#ok<AGROW>
            curstring = curstring(1:250);
            dolinefeed = 1;
        end
    end
    
    if IsWin
        % On Windows, a single ampersand & is translated into a control
        % character to enable underlined text. To avoid this and actually
        % draw & symbols in text as & symbols in text, we need to store
        % them as two && symbols. -> Replace all single & by &&.
        if isa(curstring, 'char')
            % Only works with char-acters, not doubles, so we can't do this
            % when string is represented as double-encoded Unicode:
            curstring = strrep(curstring, '&', '&&');
        end
    end
    
    % tstring contains the remainder of the input string to process in next
    % iteration, curstring is the string we need to draw now.

    % Perform crude clipping against upper and lower window borders for
    % this text snippet. If it is clearly outside the window and would get
    % clipped away by the renderer anyway, we can safe ourselves the
    % trouble of processing it:
    if disableClip || ((yp + theight >= 0) && (yp - theight <= winHeight))
        % Inside crude clipping area. Need to draw.
        noclip = 1;
    else
        % Skip this text line draw call, as it would be clipped away
        % anyway.
        noclip = 0;
        dolinefeed = 1;
    end
    
    % Any string to draw?
    if ~isempty(curstring) && noclip
        % Cast curstring back to the class of the original input string, to
        % make sure special unicode encoding (e.g., double()'s) does not
        % get lost for actual drawing:
        curstring = cast(curstring, stringclass);
        
        % Need bounding box?
%         if xcenter || flipHorizontal || flipVertical
            % Compute text bounding box for this substring:
            bbox=Screen('TextBounds', win, curstring, [], [], [], righttoleft);
%         end
        
        % Horizontally centered output required?
%         if xcenter
            % Yes. Compute dh, dv position offsets to center it in the center of window.
%             [rect,dh] = CenterRect(bbox, winRect);
            [rect,dh] = CenterRect(bbox, textRect);
            % Set drawing cursor to horizontal x offset:
            xp = dh;
%         end
            
%         if flipHorizontal || flipVertical
%             textbox = OffsetRect(bbox, xp, yp);
%             [xc, yc] = RectCenter(textbox);
% 
%             % Make a backup copy of the current transformation matrix for later
%             % use/restoration of default state:
%             Screen('glPushMatrix', win);
% 
%             % Translate origin into the geometric center of text:
%             Screen('glTranslate', win, xc, yc, 0);
% 
%             % Apple a scaling transform which flips the direction of x-Axis,
%             % thereby mirroring the drawn text horizontally:
%             if flipVertical
%                 Screen('glScale', win, 1, -1, 1);
%             end
%             
%             if flipHorizontal
%                 Screen('glScale', win, -1, 1, 1);
%             end
% 
%             % We need to undo the translations...
%             Screen('glTranslate', win, -xc, -yc, 0);
%             [nx ny] = Screen('DrawText', win, curstring, xp, yp, color, [], [], righttoleft);
%             Screen('glPopMatrix', win);
%         else
            [nx ny] = Screen('DrawText', win, curstring, xp, yp, color, [], [], righttoleft);
%         end
    else
        % This is an empty substring (pure linefeed). Just update cursor
        % position:
        nx = xp;
        ny = yp;
    end

    % Update bounding box:
    minx = min([minx , xp, nx]);
    maxx = max([maxx , xp, nx]);
    miny = min([miny , yp, ny]);
    maxy = max([maxy , yp, ny]);

    % Linefeed to do?
    if dolinefeed
        % Update text drawing cursor to perform carriage return:
        if xcenter==0
            xp = sx;
        end
        yp = ny + theight;
    else
        % Keep drawing cursor where it is supposed to be:
        xp = nx;
        yp = ny;
    end
    % Done with substring, parse next substring.
end

% Add one line height:
maxy = maxy + theight;

% Create final bounding box:
textbounds = SetRect(minx, miny, maxx, maxy);

% Create new cursor position. The cursor is positioned to allow
% to continue to print text directly after the drawn text.
% Basically behaves like printf or fprintf formatting.
nx = xp;
ny = yp;

% Our work is done. If a different window than our target window was
% active, we'll switch back to that window and its state:
if previouswin > 0
    if previouswin ~= win
        % Different window was active before our invocation:

        % Was that window in 3D mode, i.e., OpenGL rendering for that window was active?
        if IsOpenGLRendering
            % Yes. We need to switch that window back into 3D OpenGL mode:
            Screen('BeginOpenGL', previouswin);
        else
            % No. We just perform a dummy call that will switch back to that
            % window:
            Screen('GetWindowInfo', previouswin);
        end
    else
        % Our window was active beforehand.
        if IsOpenGLRendering
            % Was in 3D mode. We need to switch back to 3D:
            Screen('BeginOpenGL', previouswin);
        end
    end
end

return;
end

