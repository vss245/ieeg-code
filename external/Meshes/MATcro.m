function varargout = MATcro(varargin)
% surface rendering for NIfTI images, can be run from user interface or scripted
%Examples:
% MATcro %launch MATcro
% MATcro('openLayer',{'avg152T1_brain.nii.gz'}); %open image
% MATcro('simplifyLayers', 0.5); %reduce mesh to 50% complexity
% MATcro('closeLayers'); %close all images
% MATcro('openLayer',{'cortex_20484.surf.gii'}); %open image
% MATcro('openLayer',{'attention.nii.gz'}, 3.0); %add fMRI overlay, threshold t>3
% MATcro('openLayer',{'saccades.nii.gz'}, 3.0); %add fMRI overlay threshold t>3
% MATcro('openLayer',{'scalp_2562.surf.gii'}); %add scalp overlay
% MATcro('layerRGBA', 4, 0.9, 0.5, 0.5, 0.2); %make scalp reddish
% MATcro('setMaterial', 0.1, 0.4, 0.9, 50, 0, 1); %make surfaces shiny
% for i=-27:9
% 	MATcro('setView', i*10, 35); %rotate azimuth, constant elevation
% 	pause(0.1);
% end;
% MATcro('copyBitmap'); %copy screenshot to clipboard
% MATcro('saveBitmap',{'myPicture.png'}); %save screenshot
% MATcro('saveMesh',{'myMesh.ply'}); %export mesh to PLY format
mOutputArgs = {}; % Variable for storing output when GUI returns
h = findall(0,'tag',mfilename); %run as singleton
if (isempty(h)) % new instance
   h = makeGUI(); %set up user interface
else % instance already running
   figure(h);  %Figure exists so bring Figure to the focus
end;
if (nargin) && (ischar(varargin{1})) 
 f = str2func(varargin{1});
 f(guidata(h),varargin{2:nargin})
end
mOutputArgs{1} = h;% return handle to main figure
if nargout>0
 [varargout{1:nargout}] = mOutputArgs{:};
end
%end MATcro() --- SUBFUNCTIONS FOLLOW

% --- add an image as a new layer on top of previously opened images
function openLayer(v,varargin)
%  filename, threshold(optional), reduce(optional), smooth(optional)
% Optional values only influence NIfTI volumes, not meshes (VTK, GIfTI)
%  nb: threshold=Inf for midrange, threshold=-Inf for otsu, threshold=NaN for dialog box
%MATcro('openLayer',{'cortex_5124.surf.gii'});
%MATcro('openLayer',{'attention.nii.gz'}); %midrange threshold
%MATcro('openLayer',{'attention.nii.gz',-Inf}); %Otsu's threshold
%MATcro('openLayer',{'attention.nii.gz'},3,0.05,0); %threshold >3
if (length(varargin) < 1), return; end;
thresh = Inf;
reduce = 0.25;
smooth = 0;
filename = char(varargin{1});
if (length(varargin) > 1), thresh = cell2mat(varargin(2)); end;
if (length(varargin) > 2), reduce = cell2mat(varargin(3)); end;
if (length(varargin) > 3), smooth = cell2mat(varargin(4)); end;
SelectFileToOpen(v,filename, thresh, reduce, smooth);
%end openLayer()

% --- Save each surface as a polygon file
function saveMesh(v,varargin)
% filename should be .ply, .vtk or (if SPM installed) .gii
%MATcro('saveMesh',{'myMesh.ply'});
if (length(varargin) < 1), return; end;
filename = char(varargin{1});
doSaveMesh(v,filename)
%end saveMesh()

% --- Save screenshot as bitmap image
function saveBitmap(v,varargin)
% inputs: filename
%MATcro('saveBitmap',{'myPicture.png'});
if (length(varargin) < 1), return; end;
filename = char(varargin{1});
%saveas(v.hAxes, filename,'png'); %<- save as 150dpi
print (v.hMainFigure, '-r600', '-dpng', filename); %<- save as 600dpi , '-noui'
%end saveBitmap()

% --- Copy screenshot to clipboard
function copyBitmap(v)
%MATcro('copyBitmap')
editmenufcn(v.hAxes,'EditCopyFigure');
%end copyBitmap()

% --- close all open layers 
function closeLayers(v,varargin)
%MATcro('closeLayers');
doCloseOverlays(v);
%end closeLayers()

% --- set a Layer's color and transparency
function layerRGBA(v,varargin)
% inputs: layerNumber, Red, Green, Blue, Alpha
%MATcro('layerRGBA', 1, 0.9, 0, 0, 0.2) %set layer 1 to bright red (0.9) with 20% opacity
if (length(varargin) < 2), return; end;
vIn = cell2mat(varargin);
v.vprefs.colors(vIn(1),1:(length(varargin)-1)) = vIn(2:length(varargin)); %change layer 1's red/green/blue/opacity 
guidata(v.hMainFigure,v);%store settings
redrawSurface(v);
%end layerRGBA()

% ---  reduce mesh complexity
function simplifyLayers(v, varargin)
% inputs: reductionRatio
%MATcro('simplifyLayers', 0.2); %reduce mesh to 20% complexity
if (length(varargin) < 1), return; end;
reduce = cell2mat(varargin(1));
doSimplifyMesh(v,reduce)
%end simplifyLayers()

% --- set surface appearance (shiny, matte, etc)
function setMaterial(v,varargin)
% inputs: ambient(0..1), diffuse(0..1), specular(0..1), specularExponent(0..inf), bgMode (0 or 1), backFaceLighting (0 or 1)
%MATcro('setMaterial', 0.5, 0.5, 0.7, 100, 1, 1);
if (length(varargin) < 1), return; end;
vIn = cell2mat(varargin);
v.vprefs.materialKaKdKsn(1) = vIn(1);
if (length(varargin) > 1), v.vprefs.materialKaKdKsn(2) = vIn(2); end;
if (length(varargin) > 2), v.vprefs.materialKaKdKsn(3) = vIn(3); end;
v.vprefs.materialKaKdKsn(1:3) = boundArray(v.vprefs.materialKaKdKsn(1:3),0,1);
if (length(varargin) > 3), v.vprefs.materialKaKdKsn(4) = vIn(4); end;
if (length(varargin) > 4), v.vprefs.bgMode = vIn(5); end;
if (length(varargin) > 5), v.vprefs.backFaceLighting = vIn(6); end;
guidata(v.hMainFigure,v);%store settings
redrawSurface(v);
%end setMaterial()

