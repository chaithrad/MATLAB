function inPut(filePath)

projectRoot = pwd; expr = '/p(\d+)/';
tokens = regexp(filePath, expr, 'tokens');
id = tokens(1,1}{1,1);
targetDir = fullfile (projectRoot, 'data');
folderNmae = ['p',id,'/Inputs'];
targetFolderToFetch = fullfile(targetDir, folderNmae);

usdFile = fullfile([targetFolderToFetch, '/world'], [id,'.usd']);
materialFile = fullfile([targetFolderToFetch,'/world'], 'materials.json');

fromNodesFile = fullfile([targetFolderToFetch, '/deployment'], 'fromNodes.json');
fromNodesPath = 'fromNodes';
toNodesFile = fullfile([targetFolderToFetch, '/deployment'], 'toNodes.json');
toNodesPath = 'toNodes';

% Build structure
scenario.name = 'my_scenario';
scenario.world.USD = usdFile;
scenario.world.materials = materialFile;
scenario.deployment.from_nodes = fromNodesFile;
scenario.deployment.from_nodes_path = fromNodesPath;
scenario.deployment.to_nodes = toNodesFile;
scenario.deployment.to_nodes_path = toNodesPath;

% Convert to JSON string
jsonText = jsonencode(scenario, 'PrettyPrint', true);

% Save JSON file
scenarioFile = fullfile(targetFolderToFetch, 'my_scenario.json');
fid = fopen(scenarioFile, 'w');
1f fid == -1
    error('Cannot open file for writing: %s', scenarioFile);
end
fprintf(fid, '%s', jsonText);
fclose(fid);
disp(['Scenario JSON saved: ', scenarioFile]);

end