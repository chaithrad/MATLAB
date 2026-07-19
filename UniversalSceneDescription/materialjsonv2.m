function materialjsonv2(filePath)
projectRoot = pwd;
expr = '/p(\d+)/';
tokens = regexp(filePath, expr, 'tokens');
id=tokens(1,1}{1,1);
targetDir = fullfile(projectRoot, 'data');
folderNmae = ['p',id];
mkdir([fullfile(targetDir, [folderNmae, '/Inputs']), '/world'])
targetFolder ToSave = [fullfile(targetDir, [folderNmae, /Inputs']),'/world'];

Step 1: Define a table with all material properties
Material properties definitions for exporting 3D floorplans to OBJ files
% name              - Name of the material
% Id                - id of the material
% Surafec roughness - used for determining specular/diffuse
% abcd              - determining material parameters (permittivity and conductivity) from Rec. ITU-R P.2040-1 Table 3
% NS                - Specular exponent (specular highlight)
% Ka                - Ambient reflectivity (RBG colors)
% Ke                - Emissive coeficient (light emitted)
% N1                - Optical density (lights bends on material)
% d                 - Transparency
% illum             - Illumination model to use
% Layer Thickess    - Material tickness
% Plot color        - Meta data for plot
% Plot transperency - Meta Data for plot
% Kd                - Diffuse reflectivity (RGB colors) (Visible color)
% Ks                - Specular reflectivity (RGB colors)

MaterialData = { add your data here
}
numMaterials = size(MaterialData, 1);
fid = fopen([fullfile(targetFolderToSave, 'materials.json')], 'w');
fid = fopen('materials.json', 'w');
fprintf(fid, '{\n "allow_modify_existing_materials": false, \n "Materials": [\n');
for i = 1:numMaterials
    fprintf(fid, '   {\n');
    fprintf(fid, '   "name": "%s", \n', MaterialData{1,1});
    fprintf(fid, '   "Id": %d, \n', MaterialData{1,2});
    fprintf(fid, '   "SurfaceRoughness": %.6g, \n', MaterialData{1,3});

    %Abcd force horizontal
    abcd = MaterialData{1,4}(:)';
    fprintf(fid, '   "abcd": [%g, %g, %g, %g], \n', abcd);
    fprintf(fid, '    "Ns": %.6g, \n', MaterialData(1,5});

    % ka force horizontal
    Ka = MaterialData{1,6}(:)';
    fprintf(fid, '    "Ka": [%g, %g, %g], \n', Ka);

    %ke force horizontal
    Ke = MaterialData{1,7}(:)';
    fprintf(fid, '    "Ke": [%g, %g, %g], \n', Ke);
    fprintf(fid, '    "Ni": %.6g, \n', MaterialData{1,8});
    fprintf(fid, '    "D": %.6g, \n', MaterialData(1,9});
    fprintf(fid, '    "Dtramp": %.6g, \n', MaterialData(1,1
    fprintf(fid, '    "Illum": %.6g, \n', MaterialData{1,11});
    fprintf(fid, '    "Layer Thickness": %.6g, \n', MaterialData(1,12});

    %PlotColor force horizontal
    plotColor = MaterialData{1,13)(:)'; 
    fprintf(fid, '    "PlotColor": [%g, %g, %g], \n', plotColor);
    fprintf(fid, '    "PlotTransparency": %.6g, \n', MaterialData(1,14});   
    
    % ka  -  force horizontal
    Kd = MaterialData{1,15)(:)';
    fprintf(fid, '    "Kd": [%g, %g, %g], \n', Kd);
    
    % ka force horizontal
    KS = MaterialData{1,16}(:)';
    fprintf(fid, '    "Ks": [%g, %g, %g]\n', Ks);
    if i < numMaterials
        fprintf(fid,' }, \n');
    else
        fprintf(fid,' }\n'); % last material
    end
end

fprintf(fid, ' ]\n}\n');
fclose(fid);

disp('materials.json generated successfully.');
end