% --- set view by moving camera position
function setView(v,varargin)
% inputs: azimuth(0..360), elevation(=90..90)
%MATcro('setView', 15, 25);
if (nargin < 1), return; end;
vIn = cell2mat(varargin);
v.vprefs.az = vIn(1);
if (nargin > 1), v.vprefs.el = vIn(2); end;
guidata(v.hMainFigure,v);%store settings
redrawSurface(v);
%end setView()

% --- Declare and create all the user interface objects
function [vFig] = makeGUI()
sz = [980 680]; % figure width, height in pixels
screensize = get(0,'ScreenSize');
margin = [ceil((screensize(3)-sz(1))/2) ceil((screensize(4)-sz(2))/2)];
v.hMainFigure = figure('MenuBar','none','Toolbar','none','HandleVisibility','on', ...
  'position',[margin(1), margin(2), sz(1), sz(2)], ...
    'Tag', mfilename,'Name', mfilename, 'NumberTitle','off', ...
 'Color', get(0, 'defaultuicontrolbackgroundcolor'));
set(v.hMainFigure,'Renderer','OpenGL')
v.hAxes = axes('Parent', v.hMainFigure,'HandleVisibility','on','Units', 'normalized','Position',[0.0 0.0 1 1]); %important: turn ON visibility
%menus...
v.hFileMenu = uimenu('Parent',v.hMainFigure,'HandleVisibility','callback','Label','File');
v.hAddMenu = uimenu('Parent',v.hFileMenu,'Label','Add image','HandleVisibility','callback', 'Callback', @AddMenu_Callback);
v.hAddAdvMenu = uimenu('Parent',v.hFileMenu,'Label','Add image with options','HandleVisibility','callback', 'Callback', @AddAdvMenu_Callback);
v.hCloseOverlaysMenu = uimenu('Parent',v.hFileMenu,'Label','Close image(s)','HandleVisibility','callback', 'Callback', @CloseOverlaysMenu_Callback);
v.hSaveBmpMenu = uimenu('Parent',v.hFileMenu,'Label','Save bitmap','HandleVisibility','callback', 'Callback', @SaveBmpMenu_Callback);
v.hSaveMeshesMenu = uimenu('Parent',v.hFileMenu,'Label','Save mesh(es)','HandleVisibility','callback', 'Callback', @SaveMeshesMenu_Callback);
v.hEditMenu = uimenu('Parent',v.hMainFigure,'HandleVisibility','callback','Label','Edit');
v.hCopyMenu = uimenu('Parent',v.hEditMenu,'Label','Copy','HandleVisibility','callback','Callback', @CopyMenu_Callback);
v.hFunctionMenu = uimenu('Parent',v.hMainFigure,'HandleVisibility','callback','Label','Functions');
v.hToolbarMenu = uimenu('Parent',v.hFunctionMenu,'Label','Show/hide toolbar','HandleVisibility','callback','Callback', @ToolbarMenu_Callback);
v.hOverlayOptionsMenu = uimenu('Parent',v.hFunctionMenu,'Label','Color and transparency','HandleVisibility','callback','Callback', @OverlayOptionsMenu_Callback);
v.hMaterialOptionsMenu = uimenu('Parent',v.hFunctionMenu,'Label','Surface material','HandleVisibility','callback','Callback', @MaterialOptionsMenu_Callback);
v.hSimplifyMeshesMenu = uimenu('Parent',v.hFunctionMenu,'Label','Simplify mesh(es)','HandleVisibility','callback','Callback', @SimplifyMeshesMenu_Callback);
v.hHelpMenu = uimenu('Parent',v.hMainFigure,'HandleVisibility','callback','Label','Help');
v.hAboutMenu = uimenu('Parent',v.hHelpMenu,'Label','About','HandleVisibility','callback','Callback', @AboutMenu_Callback);
%load default simulated surfaces
[heartFV, sphereFV] = createDemoObjects;
v.surface(1) = heartFV;
v.surface(2) = sphereFV;
%viewing preferences - color, material, camera position, light position
v.vprefs.demoObjects = true; %denote simulated objects
v.vprefs.colors = [0.7 0.7 0.9 0.6; 1 0 0 0.7; 0 1 0 0.7; 0 0 1 0.7; 0.5 0.5 0 0.7; 0.5 0 0.5 0.7; 0 0.5 0.5 0.7;0.7 0.7 0.9 0.6; 1 0 0 0.7; 0 1 0 0.7; 0 0 1 0.7; 0.5 0.5 0 0.7; 0.5 0 0.5 0.7; 0 0.5 0.5 0.7;0.7 0.7 0.9 0.6; 1 0 0 0.7; 0 1 0 0.7; 0 0 1 0.7; 0.5 0.5 0 0.7; 0.5 0 0.5 0.7; 0 0.5 0.5 0.7]; %rgba for each layer
v.vprefs.materialKaKdKsn = [0.6 0.4 0.4, 100.0];%ambient/diffuse/specular strength and specular exponent
v.vprefs.bgMode = 0; %background mode: wireframe, faces, faces+edges
v.vprefs.backFaceLighting = 1;
v.vprefs.azLight = 0; %light azimuth relative to camera
v.vprefs.elLight = 60; %light elevation relative to camera
v.vprefs.camLight = [];
v.vprefs.az = 45; %camera azimuth
v.vprefs.el = 10; %camera elevation
guidata(v.hMainFigure,v);%store settings
vFig = v.hMainFigure;
redrawSurface(v);
%end makeGUI()

% --- generate initial background volume: make heart and sphere shapes
function [heartFV, sphereFV] = createDemoObjects
vox=48;
[X,Y,Z]=ndgrid(linspace(-3,3,vox),linspace(-3,3,vox),linspace(-3,3,vox));
F=((-(X.^2) .* (Z.^3) -(9/80).*(Y.^2).*(Z.^3)) + ((X.^2) + (9/4).* (Y.^2) + (Z.^2)-1).^3);
heartFV = isosurface(F,0);
F = sqrt(X.^2 + Y.^2 + Z.^2);
sphereFV = isosurface(F,0.4);
%end createDemoObjects()

