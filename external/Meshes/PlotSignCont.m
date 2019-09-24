%code from Athina Tzovara, adapted by Veronika Shamova on 11/07/2018

fname_allmeshes =  ['\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\Veronika_iEEG_project\external\Meshes\Hipp_Amy_templates.gii'];

% MNI coordinates (xyz) for different effects:
% Eff1 = [-30.48566247	-4.959895486	-19.65436093;
%     -33.3986408	-11.62971024	-18.86903322;
%     40.84277282	-32.61979709	-13.67253332;
%     -28.51770569	-1.348562206	-21.10976845;
%     39.43477153	-15.69086423	-15.68423997];
% 
% Eff2 = [-30.48566247	-4.959895486	-19.65436093;
%     35.45051674	-31.20315641	-14.24500971;
%     -27.48260585	-3.704067145	-20.95122964;
%     -31.71809741	-2.915189654	-22.97462259
%     ];
% 
% Eff3 = [
%     ];
% colours for different effects:

Eff1 = [32.5	 -8.6	 -16.9;
    33.4	 1.3	 -25.1;
    38.1	 2.5	 -24.1;
    -32.6	 -6.1	 -11.1;
    -37.9	 -6.2	 -11.0;
    -31.7	 4.9	 -15.5;
    -36.3	 5.4	 -14.4;];
Eff2 = [-25.3	 16.6	 -21.9;
    -26.2	 17.1	 -21.1;
    -25.9	 15.4	 -21.9;
    24.3	 11.6	 -15.6;
    28.6	 12.3	 -17.9];
Eff3 = [];
col1 = [141,160,203]./256; % mesh colour
color_Eff1 = [217,95,2]./256; % effect1
color_Eff2 = [27,158,119]./256; % effect2
color_Eff3 = [153,112,171]./245; % effect3

close all

% First plot the meshes:
figure
MATcro('openLayer',{fname_allmeshes}); hold on;
MATcro('layerRGBA', 1, col1(1), col1(2),col1(3),0.2)
MATcro('setView', 180, 0); %rotate azimuth, constant elevation
ssize = 120;

% Then, plot the contacts according to MNI coordinates and on top of that
% plot significant effects:
if ~isempty(Eff1)
    for con = 1:size(Eff1,1)
        scatter3(Eff1(con,1), Eff1(con,2), Eff1(con,3), ssize, color_Eff1,'fill')
    end
end

if ~isempty(Eff2)
    for con = 1:size(Eff2,1)
        scatter3(Eff2(con,1), Eff2(con,2), Eff2(con,3), ssize, color_Eff2,'fill')
    end
end

if ~isempty(Eff3)
    for con = 1:size(Eff2,1)
        scatter3(Eff2(con,1), Eff2(con,2), Eff2(con,3), ssize, color_Eff3,'fill')
    end
end



