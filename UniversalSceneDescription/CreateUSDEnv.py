import os
import json
from pxr import usd, USDGeom, USDShade,sdf, Gf

def santize_name(name):
    """Ensure USD-safe prim names."""
    return str(name).replace(" ","_").replace("-","_")

def generate_usd(floor_data_list,output_file = "building_extended.usda",also_binary=True,use_only_materials_name = True):
    """
    Generate a USD with Root/world, foliage,ignoreDiffraction,
    and material sunsets.

    floor_data_list = [
        {
            'vertices': [[x,y,z], ...],
            'faces': [[v1.v2,v3, ...], ...],
            'wall_material_ids': [id1,id2, ...],
            'materials_dict': {id:,'name', ...},
            'folliage_faces': [...], # optional list of faces indices
            'ignore_diff_faces':[...] 
        },
        ...
    ]
    """

    # --- if filealready exists, remove it
    if os.path.exists(output_file):
        os.remove(output_file)

    # -- Load json --
    if not use_only_material_name:
        with open("material.json","r") as f:
            mat_data = json.load(f)

    # ---- create USD stage ----
    stage = Usd.Stage.CreateNew(output_file)

    # --- Root/prim ---
    root_xform = UsdGeom.Xform.Define(stage, "/Root/World")
    stage.SetDefaultPrim(root_form.GetPrim()) 
    
    stage.GetRootLayer().customLayerData = {
        " cameraSettings": {
            "Front": {
                "position": Gf.Vec3d(500.0, 0.0, 0.0), # tuple of numbers 
                "radius": 500.0
            },
            "Right": {
                "position": Gf.Vec3d(0.0, -500.0, 0.0), # tuple of numbers 
                "radius": 500.0
            },
           "Top": {
                "position": Gf. Vec3d(0.0, 0.0, 500.0), # tuple of numbers
                "radius": 500.0
            }, 
            "Perspective": {
                "position": Gf. Vec3d(219.36661124640295, 176.17653341951657, 131.4138445756818), # tuple of numbers 
                "target": Gf.Vec3d(43.71427974973375, 0.5242019228474248, 44.23848272847698), # tuple of numbers
            },
            "boundCamera": "/OmniverseKit_Persp"
        },
        "omni_layer": {"authoring_layer": f"./{os.path.basename(output_file)}"},
        "renderSettings": {}
    }

    # -- World under root ---
    world_xform = UsdGeom.Xform.Define(stage, "/Root")

    # --- optional extended scopes --- 
    ignore_diff_scope =  UsdGeom.Scope.Define("/Root/ignoreDiffraction")
    foliage_scope = UsdGeom.Scope.Define("/Root/folliage")

    # --- Define materials once ---
    if not use_only_material_name:
        all_materials = {}
        for mat in mat_data["Materials"]:
            mat_id = int(mat["Id"])
            mat_name = mat["name"]
            
            #Safe name for USD path
            safe_name = mat_name.replace("", "_") # or use your sanitize_name function
            
            mat_path = f"/Root/Materials/{safe_name}"

            # Define material
            usd_mat = UsdShade.Material.Define(stage, mat_path)

            # Define shader
            shader = UsdShade.Shader.Define(stage, f"{mat_path}/Shader")
            shader.CreateIdAttr("UsdPreviewSurface")
            shader_output = shader.CreateOutput("surface", Sdf. ValueTypeNames.Token)
            usd_mat.CreateSurfaceOutput().ConnectToSource(shader_output)

            #--- Add EM / visual parameters as inputs
            param_fields = ["Surface Roughness", "abcd", "Ns", "Ka", "Ke", "Ni", "D", "Dtramp", "Illum", "LayerThickness", "PlotColor", "PlotTransparency", "Kd", "Ks"]

            for field in param_fields:
                if field in mat:
                    value = mat [field]
                    #Decide type: list FloatArray, single number = Float
                    if isinstance(value, list):
                        #If length 3 or 4, use appropriate sdf type
                        if len(value) == 3:
                            usd_mat.CreateInput(field, Sdf.ValueTypeNames.Color3f).set(Gf. Vec3f(value))
                        elif len(value) == 4:
                            usd_mat.CreateInput(field, Sdf.ValueTypeNames.Float4).Set(Gf. Vec4f(value))
                        else:
                            usd_mat.CreateInput(field, Sdf.ValueTypeNames.FloatArray).Set(value)

                    else:
                        usd_mat.CreateInput(field, Sdf.ValueTypeNames.Float).set(value)
            
            #Store in dict by ID
            all_materials[mat_id] = usd_mat

        #print("All materials defined successfully from materials.json!")

    # Define only materials once...
    if use_only_material_name:
        all_materials = {}
        if len(floor_data_list) > 0:
            sample_dict = floor_data_list[0]['material_dict']
            for mat_id, mat_name in sample_dict.items():
                safe_name = sanitize_name(mat_name)
                mat_path = f"/Root/Materials/{safe_name}"
                mat = UsdShade.Material.Define(stage, mat_path)
                shader = UsdShade.Shader.Define(stage, f"{mat_path}/Shader")
                shader.CreateIdAttr("UsdPreviewSurface")
                shader_output = shader.CreateOutput("surface", Sdf.ValueTypeNames.Token)
                mat.CreateSurfaceOutput().ConnectToSource(shader_output)
                all_materials [int(mat_id)] = mat
                
    #--- Process each floor
    for floor_idx, floor_data in enumerate (floor_data_list, start=1):
        verts = [tuple(v) for v in floor_data['vertices']]
        faces = [list(f) for f in floor_data['faces']]
        wall_material_ids = floor_data['wall_material_ids']
        foliage_faces = set(floor_data.get('foliage_faces', []))
        ignore_diff_faces = set(floor_data.get('ignore_diff_faces', []))

        # --- Main building mesh ---
        mesh = UsdGeom.Mesh.Define(stage, f"/Root/World/Building_{floor_idx}_Mesh") 
        mesh.GetPointsAttr().Set(verts)
        faceVertexCounts = [len(f) for f in faces]
        faceVertexIndices = [idx for f in faces for idx in f]
        mesh.GetFaceVertexCountsAttr().Set(faceVertexCounts)
        mesh.GetFaceVertexIndicesAttr().Set(faceVertexIndices)
        
        #added later
        UsdShade.MaterialBindingAPI.Apply(mesh.GetPrim())
        UsdShade.Material. Define(stage, "/Root/Materials/Concrete_outer_wall")
        mainBindingRel = mesh.GetPrim().CreateRelationship("material:binding", False)
        mainBindingRel.SetTargets([])
        mainBindingRel.SetTargets ([Sdf.Path("/Root/Materials/Concrete_outer_wall")])
        mainBindingRel.SetMetadata("bindMaterialAs", "weaker ThanDescendants")

        # -- Subsets per material
        if not use_only_material_name:
            #Create lookup dictionary from material Id material data
            material_lookup = {int(m["Id"]): m for m in mat_data["Materials"]}
        
        mat_to_faces= {}
        for idx, mat_id in enumerate(wall_material_ids):
            mat_to_faces.setdefault(int(mat_id), []).append(idx)
        
        for mat_id, face_indices in mat_to_faces.items():
            if use_only_material_name:
                mat_name= sanitize_name(floor_data['material_dict'].get(mat_id, f"mat_{mat_id}"))
            else:
                #mat_name = sanitize_name(all_materials[mat_id].GetName())
                mat_name = sanitize_name(material_lookup.get(mat_id, {"Name": f"mat_{mat_id}"})["name"])
                
            subset_path = Sdf.Path(f"/Root/World/Building_{floor_idx}_{mat_name}_subset")
            
            subset = UsdGeom.Subset.Define(stage, Sdf. Path(subset_path))
            subset.createElementTypeAttr("face")
            subset.CreateIndicesAttr(face_indices)
            UsdShade.MaterialBindingAPI(subset.GetPrim()).Bind(all_materials [mat_id])
            bindingRel = subset.GetPrim().GetRelationship("material:binding")
            if bindingRel:
                bindingRel.SetMetadata("bindMaterialAs", "stronger Than Descendants")
            if mat_name == 'Concrete_outer_wall':
                subset.GetPrim().SetMetadata("active", True)
            
        #-Foliage mesh
        if foliage_faces:
            foliage_mesh = UsdGeom.Mesh.Define(stage, f"/Root/foliage/Building_{floor_idx}_FoliageMesh")
            foliage_mesh.GetPointsAttr().Set(verts)
            foliage_mesh.GetFaceVertexCountsAttr().Set([len (faces[1]) for i in foliage_faces])
            foliage_mesh.GetFaceVertexIndicesAttr().Set([idx for i in foliage_faces for idx in faces[1]])
        
        #-IgnoreDiffraction mesh
        if ignore_diff_faces:
            ignore_mesh = UsdGeom.Mesh. Define(stage, f"/Root/ignoreDiffraction/Building_{floor_idx}_IgnoreMesh")
            ignore_mesh.GetPointsAttr().Set(verts)
            ignore_mesh.GetFaceVertexCountsAttr().set([len(faces[1]) for i in ignore_diff_faces])
            ignore_mesh.GetFaceVertexIndicesAttr().Set([idx for i in ignore_diff_faces for idx in faces[1]])

    #--- Set Z-up axis ---
    UsdGeom.SetStageUpAxis(stage, UsdGeom.Tokens.z)

    #--- Set metersPerUnit ---
    UsdGeom.SetStageMetersPerUnit(stage, 1.0)
    
    # Optionally also save binary USD (.usd)
    if also_binary:
        usd_binary = output_file.replace(".usda", ".usd")
        stage.GetRootLayer().Export(usd_binary)
        print(f"USD Binary file generated: {usd_binary}")

    #--- Save USD
    stage.GetRootLayer().Save()
    print(f"USD generated: {output_file}")