% --- creates renderings
function redrawSurface(v)
delete(allchild(v.hAxes));%
set(v.hMainFigure,'CurrentAxes',v.hAxes)
set(0, 'CurrentFigure', v.hMainFigure);  %# for figures
if ( v.vprefs.backFaceLighting == 1)
    bf = 'reverselit';
else
    bf = 'unlit'; % 'reverselit';
end
for i=1:length( v.surface)
    clr =  v.vprefs.colors ( (mod(i-1,length( v.vprefs.colors))+1) ,1:3);
    if ( v.vprefs.bgMode == 1) && ( i == 1)
        ec = 'black';
    else
        ec = 'none';
    end;
    alph =  v.vprefs.colors (mod(i,length( v.vprefs.colors)),4);
    patch('vertices', v.surface(i).vertices,'faces', v.surface(i).faces,...
        'edgecolor',ec,'BackFaceLighting',bf,...
        'facealpha',alph,'facecolor',clr,'facelighting','phong');
end;
set(gca,'DataAspectRatio',[1 1 1])
set(gcf,'Color',[1 1 1])
axis vis3d off; %tight
h = rotate3d; 
set( h, 'ActionPostCallback', @myPost_Callback); %called when user changes perspective
set(h,'Enable','on');
view( v.vprefs.az,  v.vprefs.el);
v.vprefs.camLight = camlight( v.vprefs.azLight, v.vprefs.elLight);
material( v.vprefs.materialKaKdKsn);
light;
guidata(v.hMainFigure,v);%store settings
%end redrawSurface()

% --- reposition light after camera is moved, store new camera azimuth/elevation
function myPost_Callback(obj,evd)
v=guidata(obj);
camlight(v.vprefs.camLight, v.vprefs.azLight,v.vprefs.elLight);
newView = round(get(evd.Axes,'View'));
v.vprefs.az = newView(1);
v.vprefs.el = newView(2);
guidata(v.hMainFigure,v);%store settings
%end mypostcallback()

% --- add a new voxel image or mesh as a layer with default options
function AddMenu_Callback(obj, eventdat)
v=guidata(obj);
SelectFileToOpen(v,'', Inf, 0.25, 0);
%end AddMenu_Callback()

% --- add a new voxel image or mesh as a layer, allow user to specify options
function AddAdvMenu_Callback(obj, eventdata)
v=guidata(obj);
SelectFileToOpen(v,'', NaN, 0.25, 0 );
%end AddAdvMenu_Callback()

% --- close all open images
function doCloseOverlays(v)
if (~isempty(v.surface)) 
    v = rmfield(v,'surface');
    [heartFV, sphereFV] = createDemoObjects;
    v.surface(1) = heartFV;
    v.surface(2) = sphereFV;
    v.vprefs.demoObjects = true;
    guidata(v.hMainFigure,v);%store settings
    redrawSurface(v);
else
    fprintf('Unable to close overlays: no overlays loaded\n');
end;
%end doCloseOverlays()

% --- close all open images
function CloseOverlaysMenu_Callback(obj, eventdata)
v=guidata(obj);
doCloseOverlays(v);
%end CloseOverlaysMenu_Callback()

% --- save mesh(es) as PLY, VTK or (if SPM is installed) GIfTI format file
function doSaveMesh(v, filename)
[path,file,ext] = fileparts(filename);
for i=1:length(v.surface)
    if (i > 1) 
        filename = fullfile(path, [file num2str(i) ext]);
    end;
    if (length(ext) == 4) && strcmpi(ext,'.gii')
        if (exist('gifti.m', 'file') == 2)
            g = gifti(v.surface(i));
            save(g,filename,'GZipBase64Binary');
        else
            fprintf('Error: Unable to save GIfTI files - make sure SPM is installed');
        end;
    elseif (length(ext) == 4) && strcmpi(ext,'.vtk')
        writeVtkSub(v.surface(i).vertices,v.surface(i).faces,filename);
    else
        writePlySub(v.surface(i).vertices,v.surface(i).faces,filename);
    end;
end;
%end doSaveMesh()

% --- allow user to specify file name to export meshes
function SaveMeshesMenu_Callback(obj, eventdata)
if (exist('gifti.m', 'file') == 2)
    [file,path] = uiputfile({'*.gii','GIfTI (e.g. SPM8)';'*.vtk','VTK (e.g. FSLview)';'*.ply','PLY (e.g. MeshLab)'},'Save mesh');
else
    [file,path] = uiputfile({'*.ply','PLY (e.g. MeshLab)';'*.vtk','VTK (e.g. FSLview)'},'Save mesh');
end
if isequal(file,0), return; end;
filename=[path file];
v=guidata(obj);
doSaveMesh(v, filename);
%end SaveMeshesMenu_Callback()

% --- show/hide figure toolbar
function ToolbarMenu_Callback(obj, eventdata)
if strcmpi(get(gcf, 'Toolbar'),'none')
    set(gcf,  'Toolbar', 'figure');
else
    set(gcf,  'Toolbar', 'none');
end
%end ToolbarMenu_Callback()

% --- save screenshot as bitmap image
function SaveBmpMenu_Callback(obj, eventdata)
v=guidata(obj);
[file,path] = uiputfile('*.png','Save image as');
if isequal(file,0), return; end;
saveBitmap(v,[path file]);
%end SaveBmpMenu_Callback()

% --- let user select layer, then set RGBA for that layer 
function OverlayOptionsMenu_Callback(obj, eventdata)
v=guidata(obj);
nlayer = length(v.surface);
if nlayer > 1
    answer = inputdlg({['Layer [1= background] (1..' num2str(nlayer) ')']}, 'Enter layer to modify', 1,{'1'});
    if isempty(answer), disp('options cancelled'); return; end;
    layer = round(str2double(answer));
    layer = boundArray(layer,1,nlayer);
else
    layer = 1;
