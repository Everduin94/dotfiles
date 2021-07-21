'use strict';
var vscode = require('vscode');
var path = require('path');
var fs = require('fs');
var fse = require('fs-extra');
var child_process_1 = require('child_process');
var moment = require('moment');
var upath = require('upath');
var Logger = (function () {
    function Logger() {
    }
    Logger.log = function (message) {
        if (this.channel) {
            var time = moment().format("MM-DD HH:mm:ss");
            this.channel.appendLine("[" + time + "] " + message);
        }
    };
    Logger.showInformationMessage = function (message) {
        var items = [];
        for (var _i = 1; _i < arguments.length; _i++) {
            items[_i - 1] = arguments[_i];
        }
        this.log(message);
        return (_a = vscode.window).showInformationMessage.apply(_a, [message].concat(items));
        var _a;
    };
    Logger.showErrorMessage = function (message) {
        var items = [];
        for (var _i = 1; _i < arguments.length; _i++) {
            items[_i - 1] = arguments[_i];
        }
        this.log(message);
        return (_a = vscode.window).showErrorMessage.apply(_a, [message].concat(items));
        var _a;
    };
    return Logger;
}());
function activate(context) {
    Logger.channel = vscode.window.createOutputChannel("PasteImage");
    context.subscriptions.push(Logger.channel);
    Logger.log('Congratulations, your extension "vscode-paste-image" is now active!');
    var disposable = vscode.commands.registerCommand('extension.pasteImage', function () {
        try {
            Paster.paste();
        }
        catch (e) {
            Logger.showErrorMessage(e);
        }
    });
    context.subscriptions.push(disposable);
}
exports.activate = activate;
function deactivate() {
}
exports.deactivate = deactivate;
var Paster = (function () {
    function Paster() {
    }
    Paster.paste = function () {
        // get current edit file path
        var editor = vscode.window.activeTextEditor;
        if (!editor)
            return;
        var fileUri = editor.document.uri;
        if (!fileUri)
            return;
        if (fileUri.scheme === 'untitled') {
            Logger.showInformationMessage('Before paste image, you need to save current edit file first.');
            return;
        }
        var filePath = fileUri.fsPath;
        var folderPath = path.dirname(filePath);
        var projectPath = vscode.workspace.rootPath;
        // get selection as image file name, need check
        var selection = editor.selection;
        var selectText = editor.document.getText(selection);
        if (selectText && /[\\:*?<>|]/.test(selectText)) {
            Logger.showInformationMessage('Your selection is not a valid file name!');
            return;
        }
        // load config pasteImage.defaultName
        this.defaultNameConfig = vscode.workspace.getConfiguration('pasteImage')['defaultName'];
        if (!this.defaultNameConfig) {
            this.defaultNameConfig = "Y-MM-DD-HH-mm-ss";
        }
        // load config pasteImage.path
        this.folderPathConfig = vscode.workspace.getConfiguration('pasteImage')['path'];
        if (!this.folderPathConfig) {
            this.folderPathConfig = "${currentFileDir}";
        }
        if (this.folderPathConfig.length !== this.folderPathConfig.trim().length) {
            Logger.showErrorMessage("The config pasteImage.path = '" + this.folderPathConfig + "' is invalid. please check your config.");
            return;
        }
        // load config pasteImage.basePath
        this.basePathConfig = vscode.workspace.getConfiguration('pasteImage')['basePath'];
        if (!this.basePathConfig) {
            this.basePathConfig = "";
        }
        if (this.basePathConfig.length !== this.basePathConfig.trim().length) {
            Logger.showErrorMessage("The config pasteImage.path = '" + this.basePathConfig + "' is invalid. please check your config.");
            return;
        }
        // load other config
        this.prefixConfig = vscode.workspace.getConfiguration('pasteImage')['prefix'];
        this.suffixConfig = vscode.workspace.getConfiguration('pasteImage')['suffix'];
        this.forceUnixStyleSeparatorConfig = vscode.workspace.getConfiguration('pasteImage')['forceUnixStyleSeparator'];
        this.forceUnixStyleSeparatorConfig = !!this.forceUnixStyleSeparatorConfig;
        this.encodePathConfig = vscode.workspace.getConfiguration('pasteImage')['encodePath'];
        this.namePrefixConfig = vscode.workspace.getConfiguration('pasteImage')['namePrefix'];
        this.nameSuffixConfig = vscode.workspace.getConfiguration('pasteImage')['nameSuffix'];
        this.insertPatternConfig = vscode.workspace.getConfiguration('pasteImage')['insertPattern'];
        this.showFilePathConfirmInputBox = vscode.workspace.getConfiguration('pasteImage')['showFilePathConfirmInputBox'] || false;
        this.filePathConfirmInputBoxMode = vscode.workspace.getConfiguration('pasteImage')['filePathConfirmInputBoxMode'];
        // replace variable in config
        this.defaultNameConfig = this.replacePathVariable(this.defaultNameConfig, projectPath, filePath, function (x) { return ("[" + x + "]"); });
        this.folderPathConfig = this.replacePathVariable(this.folderPathConfig, projectPath, filePath);
        this.basePathConfig = this.replacePathVariable(this.basePathConfig, projectPath, filePath);
        this.namePrefixConfig = this.replacePathVariable(this.namePrefixConfig, projectPath, filePath);
        this.nameSuffixConfig = this.replacePathVariable(this.nameSuffixConfig, projectPath, filePath);
        this.insertPatternConfig = this.replacePathVariable(this.insertPatternConfig, projectPath, filePath);
        // "this" is lost when coming back from the callback, thus we need to store it here.
        var instance = this;
        this.getImagePath(filePath, selectText, this.folderPathConfig, this.showFilePathConfirmInputBox, this.filePathConfirmInputBoxMode, function (err, imagePath) {
            try {
                // is the file existed?
                var existed = fs.existsSync(imagePath);
                if (existed) {
                    Logger.showInformationMessage("File " + imagePath + " existed.Would you want to replace?", 'Replace', 'Cancel').then(function (choose) {
                        if (choose != 'Replace')
                            return;
                        instance.saveAndPaste(editor, imagePath);
                    });
                }
                else {
                    instance.saveAndPaste(editor, imagePath);
                }
            }
            catch (err) {
                Logger.showErrorMessage("fs.existsSync(" + imagePath + ") fail. message=" + err.message);
                return;
            }
        });
    };
    Paster.saveAndPaste = function (editor, imagePath) {
        var _this = this;
        this.createImageDirWithImagePath(imagePath).then(function (imagePath) {
            // save image and insert to current edit file
            _this.saveClipboardImageToFileAndGetPath(imagePath, function (imagePath, imagePathReturnByScript) {
                if (!imagePathReturnByScript)
                    return;
                if (imagePathReturnByScript === 'no image') {
                    Logger.showInformationMessage('There is not a image in clipboard.');
                    return;
                }
                imagePath = _this.renderFilePath(editor.document.languageId, _this.basePathConfig, imagePath, _this.forceUnixStyleSeparatorConfig, _this.prefixConfig, _this.suffixConfig);
                editor.edit(function (edit) {
                    var current = editor.selection;
                    if (current.isEmpty) {
                        edit.insert(current.start, imagePath);
                    }
                    else {
                        edit.replace(current, imagePath);
                    }
                });
            });
        }).catch(function (err) {
            if (err instanceof PluginError) {
                Logger.showErrorMessage(err.message);
            }
            else {
                Logger.showErrorMessage("Failed make folder. message=" + err.message);
            }
            return;
        });
    };
    Paster.getImagePath = function (filePath, selectText, folderPathFromConfig, showFilePathConfirmInputBox, filePathConfirmInputBoxMode, callback) {
        // image file name
        var imageFileName = "";
        if (!selectText) {
            imageFileName = this.namePrefixConfig + moment().format(this.defaultNameConfig) + this.nameSuffixConfig + ".png";
        }
        else {
            imageFileName = this.namePrefixConfig + selectText + this.nameSuffixConfig + ".png";
        }
        var filePathOrName;
        if (filePathConfirmInputBoxMode == Paster.FILE_PATH_CONFIRM_INPUTBOX_MODE_PULL_PATH) {
            filePathOrName = makeImagePath(imageFileName);
        }
        else {
            filePathOrName = imageFileName;
        }
        if (showFilePathConfirmInputBox) {
            vscode.window.showInputBox({
                prompt: 'Please specify the filename of the image.',
                value: filePathOrName
            }).then(function (result) {
                if (result) {
                    if (!result.endsWith('.png'))
                        result += '.png';
                    if (filePathConfirmInputBoxMode == Paster.FILE_PATH_CONFIRM_INPUTBOX_MODE_ONLY_NAME) {
                        result = makeImagePath(result);
                    }
                    callback(null, result);
                }
                return;
            });
        }
        else {
            callback(null, makeImagePath(imageFileName));
            return;
        }
        function makeImagePath(fileName) {
            // image output path
            var folderPath = path.dirname(filePath);
            var imagePath = "";
            // generate image path
            if (path.isAbsolute(folderPathFromConfig)) {
                imagePath = path.join(folderPathFromConfig, fileName);
            }
            else {
                imagePath = path.join(folderPath, folderPathFromConfig, fileName);
            }
            return imagePath;
        }
    };
    /**
     * create directory for image when directory does not exist
     */
    Paster.createImageDirWithImagePath = function (imagePath) {
        return new Promise(function (resolve, reject) {
            var imageDir = path.dirname(imagePath);
            fs.stat(imageDir, function (err, stats) {
                if (err == null) {
                    if (stats.isDirectory()) {
                        resolve(imagePath);
                    }
                    else {
                        reject(new PluginError("The image dest directory '" + imageDir + "' is a file. please check your 'pasteImage.path' config."));
                    }
                }
                else if (err.code == "ENOENT") {
                    fse.ensureDir(imageDir, function (err) {
                        if (err) {
                            reject(err);
                            return;
                        }
                        resolve(imagePath);
                    });
                }
                else {
                    reject(err);
                }
            });
        });
    };
    /**
     * use applescript to save image from clipboard and get file path
     */
    Paster.saveClipboardImageToFileAndGetPath = function (imagePath, cb) {
        if (!imagePath)
            return;
        var platform = process.platform;
        if (platform === 'win32') {
            // Windows
            var scriptPath = path.join(__dirname, '../../res/pc.ps1');
            var command = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe";
            var powershellExisted = fs.existsSync(command);
            if (!powershellExisted) {
                command = "powershell";
            }
            var powershell = child_process_1.spawn(command, [
                '-noprofile',
                '-noninteractive',
                '-nologo',
                '-sta',
                '-executionpolicy', 'unrestricted',
                '-windowstyle', 'hidden',
                '-file', scriptPath,
                imagePath
            ]);
            powershell.on('error', function (e) {
                if (e.code == "ENOENT") {
                    Logger.showErrorMessage("The powershell command is not in you PATH environment variables.Please add it and retry.");
                }
                else {
                    Logger.showErrorMessage(e);
                }
            });
            powershell.on('exit', function (code, signal) {
                // console.log('exit', code, signal);
            });
            powershell.stdout.on('data', function (data) {
                cb(imagePath, data.toString().trim());
            });
        }
        else if (platform === 'darwin') {
            // Mac
            var scriptPath = path.join(__dirname, '../../res/mac.applescript');
            var ascript = child_process_1.spawn('osascript', [scriptPath, imagePath]);
            ascript.on('error', function (e) {
                Logger.showErrorMessage(e);
            });
            ascript.on('exit', function (code, signal) {
                // console.log('exit',code,signal);
            });
            ascript.stdout.on('data', function (data) {
                cb(imagePath, data.toString().trim());
            });
        }
        else {
            // Linux 
            var scriptPath = path.join(__dirname, '../../res/linux.sh');
            var ascript = child_process_1.spawn('sh', [scriptPath, imagePath]);
            ascript.on('error', function (e) {
                Logger.showErrorMessage(e);
            });
            ascript.on('exit', function (code, signal) {
                // console.log('exit',code,signal);
            });
            ascript.stdout.on('data', function (data) {
                var result = data.toString().trim();
                if (result == "no xclip") {
                    Logger.showInformationMessage('You need to install xclip command first.');
                    return;
                }
                cb(imagePath, result);
            });
        }
    };
    /**
     * render the image file path dependen on file type
     * e.g. in markdown image file path will render to ![](path)
     */
    Paster.renderFilePath = function (languageId, basePath, imageFilePath, forceUnixStyleSeparator, prefix, suffix) {
        if (basePath) {
            imageFilePath = path.relative(basePath, imageFilePath);
        }
        if (forceUnixStyleSeparator) {
            imageFilePath = upath.normalize(imageFilePath);
        }
        var originalImagePath = imageFilePath;
        var ext = path.extname(originalImagePath);
        var fileName = path.basename(originalImagePath);
        var fileNameWithoutExt = path.basename(originalImagePath, ext);
        imageFilePath = "" + prefix + imageFilePath + suffix;
        if (this.encodePathConfig == "urlEncode") {
            imageFilePath = encodeURI(imageFilePath);
        }
        else if (this.encodePathConfig == "urlEncodeSpace") {
            imageFilePath = imageFilePath.replace(/ /g, "%20");
        }
        var imageSyntaxPrefix = "";
        var imageSyntaxSuffix = "";
        switch (languageId) {
            case "markdown":
                imageSyntaxPrefix = "![](";
                imageSyntaxSuffix = ")";
                break;
            case "asciidoc":
                imageSyntaxPrefix = "image::";
                imageSyntaxSuffix = "[]";
                break;
        }
        var result = this.insertPatternConfig;
        result = result.replace(this.PATH_VARIABLE_IMAGE_SYNTAX_PREFIX, imageSyntaxPrefix);
        result = result.replace(this.PATH_VARIABLE_IMAGE_SYNTAX_SUFFIX, imageSyntaxSuffix);
        result = result.replace(this.PATH_VARIABLE_IMAGE_FILE_PATH, imageFilePath);
        result = result.replace(this.PATH_VARIABLE_IMAGE_ORIGINAL_FILE_PATH, originalImagePath);
        result = result.replace(this.PATH_VARIABLE_IMAGE_FILE_NAME, fileName);
        result = result.replace(this.PATH_VARIABLE_IMAGE_FILE_NAME_WITHOUT_EXT, fileNameWithoutExt);
        return result;
    };
    Paster.replacePathVariable = function (pathStr, projectRoot, curFilePath, postFunction) {
        if (postFunction === void 0) { postFunction = function (x) { return x; }; }
        var currentFileDir = path.dirname(curFilePath);
        var ext = path.extname(curFilePath);
        var fileName = path.basename(curFilePath);
        var fileNameWithoutExt = path.basename(curFilePath, ext);
        pathStr = pathStr.replace(this.PATH_VARIABLE_PROJECT_ROOT, postFunction(projectRoot));
        pathStr = pathStr.replace(this.PATH_VARIABLE_CURRNET_FILE_DIR, postFunction(currentFileDir));
        pathStr = pathStr.replace(this.PATH_VARIABLE_CURRNET_FILE_NAME, postFunction(fileName));
        pathStr = pathStr.replace(this.PATH_VARIABLE_CURRNET_FILE_NAME_WITHOUT_EXT, postFunction(fileNameWithoutExt));
        return pathStr;
    };
    Paster.PATH_VARIABLE_CURRNET_FILE_DIR = /\$\{currentFileDir\}/g;
    Paster.PATH_VARIABLE_PROJECT_ROOT = /\$\{projectRoot\}/g;
    Paster.PATH_VARIABLE_CURRNET_FILE_NAME = /\$\{currentFileName\}/g;
    Paster.PATH_VARIABLE_CURRNET_FILE_NAME_WITHOUT_EXT = /\$\{currentFileNameWithoutExt\}/g;
    Paster.PATH_VARIABLE_IMAGE_FILE_PATH = /\$\{imageFilePath\}/g;
    Paster.PATH_VARIABLE_IMAGE_ORIGINAL_FILE_PATH = /\$\{imageOriginalFilePath\}/g;
    Paster.PATH_VARIABLE_IMAGE_FILE_NAME = /\$\{imageFileName\}/g;
    Paster.PATH_VARIABLE_IMAGE_FILE_NAME_WITHOUT_EXT = /\$\{imageFileNameWithoutExt\}/g;
    Paster.PATH_VARIABLE_IMAGE_SYNTAX_PREFIX = /\$\{imageSyntaxPrefix\}/g;
    Paster.PATH_VARIABLE_IMAGE_SYNTAX_SUFFIX = /\$\{imageSyntaxSuffix\}/g;
    Paster.FILE_PATH_CONFIRM_INPUTBOX_MODE_ONLY_NAME = "onlyName";
    Paster.FILE_PATH_CONFIRM_INPUTBOX_MODE_PULL_PATH = "fullPath";
    return Paster;
}());
var PluginError = (function () {
    function PluginError(message) {
        this.message = message;
    }
    return PluginError;
}());
//# sourceMappingURL=extension.js.map