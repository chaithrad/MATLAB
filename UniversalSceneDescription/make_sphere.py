from pxr import Usd, UsdGeom

# createa new usd stage
stage = usd.Stage.CreateNew("sphere.usda")

# define the root xform
xform = UsdGeom.Xform.Define(stage, "/root")

# define a s phere under the root xform
sphere = UsdGeom.Sphere.Define(stage, "/root/sphere")
sphere.GetRadiusAttr().Set(1.0)

#save the stage to usd file
stage.GetRootLayer().Save()
print("USD file 'sphere.usda' created successfully.")   
