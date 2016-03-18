
% Copyright (C) 1993-2015, by Peter I. Corke
%
% This file is part of The Robotics Toolbox for MATLAB (RTB).
% 
% RTB is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% RTB is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Leser General Public License
% along with RTB.  If not, see <http://www.gnu.org/licenses/>.
%
% http://www.petercorke.com
function varargout = tripleangle(varargin)
% TRIPLEANGLE Visualize triple angle rotations
%
% TRIPLEANGLE, by itself, displays a simple GUI with three angle sliders
% and a set of axes showing three coordinate frames.  The frames correspond
% to rotation after the first angle (red), the first and second angles (green)
% and all three angles (blue).
%
% TRIPLEANGLE(OPTIONS) as above but with options to select the rotation axes.
%
% Options::
% 'rpy'     Rotation about axes x, y, z (default)
% 'euler'   Rotation about axes z, y, z
% 'ABC'     Rotation about axes A, B, C where A,B,C are each one of x,y or z.
%
% Other options relevant to TRPLOT can be appended.
%
% Notes::
% - All angles are displayed in units of degrees.
%
% See also trplot.



% Last Modified by GUIDE v2.5 19-Aug-2015 15:19:48


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tripleangle_OpeningFcn, ...
                   'gui_OutputFcn',  @tripleangle_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before tripleang is made visible.
function tripleangle_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tripleang (see VARARGIN)

% Choose default command line output for tripleang
handles.output = hObject;

figure(handles.figure1);


% process options
opt.wait = false;
opt.which = {'rpy', 'euler'};

[opt,args] = tb_optparse(opt, varargin);

if length(args) > 0 && ischar(args{1})
    s = args{1};
    try
        set(handles.popupmenu1, 'Value', strfind('xyz', s(1)));
        set(handles.popupmenu2, 'Value', strfind('xyz', s(2)));
        set(handles.popupmenu3, 'Value', strfind('xyz', s(3)));
        if length(args) > 1
            args = args{2:end};
        else
            args = {};
        end
        opt.which = 'none';
    catch me
        % doesnt match a rotation string, go with 'rpy'
        opt.which = 'rpy';
        
    end
end

% set initial slider to axis mapping
switch opt.which
    case 'rpy'
        set(handles.popupmenu1, 'Value', 3);
        set(handles.popupmenu2, 'Value', 2);
        set(handles.popupmenu3, 'Value', 1);
    case 'euler'
        set(handles.popupmenu1, 'Value', 3);
        set(handles.popupmenu2, 'Value', 2);
        set(handles.popupmenu3, 'Value', 3);
end
                
% draw the axes at null rotation
%handles.h1 = trplot(eye(3,3), 'color', 'r', args{:});


% set the initial value of text fields
set(handles.text1, 'String', sprintf('%.1f', get(handles.slider1, 'Value')));
set(handles.text2, 'String', sprintf('%.1f', get(handles.slider2, 'Value')));
set(handles.text3, 'String', sprintf('%.1f', get(handles.slider3, 'Value')));

% configure the graphics
axis(1.5*[-1 1 -1 1 -1 1]);
daspect([1 1 1]);
light('Position', [0 0 5]);
light('Position', [2 2 1]);
grid on
xlabel('X')
ylabel('Y');
zlabel('Z');

% establish transforms
handles.plane = hgtransform('Tag', 'plane');
handles.ring1 = hgtransform('Tag', 'ring1');
handles.ring2 = hgtransform('Tag', 'ring2');
handles.ring3 = hgtransform('Tag', 'ring3');

%% load the models

% read the plane model
fprintf('reading STL models...');
[V,F] = stlRead( 'spitfire_assy-gear_up.stl' );

% shift origin to wing centre line
V = bsxfun(@plus, V, [0 0 75]);
patch('Faces', F, 'Vertices', V/180, ...
    'FaceColor', 0.8*[1.0000    0.7812    0.4975], 'EdgeAlpha', 0, ...
    'Parent', handles.plane);

%% read the gimbal rings

% inner
fprintf('.');
[V,F] = stlRead( 'gimbal-ring1.stl' );
patch('Faces', F, 'Vertices', V*1, ...
    'FaceColor', 'b', 'EdgeAlpha', 0, ...
    'Parent', handles.ring1);

% middle
fprintf('.');

[V,F] = stlRead( 'gimbal-ring2.stl' );
patch('Faces', F, 'Vertices', V*1.1, ...
    'FaceColor', 'g',  'EdgeAlpha', 0, ...
    'Parent', handles.ring2);

% outer
fprintf('.');

