% get current python environment
p = pyenv;

% if python is not loaded,set it up
if p == "NotLoaded"
    pyenv('Version', 'C:\Users\YourUsername\AppData\Local\Programs\Python\Python39\python.exe'); % specify your python path
end

% add current folder to python path if needed
if count(py.sys.path, pwd) == 0
    insert(py.sys.path, int32(0), pwd);
end

% example: call function from hello.py
msg = py.hello.say_hello('World');   
disp(msg);

% call python script from MATLAB
%scriptPath = fullfile('c:\path\to\your\make_sphere.py'); % specify your script path
%pyExec = fullfile(getenv('Home','yourpythonFolder','bin','python3'))
%system(sprintf('"%s" "%s"',pyExec,scriptPath));