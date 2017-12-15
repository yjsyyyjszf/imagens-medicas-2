function varargout = IMG_app(varargin)
% IMG_APP MATLAB code for IMG_app.fig
%      IMG_APP, by itself, creates a new IMG_APP or raises the existing
%      singleton*.
%
%      H = IMG_APP returns the handle to a new IMG_APP or the handle to
%      the existing singleton*.
%
%      IMG_APP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMG_APP.M with the given input arguments.
%
%      IMG_APP('Property','Value',...) creates a new IMG_APP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IMG_app_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IMG_app_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IMG_app

% Last Modified by GUIDE v2.5 15-Dec-2017 16:20:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IMG_app_OpeningFcn, ...
                   'gui_OutputFcn',  @IMG_app_OutputFcn, ...
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


% --- Executes just before IMG_app is made visible.
function IMG_app_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IMG_app (see VARARGIN)
global raio ordem tipo plotResult limiar mascara seeds;
% Choose default command line output for IMG_app
handles.output = hObject;
raio = str2double(handles.text_raio.String);
ordem = str2double(handles.text_ordem.String);
tipo = 'low';
plotResult = 'yes';
limiar = 0.27;
mascara = 9;
seeds = [];
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = IMG_app_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in button_carregar.
function button_carregar_Callback(hObject, eventdata, handles)
% hObject    handle to button_carregar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imagemSaida imagemEntrada;
[FileName,PathName] = uigetfile({'*.*',  'All Files (*.*)'}, ...
        'Escolha uma imagem');
imagemEntrada = imread([PathName FileName]);
imagemSaida = imagemEntrada;
axes(handles.axes_output);
imshow(imagemSaida);
axes(handles.axes_input);
imshow(imagemSaida);
linkaxes([handles.axes_input,handles.axes_output],'xy')

% --- Executes on button press in button_resetar.
function button_resetar_Callback(hObject, eventdata, handles)
% hObject    handle to button_resetar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imagemEntrada imagemSaida;
imagemSaida = imagemEntrada;
axes(handles.axes_output);
cla
axes(handles.axes_input);
cla
axes(handles.axes_output);
imshow(imagemSaida);
axes(handles.axes_input);
imshow(imagemEntrada);

% --- Executes on button press in checkbox_butter.
function checkbox_butter_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_butter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global tipo imagemSaida raio ordem plotResult;
% Hint: get(hObject,'Value') returns toggle state of checkbox_passaBaixa
if get(hObject,'Value')
    [imagemSaida] = butterworthFilter(imagemSaida,tipo,raio,ordem,plotResult); 
    axes(handles.axes_output);
    imshow(imagemSaida);
end

% --- Executes on button press in checkbox_ideal.
function checkbox_ideal_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_ideal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global  tipo imagemSaida raio plotResult;
% Hint: get(hObject,'Value') returns toggle state of checkbox_passaBaixa
if get(hObject,'Value')
    [imagemSaida] = idealFilter(imagemSaida,tipo,raio,plotResult); 
    axes(handles.axes_output);
    imshow(imagemSaida);
end

% --- Executes on button press in checkbox_passaAlta.
function checkbox_passaAlta_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_passaAlta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global tipo;
% Hint: get(hObject,'Value') returns toggle state of checkbox_passaBaixa
if get(hObject,'Value')
    tipo = 'high';
end

% --- Executes on button press in checkbox_passaBaixa.
function checkbox_passaBaixa_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_passaBaixa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global tipo;
% Hint: get(hObject,'Value') returns toggle state of checkbox_passaBaixa
if get(hObject,'Value')
    tipo = 'low';
end


function text_raio_Callback(hObject, eventdata, handles)
% hObject    handle to text_raio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global raio;
% raio = get(hObject,'String');
raio = str2double(handles.text_raio.String);

