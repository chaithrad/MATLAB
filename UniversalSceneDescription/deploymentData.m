function deploymentData(filePath, fromLayer, toLayer)
projectRoot = pwd;
expr = '/p(\d+)/';
tokens = regexp (filePath, expr, 'tokens');
id=tokens(1, 1)(1,1);
targetDir = fullfile (projectRoot, 'data');
folder Nmae = ['p',id];
mkdir([fullfile(targetDir, [folderNmae,'/Inputs']),'/deployment'])
targetFolderToSave = s']),'/deployment'];

% from node
fromNodesLen = length(fromLayer.Deployment.xyPositions);
fromNodes = struct([]);
% tonodes
toNodesLen = length(toLayer.Deployment.xyPositions);
toNodes = struct([]);

% Open file for writing
fidTo = fopen([fullfile(targetFolderToSave, 'toNodes.json')], 'w');
if fidTo-1
    error('Cannot open file for writing.');
end
fprintf(fidTo, '(\n "toNodes": [\n');

for k = 1:toNodesLen
    x = real(toLayer.Deployment.xyPositions(k));
    y = imag(toLayer.Deployment.xyPositions(k));
    z = tolayer.Deployment.zPositions(k);
    fprintf(fidTo, {\n "position": [%g, %g, %g]\n }', x, y, z);
    
    % Add comma if not the last node
    if k = toNodesLen
        fprintf(fidTo, ', \n');
    else
        fprintf(fidTo, '\n');
    end

end

% Write closing of JSON
fprintf(fidTo, ' ]\n}\n');
fclose(fidTo);

% Open file for writing
fidFrom = fopen([fullfile(targetFolderToSave, 'fromNodes.json')], 'w');
if fidFrom == -1
    error('Cannot open file for writing.');
end

fprintf(fidFrom, '{\n "fromNodes": [\n');

for k = 1:fromNodesLen
    xt = real(fromLayer.Deployment.xyPositions(k));
    yt = imag(fromLayer.Deployment.xyPositions(k));
    zt = fromLayer.Deployment.zPositions(k);
    fromNodes(k).position = [xt, yt, zt];
    fprintf(fidFrom,'    {\n   "position": [%g, %g, %g]\n }', xt, yt, zt);

    % Add comma if not the last node
    if k~=fromNodesLen
        fprintf(fidFrom, ',\n');
    else
        fprintf(fidFrom, '\n');
    end
end

% Write closing of JSON
fprintf(fidFrom, ' ]\n}\n');
fclose(fidFrom);
disp('JSON file created successfully.');