end; 
v.vprefs.colors(layer,1:3) = uisetcolor( v.vprefs.colors(layer,1:3),'select color');
answer = inputdlg({'Alpha (0[transparent]..1[opaque])'},'Set opacity',1,{num2str( v.vprefs.colors(layer,4))} );
if isempty(answer), disp('options cancelled'); return; end;
v.vprefs.colors(layer,4) = str2double(answer(1));
v.vprefs.colors(layer,:) = boundArray( v.vprefs.colors(layer,:), 0,1);
guidata(v.hMainFigure,v);%store settings
redrawSurface(v); %display new settings
%end OverlayOptionsMenu_Callback()

% --- allow user to select appearance of surfaces
function MaterialOptionsMenu_Callback(obj, eventdata)
v=guidata(obj);
prompt = {'Ambient strength (0..1):','Diffuse strength(0..1):'...
    'Specular strength (0..1)', 'Specular exponent (0..100)','Mode [0=hide edges,1=show edges]:'...
    'Back face reverse lit (1=true)'};
dlg_title = 'Select options for surface material';
a =  v.vprefs.materialKaKdKsn;
def = {num2str(a(1)),num2str(a(2)), num2str(a(3)),num2str(a(4)), num2str( v.vprefs.bgMode),num2str( v.vprefs.backFaceLighting)};
answer = inputdlg(prompt,dlg_title,1,def);
if isempty(answer), disp('options cancelled'); return; end;
 v.vprefs.materialKaKdKsn(1) = str2double(answer(1));
 v.vprefs.materialKaKdKsn(2) = str2double(answer(2));
 v.vprefs.materialKaKdKsn(3) = str2double(answer(3));
 v.vprefs.materialKaKdKsn(1:3) = boundArray( v.vprefs.materialKaKdKsn(1:3),0,1);
 v.vprefs.materialKaKdKsn(4) = str2double(answer(4));
 v.vprefs.bgMode = round(str2double(answer(5)));
 v.vprefs.backFaceLighting = round(str2double(answer(6)));
 guidata(v.hMainFigure,v);%store settings
redrawSurface(v);
%end MaterialOptionsMenu_Callback()

% --- reduce mesh complexity
function doSimplifyMesh(v,reduce)
if (reduce >= 1) || (reduce <= 0), disp('simplify ratio must be between 0..1');  return; end;
for i=1:length(v.surface)
    FVr = reducepatch(v.surface(i),reduce);
    fprintf('Mesh reduced %d->%d vertices and %d->%d faces\n',size(v.surface(i).vertices,1),size(FVr.vertices,1),size(v.surface(i).faces,1),size(FVr.faces,1) );
    v.surface(i).faces = FVr.faces;
    v.surface(i).vertices = FVr.vertices;
    clear('FVr');    
end;
guidata(v.hMainFigure,v);%store settings
redrawSurface(v);
%end simplifyMesh()

% --- allow user to specify parameters for reducing mesh complexity
function SimplifyMeshesMenu_Callback(obj, eventdata)
v=guidata(obj);
reduce = 0.25;
prompt = {'Reduce Path, e.g. 0.5 means half resolution (0..1):'};
dlg_title = 'Select options for loading image';
def = {num2str(reduce)};
answer = inputdlg(prompt,dlg_title,1,def);
if isempty(answer), disp('simplify cancelled'); return; end;
reduce = str2double(answer(1));
doSimplifyMesh(v,reduce)
%end SimplifyMeshesMenu_Callback()

% --- display version
function AboutMenu_Callback(obj, eventdata)
msgbox('MATcro 7/2013 by Leonardo Bonilha and Chris Rorden','About');
%end AboutMenu_Callback()

function CopyMenu_Callback(obj, eventdata)
v=guidata(obj);
copyBitmap(v);
%end CopyMenu_Callback()

% --- open a mesh or voxel image
function SelectFileToOpen(v, filename, thresh, reduce,smooth)
%filename: mesh (GIFTI,VTK,PLY) or NIFTI voxel image to open
% thresh : (NIFTI only) isosurface threshold Inf for automatic, -Inf for dialog input
% reduce : (NIFTI only) path reduction ratio, e.g. 0.2 makes mesh 20% original size
% smooth : (NIFTI only) radius of smoothing, 0 = no smoothing
if length(filename) < 1
    if (exist('gifti.m', 'file') == 2)
        [brain_filename, brain_pathname] = uigetfile( ...
                    {'*.nii;*.hdr;*.nii.gz;*.gii;*.vtk', 'NIfTI/GIfTI/VTK files'; ...
                    '*.*',                   'All Files (*.*)'}, ...
                    'Select a NIfTI image');
    else
        [brain_filename, brain_pathname] = uigetfile( ...
                    {'*.nii;*.hdr;*.nii.gz', 'NIfTI/VTK files'; ...
                    '*.*',                   'All Files (*.*)'}, ...
                    'Select a NIfTI image');
    end;
    if isequal(brain_filename,0), return; end;
    filename=[brain_pathname brain_filename];
end;
isBackground = v.vprefs.demoObjects;
if exist(filename, 'file') == 0, fprintf('Unable to find "%s"\n',filename); return; end;
[pathstr, name, ext] = fileparts(filename);
if (length(ext) == 4) && strcmpi(ext,'.vtk')
        meshToOpen (v,filename, isBackground);
        return;
end; %VTK file
if (exist('gifti.m', 'file') == 2) &&  (length(ext) == 4) && strcmpi(ext,'.gii')
        meshToOpen (v,filename, isBackground);
        return;
end; %GIFTI file
if isnan(thresh)
    thresh = Inf;%infinity means auto-select
    prompt = {'Surface intensity threshold (Inf=midrange, -Inf=Otsu):','Reduce Path, e.g. 0.5 means half resolution (0..1):','Smoothing radius in voxels (0=none):'};
    dlg_title = 'Select options for loading image';
    def = {num2str(thresh),num2str(reduce),num2str(smooth)};
    answer = inputdlg(prompt,dlg_title,1,def);
    if isempty(answer), disp('load cancelled'); return; end;
    %if length(answer) == 0, disp('load cancelled'); return; end;
    thresh = str2double(answer(1));
    reduce = str2double(answer(2));
    smooth = round(str2double(answer(3)))*2+1; %e.g. +1 for 3x3x3, +2 for 5x5x5