% --- Executes during object creation, after setting all properties.
function text_raio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_raio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_media.
function checkbox_media_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_media (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global  imagemSaida plotResult mascara;
% Hint: get(hObject,'Value') returns toggle state of checkbox_media
[imagemSaida] = averageFilter(imagemSaida, mascara,plotResult); 
axes(handles.axes_output);
imshow(imagemSaida);
    
% --- Executes on button press in checkbox_max.
function checkbox_max_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global  imagemSaida plotResult mascara;
% Hint: get(hObject,'Value') returns toggle state of checkbox_max
[imagemSaida] = maximumFilter(imagemSaida, mascara,plotResult); 
axes(handles.axes_output);
imshow(imagemSaida);

% --- Executes on button press in checkbox_mediana.
function checkbox_mediana_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_mediana (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global  imagemSaida plotResult mascara;
% Hint: get(hObject,'Value') returns toggle state of checkbox_max
[imagemSaida] = medianFilter(imagemSaida, mascara,plotResult); 
axes(handles.axes_output);
imshow(imagemSaida);

% --- Executes on button press in checkbox_medGeo.
function checkbox_medGeo_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_medGeo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global  imagemSaida plotResult mascara;
% Hint: get(hObject,'Value') returns toggle state of checkbox_max
[imagemSaida] = geoAverageFilter(imagemSaida, mascara,plotResult); 
axes(handles.axes_output);
imshow(imagemSaida);

% --- Executes on button press in checkbox_min.
function checkbox_min_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global  imagemSaida plotResult mascara;
% Hint: get(hObject,'Value') returns toggle state of checkbox_max
[imagemSaida] = minimumFilter(imagemSaida, mascara,plotResult); 
axes(handles.axes_output);
imshow(imagemSaida);

% --- Executes on button press in checkbox_sementes.
function checkbox_sementes_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sementes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global seeds seedsInv imagemSaida imagemMarcada;
% Hint: get(hObject,'Value') returns toggle state of checkbox_sementes
p = ginput(1);
y = round(axes2pix(size(imagemSaida, 2), get(handles.axes_input.Children, 'XData'), p(2)));
x = round(axes2pix(size(imagemSaida, 1), get(handles.axes_input.Children, 'YData'), p(1)));
seeds = [seeds; [x y]];
disp('xablaus');
imagemMarcada = insertMarker(imagemSaida,seeds);
% inverte para proxima funcao
seedsInv = [seedsInv; [y x]];
axes(handles.axes_output);
imshow(imagemMarcada);

% --- Executes on button press in checkbox_crescimento.
function checkbox_crescimento_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_crescimento (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global seeds seedsInv imagemSaida imagemMarcada limiar;
% Hint: get(hObject,'Value') returns toggle state of checkbox_crescimento
limiarCrescimento = round(limiar*255);
% imagemMarcada = handles.axes_input.Children.CData;
for i=1:size(seedsInv,1);    
    poly = regionGrowing(imagemSaida, [seedsInv(i,:) 1], limiarCrescimento);
    hold on
    axes(handles.axes_output);
    plot(poly(:,1), poly(:,2), 'LineWidth', 2)
end
hold off

% --- Executes on button press in checkbox_acumular.
function checkbox_acumular_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_acumular (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_acumular


% --- Executes on button press in checkbox_comparar.
function checkbox_comparar_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_comparar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plotResult
% Hint: get(hObject,'Value') returns toggle state of checkbox_comparar
estado =  get(hObject,'Value');
if estado
    plotResult = 'yes';
else
    plotResult = 'no';
end


% --- Executes on button press in checkbox_arvore.
function checkbox_arvore_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_arvore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imagemSaida limiar;
% Hint: get(hObject,'Value') returns toggle state of checkbox_arvore
quadTreeSegmentation(imagemSaida',limiar,'yes');



function text_ordem_Callback(hObject, eventdata, handles)
% hObject    handle to text_ordem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ordem;
% Hints: get(hObject,'String') returns contents of text_ordem as text
%        str2double(get(hObject,'String')) returns contents of text_ordem as a double
ordem = str2double(handles.text_ordem.String);

% --- Executes during object creation, after setting all properties.
function text_ordem_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_ordem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_limiar_Callback(hObject, eventdata, handles)
% hObject    handle to slider_limiar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global limiar;
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
limiar = get(hObject,'Value');
set(handles.text_limiar,'String',num2str(limiar));

% --- Executes during object creation, after setting all properties.
function slider_limiar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_limiar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
