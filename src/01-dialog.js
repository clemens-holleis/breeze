function run(input, parameters) {
    var app = Application.currentApplication()
    var argsArray = input.map(x => x.toString())
    app.includeStandardAdditions = true

    if (input.length == 0) {
        return ["start app"]
    }

    if (input.length == 1) {
        const pathToBlender = Path(input[0].toString() + '/Contents/MacOS/Blender');
        const status = Application("Finder").exists(pathToBlender);
        if (status) {
            var app = Application.currentApplication()
            app.includeStandardAdditions = true

            var dialogText = "Setting Blender Version to:\n" + input[0].toString()
            app.displayDialog(dialogText, {
                    buttons: ["Cancel", "Change Blender Version"],
                    defaultButton: "Change Blender Version",
                    cancelButton: "Cancel"
                })
                // Result: {"buttonReturned":"Continue"}

            return ["set blender", ...argsArray]
        }
        return ["single file", ...argsArray]
    }

    var availableModes = ["merge", "blender instances"]
    var selectedMultiMode = app.chooseFromList(availableModes, {
        withPrompt: "Process multiple files:",
        defaultItems: ["merge"]
    })

    return [selectedMultiMode.toString(), ...argsArray];
}