end; 
%next - detect and unpack .nii.gz to .nii
isGZ = false;
if (length(ext)==3)  && min((ext=='.gz')==1) 
    ungzname = fullfile(pathstr, name);
    if exist(ungzname, 'file') ~= 0
        fprintf('Warning: File exists named %s; will open in place of %s\n',ungzname, filename);
        filename = ungzname;
    else
        filename = char(gunzip(filename));
        isGZ = true;
    end;
end;
voxToOpen (v,filename, thresh, reduce,smooth, isBackground); %load voxel image
if (isGZ), delete(filename); end; %remove temporary uncompressed image
%end SelectFileToOpen() 

% --- convert voxel image to triangle surface mesh
function voxToOpen (v,filename, thresh, reduce, smooth, isBackground)
% filename: image to open
% thresh : isosurface threshold, e.g. if 1 then voxels less than 1 are transparent
%          "Inf" or "-Inf" for automatic thresholds
% reduce : reduction factor 0..1, e.g. 0.05 will simplify mesh to 5% of original size 
if isequal(filename,0), return; end;
if exist(filename, 'file') == 0, fprintf('Unable to find %s\n',filename); return; end;
if (reduce > 1) || (reduce <= 0), reduce = 1; end;
Hdr = spm_volSub(filename); %this call clones spm_vol without dependencies
Vol = spm_read_volsSub(Hdr);%this call clones spm_read_vols without dependencies
%Hdr = spm_vol(filename); % <- these are the actual SPM calls
%Vol = spm_read_vols(Hdr); % <- these are the actual SPM calls
Vol(isnan(Vol)) = 0; 
if (round(smooth) > 3) %blur image prior to edge extraction
    fprintf('Applying gaussian smooth with %d voxel diameter\n',round(smooth));
    Vol = smooth3(Vol,'gaussian',round(smooth));
end;
if (isinf(thresh) && (thresh < 0)) %if -Inf, use Otsu's method
     thresh = otsuSub(Vol); %use Otsu's method to detect isosurface threshold
elseif (isnan(thresh)) || (isinf(thresh)) %if +Inf, use midpoint
	thresh = max(Vol(:)) /2; %use  max/min midpoint as isosurface threshold
    %thresh = mean(Vol(:)); %use mean to detect isosurface threshold - heavily influenced by proportion of dark air
end;
if (isBackground) 
    v = rmfield(v,'surface');
    layer = 1;
else
    layer = length( v.surface)+1;
end;
FV = isosurface(Vol,thresh);
if (reduce ~= 1.0) %next: simplify mesh
    FV = reducepatch(FV,reduce);
