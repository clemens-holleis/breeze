function run(input, parameters) {
    const app = Application.currentApplication()
    const argsArray = input.map(x => x.toString())
    app.includeStandardAdditions = true

    if (input.length == 0) {
        return ["start app"]
    }

    if (input.length == 1) {
        const arg = input[0].toString()
        const pathToBlender = Path(`${arg}/Contents/MacOS/Blender`)
        const status = Application("Finder").exists(pathToBlender);
        if (status) {
            const dialogText = "Setting Blender Version to:\n" + input[0].toString()
            app.displayDialog(dialogText, {
                buttons: ["Cancel", "Change Blender Version"],
                defaultButton: "Change Blender Version",
                cancelButton: "Cancel"
            })
            return ["set blender", ...argsArray]
        }
        return ["single file", ...argsArray]
    }

    const availableModes = ["merge", "blender instances"]
    const selectedMultiMode = app.chooseFromList(availableModes, {
        withPrompt: "Process multiple files:",
        defaultItems: ["merge"]
    })

    return [selectedMultiMode.toString(), ...argsArray];
}