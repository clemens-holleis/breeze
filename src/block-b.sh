blender_python_script=$(
    cat <<"EOF"
import uuid
import bpy
import sys
from pathlib import Path




if "--" in sys.argv:
    args = sys.argv[sys.argv.index('--')+1:]

    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)


    for file in args:

        ext = file.rsplit('.')[-1].lower()

        if ext in ('blend'):
            bpy.ops.wm.open_mainfile(filepath=file)

        if ext in ('glb','gltf'):
            bpy.ops.import_scene.gltf(filepath=file)

        if ext in ('obj'):
            bpy.ops.import_scene.obj(filepath=file)

        if ext in ('fbx'):
            bpy.ops.import_scene.fbx(filepath=file)

        if ext in ('ply'):
            bpy.ops.import_mesh.ply(filepath=file)

        if ext in ('abc'):
            bpy.ops.wm.alembic_import(filepath=file)

        if ext in ('svg'):
            bpy.ops.import_curve.svg(filepath=file)

        if ext in ('dae'):
            bpy.ops.wm.collada_import(filepath=file)

        if ext in ('bvh'):
            bpy.ops.import_anim.bvh(filepath=file)

        if ext in ('stl'):
            bpy.ops.import_mesh.stl(filepath=file)

        if ext in ('x3d','wrl'):
            bpy.ops.import_scene.x3d(filepath=file)


        # create collection with the relative path as the name
        file_path = Path(file).absolute()
        home_dir = Path('~').expanduser()
        collection_name = f"~/{file_path.relative_to(home_dir)}"
        collection_name = str(uuid.uuid5(uuid.NAMESPACE_DNS,collection_name))

        collection = bpy.data.collections.new(collection_name)
        bpy.context.scene.collection.children.link(collection)

        # newly imported models will be selected
        for obj in bpy.context.selected_objects:

            # remove them from main collection
            for other_col in obj.users_collection:
                other_col.objects.unlink(obj)

            # add them to the new collection
            if obj.name not in collection.objects:
                collection.objects.link(obj)



    for area in bpy.context.screen.areas: 
        if area.type == 'VIEW_3D':
            for space in area.spaces: 
                if space.type == 'VIEW_3D':
                    space.shading.type = 'MATERIAL'


    bpy.ops.object.select_all(action='DESELECT')


EOF
)

# default Blender installation existance should be verified in JS to give feedback to the user
blender_default_exe=/Applications/Blender.app/Contents/MacOS/Blender

# The first argument coming from JS is the mode
# put it in a variable and remove it from the args list
# $@ should only contain the files after this
MODE=$1
shift

app_data_folder="$HOME/Library/Application Support/Breeze"
script_file=$app_data_folder/loading-script.py

# create files and folders if needed
[ ! -d "$app_data_folder" ] && mkdir "$app_data_folder"
[ ! -f "$app_data_folder/blender_exe.txt" ] && echo $blender_default_exe >"$app_data_folder/blender_exe.txt"


echo $blender_python_script >$script_file
blender_exe=$(<$app_data_folder/blender_exe.txt)


case "$MODE" in
"start app")
    nohup $blender_exe >/dev/null 2>&1 &
    ;;
"merge")
    nohup $blender_exe --python "$script_file" -- $@ >/dev/null 2>&1 &
    ;;
"blender instances")
    for file in "$@"; do
        nohup $blender_exe --python "$script_file" -- "$file" >/dev/null 2>&1 &
    done
    ;;
"single file")
    nohup $blender_exe --python "$script_file" -- "$1" >/dev/null 2>&1 &
    ;;
"set blender")
    # set the desired blender executable
    blender_exe="$1/Contents/MacOS/Blender"
    echo $blender_exe >$app_data_folder/blender_exe.txt
    ;;
*)
    echo unknown
    ;;
esac