end;
v.surface(layer).faces = FV.faces;
v.surface(layer).vertices = FV.vertices;
v.vprefs.demoObjects = false;
clear('FV');
%next: isosurface swaps the X and Y dimensions! size(Vol)
i = 1;
j = 2;
v.surface(layer).vertices =  v.surface(layer).vertices(:,[1:i-1,j,i+1:j-1,i,j+1:end]);
%BELOW: SLOW for loop for converting from slice indices to mm
%for vx = 1:size( v.surface(layer).vertices,1) %slow - must be a way to do this with bsxfun
% wc = Hdr.mat * [ v.surface(layer).vertices(vx,:) 1]'; %convert voxel to world coordinates
% v.surface(layer).vertices(vx,:) = wc(1:3)';
%end
%BELOW: FAST vector for converting from slice indices to mm
vx = [ v.surface(layer).vertices ones(size( v.surface(layer).vertices,1),1)];
vx = mtimes(Hdr.mat,vx')';
v.surface(layer).vertices = vx(:,1:3);
%display results
guidata(v.hMainFigure,v);%store settings
fprintf('Surface threshold %f and reduction ratio %f yields mesh  with %d vertices and %d faces from image %s\n', thresh, reduce,size( v.surface(layer).vertices,1),size( v.surface(layer).faces,1),filename);
redrawSurface(v);
%end voxToOpen()

% --- open pre-generated mesh
function meshToOpen (v,filename, isBackground)
if isequal(filename,0), return; end;
if exist(filename, 'file') == 0, fprintf('Unable to find %s\n',filename); return; end;
[~, ~, ext] = fileparts(filename);
if (length(ext) == 4) && strcmpi(ext,'.gii') && (~exist('gifti.m', 'file') == 2)
    fprintf('Unable to open GIfTI files: this feature requires SPM to be installed');
end;
if (isBackground) 
    v = rmfield(v,'surface');
    layer = 1;
else
    layer = length( v.surface)+1;
end;
if (length(ext) == 4) && strcmpi(ext,'.gii')
    gii = gifti(filename);
     v.surface(layer).faces = double(gii.faces); %convert to double or reducepatch fails
     v.surface(layer).vertices = double(gii.vertices); %convert to double or reducepatch fails
else
    [gii.vertices gii.faces] = read_vtkSub(filename);
     v.surface(layer).faces = gii.faces'; 
     v.surface(layer).vertices = gii.vertices'; 
end;
v.vprefs.demoObjects = false;
guidata(v.hMainFigure,v);%store settings
redrawSurface(v);
%end meshToOpen()

% --- clip all values of 'in' to the range min..max
function [out] = boundArray(in, min,max)
out = in;
i = out > max;
out(i) = max;
i = out < min;
out(i) = min;
%end boundArray()

% --- creates binary format ply file, e.g. for meshlab
function writePlySub(vertex,face,filename)
%for format details, see http://paulbourke.net/dataformats/ply/
[fid,Msg] = fopen(filename,'Wt');
if fid == -1, error(Msg); end;
[~,~,endian] = computer;
fprintf(fid,'ply\n');
if endian == 'L'
    fprintf(fid,'format binary_little_endian 1.0\n');
else
    fprintf(fid,'format binary_big_endian 1.0\n');    
end
fprintf(fid,'comment created by MATLAB writeply\n');
fprintf(fid,'element vertex %d\n',length(vertex));
fprintf(fid,'property float x\n');
fprintf(fid,'property float y\n');
fprintf(fid,'property float z\n');
fprintf(fid,'element face %d\n',length(face));
%nb: MeshLab does not support ushort, so we save as either short or uint
if (length(vertex) < (2^15))
    fprintf(fid,'property list uchar short vertex_indices\n'); 
else
    fprintf(fid,'property list uchar uint vertex_indices\n'); % <- 'int' to 'uint'
end;
fprintf(fid,'end_header\n');
fclose(fid);
%binary data 
[fid,Msg] = fopen(filename,'Ab');
if fid == -1, error(Msg); end;
fwrite(fid, vertex', 'single');
if (length(vertex) < (2^15))
    %slow code - optimization not important for small datasets
    for i = 1:length(face)
        fwrite(fid, 3, 'uchar');
        fwrite(fid,round(face(i,:)-1),'int16' ); 
    end;
else
    face32 = uint32(face'-1);
    face32 = typecast(face32(:), 'uint8');
    %13 bytes per triangle, 1 byte for number of vertices (=3), and 4 bytes each of the 3 vertices
    face8 = uint8(0);
    face8(length(face)*13 , 1) = face8;
    face8(:) = 3; %all triangles have 3 vertices
    pos8 = 1; %skip first byte
    pos32 = 0;
    for i = 1:length(face)
        for p = 1:12
            face8(pos8+p) = face32(pos32+p);
        end;
        pos8 = pos8+13; 
        pos32 = pos32+12;
    end;
    fwrite(fid,face8);
end;
fclose(fid);
%end writePlySub()

% --- load NIfTI header: mimics spm_vol without requiring SPM
function [Hdr] = spm_volSub(filename)
[h, ~, fileprefix, machine] = load_nii_hdr(filename);
Hdr.dim = [h.dime.dim(2) h.dime.dim(3) h.dime.dim(4)];
if (h.hist.sform_code == 0) && (h.hist.qform_code == 0)
    fprintf('Warning: no spatial transform detected. Perhaps Analyze rather than NIfTI format');
    Hdr.mat = hdr2M(h.dime.dim,h.dime.pixdim );
elseif (h.hist.sform_code == 0) && (h.hist.qform_code > 0) %use qform Quaternion only if no sform
    Hdr.mat = hdrQ2M(h.hist,h.dime.dim,h.dime.pixdim );
else %precedence: get spatial transform from matrix (sform)
    Hdr.mat = [h.hist.srow_x; h.hist.srow_y; h.hist.srow_z; 0 0 0 1];
    Hdr.mat = Hdr.mat*[eye(4,3) [-1 -1 -1 1]']; % mimics SPM: Matlab arrays indexed from 1 not 0 so translate one voxel
end;
if (machine == 'ieee-le')
	Hdr.dt = [h.dime.datatype 0];
else
	Hdr.dt = [h.dime.datatype 1];
end;
Hdr.pinfo = [h.dime.scl_slope; h.dime.scl_inter; h.dime.vox_offset];
if findstr('.hdr',filename) & strcmp(filename(end-3:end), '.hdr')
	Hdr.fname =  [fileprefix '.img']; %if file.hdr then set to file.img
else
	Hdr.fname =  filename;
end
Hdr.descrip = h.hist.descrip;
Hdr.n = [h.dime.dim(5) 1];
Hdr.private.hk = h.hk;
Hdr.private.dime = h.dime;
Hdr.private.hist = h.hist;
%end spm_volSub()

% --- load NIfTI header
function [hdr, filetype, fileprefix, machine] = load_nii_hdr(fileprefix)
% Copyright (c) 2009, Jimmy Shen, 2-clause FreeBSD License
if ~exist('fileprefix','var'),
  error('Usage: [hdr, filetype, fileprefix, machine] = load_nii_hdr(filename)');
end
machine = 'ieee-le';
new_ext = 0;
if findstr('.nii',fileprefix) & strcmp(fileprefix(end-3:end), '.nii')
  new_ext = 1;
  fileprefix(end-3:end)='';
end
if findstr('.hdr',fileprefix) & strcmp(fileprefix(end-3:end), '.hdr')
  fileprefix(end-3:end)='';
end
if findstr('.img',fileprefix) & strcmp(fileprefix(end-3:end), '.img')
  fileprefix(end-3:end)='';
end
if new_ext
  fn = sprintf('%s.nii',fileprefix);
  if ~exist(fn)
     msg = sprintf('Cannot find file "%s.nii".', fileprefix);
     error(msg);
  end
else
  fn = sprintf('%s.hdr',fileprefix);
  if ~exist(fn)
     msg = sprintf('Cannot find file "%s.hdr".', fileprefix);
     error(msg);
  end
end
fid = fopen(fn,'r',machine); 
if fid < 0,
  msg = sprintf('Cannot open file %s.',fn);
  error(msg);
else
  fseek(fid,0,'bof');
  if fread(fid,1,'int32') == 348
     hdr = read_header(fid);
     fclose(fid);
  else
     fclose(fid);
     %  first try reading the opposite endian to 'machine'
     switch machine,
     case 'ieee-le', machine = 'ieee-be';
     case 'ieee-be', machine = 'ieee-le';
     end
     fid = fopen(fn,'r',machine);
     if fid < 0,
        msg = sprintf('Cannot open file %s.',fn);
        error(msg);
     else
        fseek(fid,0,'bof');
        if fread(fid,1,'int32') ~= 348
           %  Now throw an error
           %
           msg = sprintf('File "%s" is corrupted.',fn);
           error(msg);
        end
        hdr = read_header(fid);
        fclose(fid);
     end
  end
end
if strcmp(hdr.hist.magic, 'n+1')
  filetype = 2;
elseif strcmp(hdr.hist.magic, 'ni1')
  filetype = 1;
else
  filetype = 0;
end
%end load_nii_hdr()

% --- read NIfTI header, Copyright (c) 2009, Jimmy Shen, 2-clause FreeBSD License
function [ dsr ] = read_header(fid)
dsr.hk   = header_key(fid);
dsr.dime = image_dimension(fid);
dsr.hist = data_history(fid);
if ~strcmp(dsr.hist.magic, 'n+1') && ~strcmp(dsr.hist.magic, 'ni1')
    dsr.hist.qform_code = 0;
    dsr.hist.sform_code = 0;
end
%end read_header()

% --- read NIfTI header, Copyright (c) 2009, Jimmy Shen, 2-clause FreeBSD License
function [ hk ] = header_key(fid)
fseek(fid,0,'bof');
v6 = version;
if str2num(v6(1))<6
   directchar = '*char';
else
   directchar = 'uchar=>char';
end
hk.sizeof_hdr    = fread(fid, 1,'int32')';	% should be 348!
hk.data_type     = deblank(fread(fid,10,directchar)');
hk.db_name       = deblank(fread(fid,18,directchar)');
hk.extents       = fread(fid, 1,'int32')';
hk.session_error = fread(fid, 1,'int16')';
hk.regular       = fread(fid, 1,directchar)';
hk.dim_info      = fread(fid, 1,'uchar')';
%end header_key()
    
% --- read NIfTI header, Copyright (c) 2009, Jimmy Shen, 2-clause FreeBSD License
function [ dime ] = image_dimension(fid)
dime.dim        = fread(fid,8,'int16')';
dime.intent_p1  = fread(fid,1,'float32')';
dime.intent_p2  = fread(fid,1,'float32')';
dime.intent_p3  = fread(fid,1,'float32')';
dime.intent_code = fread(fid,1,'int16')';
dime.datatype   = fread(fid,1,'int16')';
dime.bitpix     = fread(fid,1,'int16')';
dime.slice_start = fread(fid,1,'int16')';
dime.pixdim     = fread(fid,8,'float32')';
dime.vox_offset = fread(fid,1,'float32')';
dime.scl_slope  = fread(fid,1,'float32')';
dime.scl_inter  = fread(fid,1,'float32')';
dime.slice_end  = fread(fid,1,'int16')';
dime.slice_code = fread(fid,1,'uchar')';
dime.xyzt_units = fread(fid,1,'uchar')';
dime.cal_max    = fread(fid,1,'float32')';
dime.cal_min    = fread(fid,1,'float32')';
dime.slice_duration = fread(fid,1,'float32')';
dime.toffset    = fread(fid,1,'float32')';
dime.glmax      = fread(fid,1,'int32')';
dime.glmin      = fread(fid,1,'int32')';
%end image_dimension()

% --- read NIfTI header, Copyright (c) 2009, Jimmy Shen, 2-clause FreeBSD License
function [ hist ] = data_history(fid)
v6 = version;
if str2double(v6(1))<6
   directchar = '*char';
else
   directchar = 'uchar=>char';
end
hist.descrip     = deblank(fread(fid,80,directchar)');
hist.aux_file    = deblank(fread(fid,24,directchar)');
hist.qform_code  = fread(fid,1,'int16')';
hist.sform_code  = fread(fid,1,'int16')';
hist.quatern_b   = fread(fid,1,'float32')';
hist.quatern_c   = fread(fid,1,'float32')';
hist.quatern_d   = fread(fid,1,'float32')';
hist.qoffset_x   = fread(fid,1,'float32')';
hist.qoffset_y   = fread(fid,1,'float32')';
hist.qoffset_z   = fread(fid,1,'float32')';
hist.srow_x      = fread(fid,4,'float32')';
hist.srow_y      = fread(fid,4,'float32')';
hist.srow_z      = fread(fid,4,'float32')';
hist.intent_name = deblank(fread(fid,16,directchar)');
hist.magic       = deblank(fread(fid,4,directchar)');
fseek(fid,253,'bof');
hist.originator  = fread(fid, 5,'int16')';
%end data_history()

% --- guess orientation: only use when neither sform or qform is available
function M = hdr2M(dim, pixdim)
%from SPM decode_qform0 Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging, GPL
n      = min(dim(1),3);
vox    = [pixdim(2:(n+1)) ones(1,3-n)];
origin = (dim(2:4)+1)/2;
off     = -vox.*origin;
M       = [vox(1) 0 0 off(1) ; 0 vox(2) 0 off(2) ; 0 0 vox(3) off(3) ; 0 0 0 1];
%end hdr2M()

% --- Rotations from quaternions
function M = hdrQ2M(hdr, dim, pixdim)
%from SPM decode_qform0 Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging, GPL
R = Q2M(double([hdr.quatern_b hdr.quatern_c hdr.quatern_d]));
T = [eye(4,3) double([hdr.qoffset_x hdr.qoffset_y hdr.qoffset_z 1]')];
n = min(dim(1),3);
Z = [pixdim(2:(n+1)) ones(1,4-n)];
Z(Z<0) = 1;
if pixdim(1)<0, Z(3) = -Z(3); end;
Z = diag(Z);
M = T*R*Z;
M = M
%end hdrQ2M()

% --- Generate a rotation matrix from a quaternion xi+yj+zk+w,
function M = Q2M(Q)
%from SPM decode_qform0 Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging, GPL
% where Q = [x y z], and w = 1-x^2-y^2-z^2.
% See: http://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Conversion_to_and_from_the_matrix_representation
Q = Q(1:3); % Assume rigid body
w = sqrt(1 - sum(Q.^2));
x = Q(1); y = Q(2); z = Q(3);
if w<1e-7,
    w = 1/sqrt(x*x+y*y+z*z);
    x = x*w;
    y = y*w;
    z = z*w;
    w = 0;
end;
xx = x*x; yy = y*y; zz = z*z; ww = w*w;
xy = x*y; xz = x*z; xw = x*w;
yz = y*z; yw = y*w; zw = z*w;
M = [...
(xx-yy-zz+ww)      2*(xy-zw)      2*(xz+yw) 0
    2*(xy+zw) (-xx+yy-zz+ww)      2*(yz-xw) 0
    2*(xz-yw)      2*(yz+xw) (-xx-yy+zz+ww) 0
           0              0              0  1];
%end Q2M()

% --- load NIfTI voxel data: mimics spm_read_vol without requiring SPM
function [img] = spm_read_volsSub(hdr)
if (exist(hdr.fname, 'file') ~= 2)
    fprintf('Error: unable to find %s', hdr.fname);
    return;
end;
switch hdr.dt(1)
   case   2,
      bitpix = 8;  myprecision = 'uint8';
   case   4,
      bitpix = 16; myprecision = 'int16';
   case   8,
      bitpix = 32; myprecision = 'int32';
   case  16,
      bitpix = 32; myprecision = 'float32';
   case  64,
      bitpix = 64; myprecision = 'float64';
   case 512 
      bitpix = 16; myprecision = 'uint16';
   case 768 
      bitpix = 32; myprecision = 'uint32';
   otherwise
      error('This datatype is not supported'); 
end
myvox = hdr.dim(1)*hdr.dim(2)*hdr.dim(3);
%ensure file is large enough
file_stats = dir(hdr.fname);
imgbytes = (myvox * (bitpix/8))+hdr.pinfo(3); %image bytes plus offset
if (imgbytes > file_stats.bytes)
    fprintf('Error: expected %d but file has %d bytes %s',imgbytes, file_stats.bytes,hdr.fname);
    return;
end;
%read data
fid = fopen(hdr.fname,'r');
if  (hdr.dt(2) == 0)
    myformat = 'l'; %little-endian
else
    myformat = 'b'; %big-endian
end;    
fseek(fid, hdr.pinfo(3), 'bof');
img = fread(fid, myvox, myprecision, 0, myformat);
img = img(:).*hdr.pinfo(1)+hdr.pinfo(2); %apply scale slope and intercept
img = reshape(img,hdr.dim(1),hdr.dim(2),hdr.dim(3));
fclose(fid);
%end spm_read_volsSub()

% --- read VTK format mesh
function [vertex,face] = read_vtkSub(filename)
%   [vertex,face] = read_vtk(filename);
%   'vertex' is a 'nb.vert x 3' array specifying the position of the vertices.
%   'face' is a 'nb.face x 3' array specifying the connectivity of the mesh.
%   Copyright (c) Mario Richtsfeld, distributed under BSD license
% http://www.mathworks.com/matlabcentral/fileexchange/5355-toolbox-graph/content/toolbox_graph/read_vtk.m
fid = fopen(filename,'r');
if( fid==-1 )
    error('Can''t open the file.');
    return;
end
str = fgets(fid);   % -1 if eof
if ~strcmp(str(3:5), 'vtk')
    error('The file is not a valid VTK one.');    
end
% read header
str = fgets(fid);
str = fgets(fid);
str = fgets(fid);
str = fgets(fid);
nvert = sscanf(str,'%*s %d %*s', 1);
% read vertices
[A,cnt] = fscanf(fid,'%f %f %f', 3*nvert);
if cnt~=3*nvert
    warning('Problem in reading vertices.');
end
A = reshape(A, 3, cnt/3);
vertex = A;
% read polygons
str = fgets(fid);
str = fgets(fid);
info = sscanf(str,'%c %*s %*s', 1);
if((info ~= 'P') && (info ~= 'V'))
    str = fgets(fid);    
    info = sscanf(str,'%c %*s %*s', 1);
end
if(info == 'P')
        nface = sscanf(str,'%*s %d %*s', 1);
    [A,cnt] = fscanf(fid,'%d %d %d %d\n', 4*nface);
    if cnt~=4*nface
        warning('Problem in reading faces.');
    end
    A = reshape(A, 4, cnt/4);
    face = A(2:4,:)+1;
end
if(info ~= 'P')
    face = 0;
end
% read vertex indices
if(info == 'V')
    nv = sscanf(str,'%*s %d %*s', 1);
    [A,cnt] = fscanf(fid,'%d %d \n', 2*nv);
    if cnt~=2*nv
        warning('Problem in reading faces.');
    end
    A = reshape(A, 2, cnt/2);
    face = repmat(A(2,:)+1, 3, 1);
end
if((info ~= 'P') && (info ~= 'V'))
    face = 0;
end
fclose(fid);
%end read_vtkSub()

% --- save Face/Vertex data as VTK format file
function writeVtkSub(vertex,face,filename)
[nF nFd] =size(face);
[nV nVd] =size(vertex);
if (nF <1) || (nV <3 || (nFd ~=3) || (nVd ~=3)), warning('Problem with writeVtk'); return; end; 
fid = fopen(filename, 'wt');
fprintf(fid, '# vtk DataFile Version 3.0\n');
fprintf(fid, 'Comment: created with MATcro\n');
fprintf(fid, 'ASCII\n');
fprintf(fid, 'DATASET POLYDATA\n');
fprintf(fid, 'POINTS %d float\n',nV);
fprintf(fid, '%.12g %.12g %.12g\n', vertex');
fprintf(fid, 'POLYGONS %d %d\n',nF, nF*(nFd+1));
fprintf(fid, '3 %d %d %d\n', (face-1)');
fclose(fid);
%end save_vtkSub()

% --- threshold for converting continuous brightness to binary image using Otsu's method.
function [thresh] = otsuSub(I)
% BSD license: http://www.mathworks.com/matlabcentral/fileexchange/26532-image-segmentation-using-otsu-thresholding
% Damien Garcia 2010/03 http://www.biomecardio.com/matlab/otsu.html
nbins = 256;
if (min(I(:)) == max(I(:)) ), disp('otu error: no intensity variability'); thresh =min(I(:)); return; end; 
intercept = min(I(:)); %we will translate min-val to be zero
slope = (nbins-1)/ (max(I(:))-intercept); %we will scale images to range 0..(nbins-1)
%% Convert to 256 levels
I = round((I - intercept) * slope);
%% Probability distribution
[histo,pixval] = hist(I(:),256);
P = histo/sum(histo);
%% Zeroth- and first-order cumulative moments
w = cumsum(P);
mu = cumsum((1:nbins).*P);
sigma2B =(mu(end)*w(2:end-1)-mu(2:end-1)).^2./w(2:end-1)./(1-w(2:end-1));
[maxsig,k] = max(sigma2B);
thresh=    pixval(k+1);
if (thresh >= nbins), thresh = nbins-1; end;
thresh = thresh/slope + intercept;
%end otsuSub()