[V,F] = stlRead( 'gimbal-ring3.stl' );
patch('Faces', F, 'Vertices', V*1.1^2, ...
    'FaceColor', 'r', 'EdgeAlpha', 0, ...
    'Parent', handles.ring3);

fprintf('\rSupermarine Spitfire Mk VIII by Ed Morley @GRABCAD\n');
fprintf('Gimbal models by Peter Corke using OpenSCAD\n');

% enable mouse-based 3D rotation
rotate3d on
view(50, 22);

% Update handles structure
guidata(hObject, handles);

% ask for continuous callbacks
addlistener(handles.slider1, 'ContinuousValueChange', ...
    @(obj,event) slider1_Callback(obj, event, handles) );
addlistener(handles.slider2, 'ContinuousValueChange', ...
    @(obj,event) slider2_Callback(obj, event, handles) );
addlistener(handles.slider3, 'ContinuousValueChange', ...
    @(obj,event) slider3_Callback(obj, event, handles) );

update(handles)

% UIWAIT makes tripleang wait for user response (see UIRESUME)
if opt.wait
    uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = tripleangle_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

set(handles.text1, 'String', sprintf('%.1f', get(hObject, 'Value')));
update(handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

set(handles.text2, 'String', sprintf('%.1f', get(hObject, 'Value')));

update(handles);

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

set(handles.text3, 'String', sprintf('%.1f', get(hObject, 'Value')));

update(handles);

% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function update(handles)
    
    % compute the three rotation matrices
    
    R1 = Rx( get(handles.slider1, 'Value'), get(handles.popupmenu1, 'Value'));
    R2 = Rx( get(handles.slider2, 'Value'), get(handles.popupmenu2, 'Value'));
    R3 = Rx( get(handles.slider3, 'Value'), get(handles.popupmenu3, 'Value'));


    % display the three frames
    %trplot(R1*R2*R3, 'handle', handles.h1);
    
    set(handles.ring3, 'Matrix', r2t( R1 * roty(pi/2) ));
    % Ry
    set(handles.ring2, 'Matrix', r2t( R1*R2 * rotz(pi/2) ));
    % Rx
    set(handles.ring1, 'Matrix', r2t( R1*R2*R3 * rotx(pi/2) ));
    
    set(handles.plane, 'Matrix', r2t( R1*R2*R3 * roty(pi/2)*rotz(pi/2) ))

    
function R = Rx(theta, which)
        theta = theta * pi/180;

        switch which
            case 1
                R = rotx(theta);
            case 2
                R = roty(theta);
            case 3
                R = rotz(theta);
        end

    


% --- Executes on button press in pb_RPY.
function pb_RPY_Callback(hObject, eventdata, handles)
% hObject    handle to pb_RPY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.popupmenu1, 'Value', 3);
    set(handles.popupmenu2, 'Value', 2);
    set(handles.popupmenu3, 'Value', 1);

% --- Executes on button press in pb_euler.
function pb_euler_Callback(hObject, eventdata, handles)
% hObject    handle to pb_euler (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.popupmenu1, 'Value', 2);
    set(handles.popupmenu2, 'Value', 3);
    set(handles.popupmenu3, 'Value', 2);


% --- Executes on button press in pb_top.
function pb_top_Callback(hObject, eventdata, handles)
% hObject    handle to pb_top (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    view(90, 90)
    
% --- Executes on button press in pb_side.
function pb_side_Callback(hObject, eventdata, handles)
% hObject    handle to pb_side (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    view(0, 0);

% --- Executes on button press in pb_front.
function pb_front_Callback(hObject, eventdata, handles)
% hObject    handle to pb_front (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    view(90, 0);


% --- Executes on button press in pb_reset.
function pb_reset_Callback(hObject, eventdata, handles)
% hObject    handle to pb_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.slider1, 'Value', 0);
    set(handles.text1, 'String', sprintf('%.1f', 0));

    set(handles.slider2, 'Value', 0);
    set(handles.text2, 'String', sprintf('%.1f', 0));

    set(handles.slider3, 'Value', 0);
    set(handles.text3, 'String', sprintf('%.1f', 0));
    
    update(handles)
    view(50, 22);



% --- Executes on button press in gimbals.
function gimbals_Callback(hObject, eventdata, handles)
% hObject    handle to gimbals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gimbals
    if get(hObject,'Value')
        set(handles.ring1, 'Visible', 'on');
                set(handles.ring2, 'Visible', 'on');
        set(handles.ring3, 'Visible', 'on');
    else
                set(handles.ring1, 'Visible', 'off');
                set(handles.ring2, 'Visible', 'off');
        set(handles.ring3, 'Visible', 'off');
    end
