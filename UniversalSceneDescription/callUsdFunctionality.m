function callUsdFunctionlaity(polygonData, filename)
%usdTrianngles = Map.triangles;
%usdTrianngles.materialTypes = Map.polygons.materialTypes;
%mappingMatrerial = Map.triangles.idPoly;
%usdTrianngles.wallMaterialIdx = Map.polygons.wallMaterialIdx(mappingMatrerial);
%usdTrianngles.wallType = Map.polygons.wallType(mappingMatrerial);
%callUsdFunctionlaity(usdTrianngles, filename{1}); % triangle

%Full path to your Python interpreter inside $HOME/mypython39 
pyExec fullfile(getenv('HOME'), 'mypython39', 'bin', 'python3');
p = pyenv;

% If Python is not loaded, set it up
if p.status == "NotLoaded"
    pyenv('Version', '/home/zchadxx/mypython39/bin/python3.9');
end
disp('Python Version');
disp('py.sys.version');

%Path to my script
%scriptPath = fullfile(getenv('HOME'), 'make_sphere.py'); 
scriptPath = fullfile(pwd, 'generateUSD.py');

% Call Python script from MATLAB
system(sprintf("%s" "%s", pyExec, scriptPath));

nFloors = numel(polygonData);
floor_data_list = py.list();


for i = 1:nFloors
    % Vertices
    verts = polygonData(i).vertices;
    % M x 3 double
    py_verts = py.list();
    % empty python list
    forr 1:size(verts, 1)
        py_row = py.list(num2cell(verts(r,:)));
        % convert 1x3 row to Python list
        py_verts.append(py_row);
    end
    % triangle
    fcs = polygonData(1).faces;
    py_faces= py.list();
    for f= 1:size(fcs,1)
        py_face = py.list(int32(fcs(f,:)-1));% 0-based
        py_faces.append(py_face);
    end
    
    %-- ids---
    py_wall_type_ids = py.list(int32(polygonData(1).wallType));
    wallTypeorg = polygonData.wallMaterialIdx;
    feildsData = fieldnames (polygonData.materialTypes);
    for nfieldId = 1: numel (feildsData)
        oldVal(1,nfieldId) = polygonData.materialTypes. (feildsData{nfieldId)).idx;
    end
    newVal = unique(wallTypeOrg, 'stable');

    [tf,loc] = ismember(polygonData.wallMaterialIdx, newVal);
    polygonData.wallMaterialIdx = oldval(loc)';
    py_wall_material_ids = py.list(int32(polygonData(1).wallMaterialIdx));

    %  Get field names (material names)

%fieldsData = ('plasterBoard', 'thickPlasterBoard', 'standardGlass', 'heavyConcrete', 'mediumConcrete', 'brick', 'open', 'metalCoatedGlass', 'metal', 'wood', 'lightConcrete', 'thickConcrete', 'customFloor', 'ceiling');

fieldsData = {'Plasterboard_ITU_R_P2040_2', 'thickPlasterBoard', 'standardGlass', 'Concrete_outer_wall', 'mediumConcrete', 'brick', 'open', 'metalCoatedGlass', 'metal', 'Wood_ITU_R_P2040_2', 'lightConcrete', 'thickConcrete', 'Concrete_floor_and_ceiling', 'ceiling'};

% fieldsData = ('Concrete_outer_wall', 'Brick_outer_wall', 'Concrete_floor_and_ceiling', 'Concrete_roof', 'Two_pane_glass_window'....

IRR_glass_window', 'Ground_grass_and_dirt', 'Ground_roads_and_pavement', 'PEC', 'PEC_rough', 'Air',...

'Low_loss_outer_wall', 'High_loss_outer_wall'};

% Create empty Python dict
py_mat_dict = py.dict();

for k = 1:numel(fieldsData)
    mat_name= fieldsData{k};%e.g., 'HeavyConcrete'
    mat id =k; %e.g., 1
    py_mat_dict(int32(mat_id)) = mat_name;% key: material ID (int), value: material name (string)
end

py_foliage_faces= py.list();
py_ignore_diff_faces= py.list();

% --- Floor dict ---
floor_dict = py.dict(pyargs(...
            "vertices", py_verts,...
            "faces", py faces,
            "wall_type_ids", py_wall_type_ids,
            "wall_material_ids", py wall_material_ids,
            "material_dict", py_mat_dict,
            "foliage_faces", py_foliage_faces,
            "ignore_diff_faces", py_ignore_diff_faces
));

%Append to list
floor_data_list.append(floor_dict);
end

%call Python
projectRoot = fileparts (mfilename('fullpath'));
if count(py.sys.path, projectRoot) == 0
    insert(py.sys.path, int32(0), projectRoot);
end

parts = split(filename, {'/','_'});
id = parts{end-1};
opFileName = [id, '.usda'];
targetDir = fullfile(projectRoot, 'data');
folderNmae = ['p',id];
mkdir([fullfile(targetDir, [folderNmae, '/Inputs'])])
mkdir([fullfile(targetDir, [folderNmae, '/Inputs']), '/world'])
targetFolder ToSave = [fullfile(targetDir, [folderNmae, /Inputs']), '/world');
output_file = fullfile(targetFolderToSave, opFileName);

%material json save
materialJsonV2(filename);

output_file = fullfile (projectRoot, 'building.usda');
py.CreateUSDEnv.generate_usd(floor_data_list, output_file, true, true);
disp('USD generation complete.');

end
