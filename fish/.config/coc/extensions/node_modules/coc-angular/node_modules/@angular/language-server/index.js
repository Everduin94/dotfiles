var __create = Object.create;
var __defProp = Object.defineProperty;
var __getProtoOf = Object.getPrototypeOf;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __markAsModule = (target) => __defProp(target, "__esModule", {value: true});
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, {get: all[name], enumerable: true});
};
var __exportStar = (target, module2, desc) => {
  if (module2 && typeof module2 === "object" || typeof module2 === "function") {
    for (let key of __getOwnPropNames(module2))
      if (!__hasOwnProp.call(target, key) && key !== "default")
        __defProp(target, key, {get: () => module2[key], enumerable: !(desc = __getOwnPropDesc(module2, key)) || desc.enumerable});
  }
  return target;
};
var __toModule = (module2) => {
  return __exportStar(__markAsModule(__defProp(module2 != null ? __create(__getProtoOf(module2)) : {}, "default", module2 && module2.__esModule && "default" in module2 ? {get: () => module2.default, enumerable: true} : {value: module2, enumerable: true})), module2);
};

// dist/banner/banner.js
__markAsModule(exports);
__export(exports, {
  define: () => define
});

// dist/banner/cmdline_utils.js
/**
 * @license
 * Copyright Google Inc. All Rights Reserved.
 *
 * Use of this source code is governed by an MIT-style license that can be
 * found in the LICENSE file at https://angular.io/license
 */
function findArgument(argv, argName) {
  const index = argv.indexOf(argName);
  if (index < 0 || index === argv.length - 1) {
    return;
  }
  return argv[index + 1];
}
function parseStringArray(argv, argName) {
  const arg = findArgument(argv, argName);
  if (!arg) {
    return [];
  }
  return arg.split(",");
}
function hasArgument(argv, argName) {
  return argv.includes(argName);
}
function parseCommandLine(argv) {
  return {
    help: hasArgument(argv, "--help"),
    ivy: hasArgument(argv, "--experimental-ivy"),
    logFile: findArgument(argv, "--logFile"),
    logVerbosity: findArgument(argv, "--logVerbosity"),
    logToConsole: hasArgument(argv, "--logToConsole"),
    ngProbeLocations: parseStringArray(argv, "--ngProbeLocations"),
    tsProbeLocations: parseStringArray(argv, "--tsProbeLocations")
  };
}

// dist/banner/version_provider.js
var fs = __toModule(require("fs"));
var path = __toModule(require("path"));
/**
 * @license
 * Copyright Google Inc. All Rights Reserved.
 *
 * Use of this source code is governed by an MIT-style license that can be
 * found in the LICENSE file at https://angular.io/license
 */
var MIN_TS_VERSION = "4.1";
var TSSERVERLIB = "typescript/lib/tsserverlibrary";
function resolve2(packageName, location, rootPackage) {
  rootPackage = rootPackage || packageName;
  try {
    const packageJsonPath = require.resolve(`${rootPackage}/package.json`, {
      paths: [location]
    });
    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf8"));
    const resolvedPath = require.resolve(packageName, {
      paths: [location]
    });
    return {
      name: packageName,
      resolvedPath,
      version: new Version(packageJson.version)
    };
  } catch (_a) {
  }
}
function resolveWithMinVersion(packageName, minVersionStr, probeLocations, rootPackage) {
  if (!packageName.startsWith(rootPackage)) {
    throw new Error(`${packageName} must be in the root package`);
  }
  const minVersion = new Version(minVersionStr);
  for (const location of probeLocations) {
    const nodeModule = resolve2(packageName, location, rootPackage);
    if (nodeModule && nodeModule.version.greaterThanOrEqual(minVersion)) {
      return nodeModule;
    }
  }
  throw new Error(`Failed to resolve '${packageName}' with minimum version '${minVersion}' from ` + JSON.stringify(probeLocations, null, 2));
}
function resolveTsServer(probeLocations) {
  if (probeLocations.length > 0) {
    const resolvedFromTsdk = resolveTsServerFromTsdk(probeLocations[0]);
    if (resolvedFromTsdk !== void 0) {
      return resolvedFromTsdk;
    }
  }
  return resolveWithMinVersion(TSSERVERLIB, MIN_TS_VERSION, probeLocations, "typescript");
}
function resolveTsServerFromTsdk(tsdk) {
  if (!path.isAbsolute(tsdk)) {
    return void 0;
  }
  const tsserverlib = path.join(tsdk, "tsserverlibrary.js");
  if (!fs.existsSync(tsserverlib)) {
    return void 0;
  }
  const packageJson = path.resolve(tsserverlib, "../../package.json");
  if (!fs.existsSync(packageJson)) {
    return void 0;
  }
  try {
    const json = JSON.parse(fs.readFileSync(packageJson, "utf8"));
    return {
      name: TSSERVERLIB,
      resolvedPath: tsserverlib,
      version: new Version(json.version)
    };
  } catch (_a) {
    return void 0;
  }
}
function parseNonNegativeInt(a) {
  const i = parseInt(a, 10);
  return isNaN(i) ? -1 : i;
}
var Version = class {
  constructor(versionStr) {
    this.versionStr = versionStr;
    const [major, minor, patch] = Version.parseVersionStr(versionStr);
    this.major = major;
    this.minor = minor;
    this.patch = patch;
  }
  greaterThanOrEqual(other) {
    if (this.major < other.major) {
      return false;
    }
    if (this.major > other.major) {
      return true;
    }
    if (this.minor < other.minor) {
      return false;
    }
    if (this.minor > other.minor) {
      return true;
    }
    return this.patch >= other.patch;
  }
  toString() {
    return this.versionStr;
  }
  static parseVersionStr(versionStr) {
    const [major, minor, patch] = versionStr.split(".").map(parseNonNegativeInt);
    return [
      major === void 0 ? 0 : major,
      minor === void 0 ? 0 : minor,
      patch === void 0 ? 0 : patch
    ];
  }
};

// dist/banner/banner.js
function define(modules, cb) {
  const TSSERVER = "typescript/lib/tsserverlibrary";
  const resolvedModules = modules.map((m) => {
    if (m === "typescript") {
      throw new Error(`Import '${TSSERVER}' instead of 'typescript'`);
    }
    if (m === TSSERVER) {
      const {tsProbeLocations} = parseCommandLine(process.argv);
      m = resolveTsServer(tsProbeLocations).resolvedPath;
    }
    return require(m);
  });
  cb(...resolvedModules);
}

define(['fs', 'path', 'typescript/lib/tsserverlibrary', '@angular/language-service/api', 'assert', 'util', 'vscode-languageserver/node', 'vscode-jsonrpc', 'vscode-languageserver-protocol', 'vscode-languageserver', 'vscode-uri', 'child_process'], function (fs, path, tsserverlibrary, api, assert, util, node, vscodeJsonrpc, vscodeLanguageserverProtocol, vscodeLanguageserver, vscodeUri, child_process) { 'use strict';

	function _interopDefaultLegacy (e) { return e && typeof e === 'object' && 'default' in e ? e : { 'default': e }; }

	var fs__default = /*#__PURE__*/_interopDefaultLegacy(fs);
	var path__default = /*#__PURE__*/_interopDefaultLegacy(path);
	var tsserverlibrary__default = /*#__PURE__*/_interopDefaultLegacy(tsserverlibrary);
	var api__default = /*#__PURE__*/_interopDefaultLegacy(api);
	var assert__default = /*#__PURE__*/_interopDefaultLegacy(assert);
	var util__default = /*#__PURE__*/_interopDefaultLegacy(util);
	var node__default = /*#__PURE__*/_interopDefaultLegacy(node);
	var vscodeJsonrpc__default = /*#__PURE__*/_interopDefaultLegacy(vscodeJsonrpc);
	var vscodeLanguageserverProtocol__default = /*#__PURE__*/_interopDefaultLegacy(vscodeLanguageserverProtocol);
	var vscodeLanguageserver__default = /*#__PURE__*/_interopDefaultLegacy(vscodeLanguageserver);
	var vscodeUri__default = /*#__PURE__*/_interopDefaultLegacy(vscodeUri);
	var child_process__default = /*#__PURE__*/_interopDefaultLegacy(child_process);

	function unwrapExports (x) {
		return x && x.__esModule && Object.prototype.hasOwnProperty.call(x, 'default') ? x['default'] : x;
	}

	function createCommonjsModule(fn, module) {
		return module = { exports: {} }, fn(module, module.exports), module.exports;
	}

	var cmdline_utils = createCommonjsModule(function (module, exports) {
	/**
	 * @license
	 * Copyright Google Inc. All Rights Reserved.
	 *
	 * Use of this source code is governed by an MIT-style license that can be
	 * found in the LICENSE file at https://angular.io/license
	 */
	Object.defineProperty(exports, "__esModule", { value: true });
	exports.generateHelpMessage = exports.parseCommandLine = void 0;
	function findArgument(argv, argName) {
	    const index = argv.indexOf(argName);
	    if (index < 0 || index === argv.length - 1) {
	        return;
	    }
	    return argv[index + 1];
	}
	function parseStringArray(argv, argName) {
	    const arg = findArgument(argv, argName);
	    if (!arg) {
	        return [];
	    }
	    return arg.split(',');
	}
	function hasArgument(argv, argName) {
	    return argv.includes(argName);
	}
	function parseCommandLine(argv) {
	    return {
	        help: hasArgument(argv, '--help'),
	        ivy: hasArgument(argv, '--experimental-ivy'),
	        logFile: findArgument(argv, '--logFile'),
	        logVerbosity: findArgument(argv, '--logVerbosity'),
	        logToConsole: hasArgument(argv, '--logToConsole'),
	        ngProbeLocations: parseStringArray(argv, '--ngProbeLocations'),
	        tsProbeLocations: parseStringArray(argv, '--tsProbeLocations'),
	    };
	}
	exports.parseCommandLine = parseCommandLine;
	function generateHelpMessage(argv) {
	    return `Angular Language Service that implements the Language Server Protocol (LSP).

  Usage: ${argv[0]} ${argv[1]} [options]

  Options:
    --help: Prints help message.
    --experimental-ivy: Enables the Ivy language service. Defaults to false.
    --logFile: Location to log messages. Logging to file is disabled if not provided.
    --logVerbosity: terse|normal|verbose|requestTime. See ts.server.LogLevel.
    --logToConsole: Enables logging to console via 'window/logMessage'. Defaults to false.
    --ngProbeLocations: Path of @angular/language-service. Required.
    --tsProbeLocations: Path of typescript. Required.

  Additional options supported by vscode-languageserver:
    --clientProcessId=<number>: Automatically kills the server if the client process dies.
    --node-ipc: Communicate using Node's IPC. This is the default.
    --stdio: Communicate over stdin/stdout.
    --socket=<number>: Communicate using Unix socket.
  `;
	}
	exports.generateHelpMessage = generateHelpMessage;

	});

	unwrapExports(cmdline_utils);
	cmdline_utils.generateHelpMessage;
	cmdline_utils.parseCommandLine;

	var logger = createCommonjsModule(function (module, exports) {
	/**
	 * @license
	 * Copyright Google Inc. All Rights Reserved.
	 *
	 * Use of this source code is governed by an MIT-style license that can be
	 * found in the LICENSE file at https://angular.io/license
	 */
	Object.defineProperty(exports, "__esModule", { value: true });
	exports.createLogger = void 0;



	/**
	 * Create a logger instance to write to file.
	 * @param options Logging options.
	 */
	function createLogger(options) {
	    let logLevel;
	    switch (options.logVerbosity) {
	        case 'requestTime':
	            logLevel = tsserverlibrary__default['default'].server.LogLevel.requestTime;
	            break;
	        case 'verbose':
	            logLevel = tsserverlibrary__default['default'].server.LogLevel.verbose;
	            break;
	        case 'normal':
	            logLevel = tsserverlibrary__default['default'].server.LogLevel.normal;
	            break;
	        case 'terse':
	        default:
	            logLevel = tsserverlibrary__default['default'].server.LogLevel.terse;
	            break;
	    }
	    return new Logger(logLevel, options.logFile);
	}
	exports.createLogger = createLogger;
	// TODO: Code below is from TypeScript's repository. Maybe create our own
	// implementation.
	// https://github.com/microsoft/TypeScript/blob/ec39d412876d0dcf704fc886d5036cb625220d2f/src/tsserver/server.ts#L120
	function noop(_) { } // tslint:disable-line no-empty
	function nowString() {
	    // E.g. "12:34:56.789"
	    const d = new Date();
	    return `${d.getHours()}:${d.getMinutes()}:${d.getSeconds()}.${d.getMilliseconds()}`;
	}
	class Logger {
	    constructor(level, logFilename) {
	        this.level = level;
	        this.logFilename = logFilename;
	        this.seq = 0;
	        this.inGroup = false;
	        this.firstInGroup = true;
	        this.fd = -1;
	        if (logFilename) {
	            try {
	                const dir = path__default['default'].dirname(logFilename);
	                if (!fs__default['default'].existsSync(dir)) {
	                    fs__default['default'].mkdirSync(dir);
	                }
	                this.fd = fs__default['default'].openSync(logFilename, 'w');
	            }
	            catch (_a) {
	                // swallow the error and keep logging disabled if file cannot be opened
	            }
	        }
	    }
	    close() {
	        if (this.loggingEnabled()) {
	            fs__default['default'].close(this.fd, noop);
	        }
	    }
	    getLogFileName() {
	        return this.logFilename;
	    }
	    perftrc(s) {
	        this.msg(s, tsserverlibrary__default['default'].server.Msg.Perf);
	    }
	    info(s) {
	        this.msg(s, tsserverlibrary__default['default'].server.Msg.Info);
	    }
	    startGroup() {
	        this.inGroup = true;
	        this.firstInGroup = true;
	    }
	    endGroup() {
	        this.inGroup = false;
	    }
	    loggingEnabled() {
	        return this.fd >= 0;
	    }
	    hasLevel(level) {
	        return this.loggingEnabled() && this.level >= level;
	    }
	    msg(s, type = tsserverlibrary__default['default'].server.Msg.Err) {
	        if (!this.loggingEnabled()) {
	            return;
	        }
	        let prefix = '';
	        if (!this.inGroup || this.firstInGroup) {
	            this.firstInGroup = false;
	            prefix = `${type} ${this.seq}`.padEnd(10) + `[${nowString()}] `;
	        }
	        const entry = prefix + s + '\n';
	        fs__default['default'].writeSync(this.fd, entry);
	        if (!this.inGroup) {
	            this.seq++;
	        }
	    }
	}

	});

	unwrapExports(logger);
	logger.createLogger;

	var version_provider = createCommonjsModule(function (module, exports) {
	/**
	 * @license
	 * Copyright Google Inc. All Rights Reserved.
	 *
	 * Use of this source code is governed by an MIT-style license that can be
	 * found in the LICENSE file at https://angular.io/license
	 */
	Object.defineProperty(exports, "__esModule", { value: true });
	exports.Version = exports.resolveNgcc = exports.resolveNgLangSvc = exports.resolveTsServer = exports.resolve = exports.NGLANGSVC = void 0;


	const MIN_TS_VERSION = '4.1';
	const MIN_NG_VERSION = '11.2';
	exports.NGLANGSVC = '@angular/language-service';
	const TSSERVERLIB = 'typescript/lib/tsserverlibrary';
	function resolve(packageName, location, rootPackage) {
	    rootPackage = rootPackage || packageName;
	    try {
	        const packageJsonPath = require.resolve(`${rootPackage}/package.json`, {
	            paths: [location],
	        });
	        // Do not use require() to read JSON files since it's a potential security
	        // vulnerability.
	        const packageJson = JSON.parse(fs__default['default'].readFileSync(packageJsonPath, 'utf8'));
	        const resolvedPath = require.resolve(packageName, {
	            paths: [location],
	        });
	        return {
	            name: packageName,
	            resolvedPath,
	            version: new Version(packageJson.version),
	        };
	    }
	    catch (_a) {
	    }
	}
	exports.resolve = resolve;
	/**
	 * Resolve the node module with the specified `packageName` that satisfies
	 * the specified minimum version.
	 * @param packageName name of package to be resolved
	 * @param minVersionStr minimum version
	 * @param probeLocations locations to initiate node module resolution
	 * @param rootPackage location of package.json. For example, the root package of
	 * `typescript/lib/tsserverlibrary` is `typescript`.
	 */
	function resolveWithMinVersion(packageName, minVersionStr, probeLocations, rootPackage) {
	    if (!packageName.startsWith(rootPackage)) {
	        throw new Error(`${packageName} must be in the root package`);
	    }
	    const minVersion = new Version(minVersionStr);
	    for (const location of probeLocations) {
	        const nodeModule = resolve(packageName, location, rootPackage);
	        if (nodeModule && nodeModule.version.greaterThanOrEqual(minVersion)) {
	            return nodeModule;
	        }
	    }
	    throw new Error(`Failed to resolve '${packageName}' with minimum version '${minVersion}' from ` +
	        JSON.stringify(probeLocations, null, 2));
	}
	/**
	 * Resolve `typescript/lib/tsserverlibrary` from the given locations.
	 * @param probeLocations
	 */
	function resolveTsServer(probeLocations) {
	    if (probeLocations.length > 0) {
	        // The first probe location is `typescript.tsdk` if it is specified.
	        const resolvedFromTsdk = resolveTsServerFromTsdk(probeLocations[0]);
	        if (resolvedFromTsdk !== undefined) {
	            return resolvedFromTsdk;
	        }
	    }
	    return resolveWithMinVersion(TSSERVERLIB, MIN_TS_VERSION, probeLocations, 'typescript');
	}
	exports.resolveTsServer = resolveTsServer;
	function resolveTsServerFromTsdk(tsdk) {
	    // `tsdk` is the folder path to the tsserver and lib*.d.ts files under a
	    // TypeScript install, for example
	    // - /google/src/head/depot/google3/third_party/javascript/node_modules/typescript/stable/lib
	    if (!path__default['default'].isAbsolute(tsdk)) {
	        return undefined;
	    }
	    const tsserverlib = path__default['default'].join(tsdk, 'tsserverlibrary.js');
	    if (!fs__default['default'].existsSync(tsserverlib)) {
	        return undefined;
	    }
	    const packageJson = path__default['default'].resolve(tsserverlib, '../../package.json');
	    if (!fs__default['default'].existsSync(packageJson)) {
	        return undefined;
	    }
	    try {
	        const json = JSON.parse(fs__default['default'].readFileSync(packageJson, 'utf8'));
	        return {
	            name: TSSERVERLIB,
	            resolvedPath: tsserverlib,
	            version: new Version(json.version),
	        };
	    }
	    catch (_a) {
	        return undefined;
	    }
	}
	/**
	 * Resolve `@angular/language-service` from the given locations.
	 * @param probeLocations locations from which resolution is attempted
	 * @param ivy true if Ivy language service is requested
	 */
	function resolveNgLangSvc(probeLocations, ivy) {
	    const packageName = ivy ? `${exports.NGLANGSVC}/bundles/ivy` : exports.NGLANGSVC;
	    return resolveWithMinVersion(packageName, MIN_NG_VERSION, probeLocations, exports.NGLANGSVC);
	}
	exports.resolveNgLangSvc = resolveNgLangSvc;
	function resolveNgcc(directory) {
	    return resolve('@angular/compiler-cli/ngcc/main-ngcc.js', directory, '@angular/compiler-cli');
	}
	exports.resolveNgcc = resolveNgcc;
	/**
	 * Converts the specified string `a` to non-negative integer.
	 * Returns -1 if the result is NaN.
	 * @param a
	 */
	function parseNonNegativeInt(a) {
	    // parseInt() will try to convert as many as possible leading characters that
	    // are digits. This means a string like "123abc" will be converted to 123.
	    // For our use case, this is sufficient.
	    const i = parseInt(a, 10 /* radix */);
	    return isNaN(i) ? -1 : i;
	}
	class Version {
	    constructor(versionStr) {
	        this.versionStr = versionStr;
	        const [major, minor, patch] = Version.parseVersionStr(versionStr);
	        this.major = major;
	        this.minor = minor;
	        this.patch = patch;
	    }
	    greaterThanOrEqual(other) {
	        if (this.major < other.major) {
	            return false;
	        }
	        if (this.major > other.major) {
	            return true;
	        }
	        if (this.minor < other.minor) {
	            return false;
	        }
	        if (this.minor > other.minor) {
	            return true;
	        }
	        return this.patch >= other.patch;
	    }
	    toString() {
	        return this.versionStr;
	    }
	    /**
	     * Converts the specified `versionStr` to its number constituents. Invalid
	     * number value is represented as negative number.
	     * @param versionStr
	     */
	    static parseVersionStr(versionStr) {
	        const [major, minor, patch] = versionStr.split('.').map(parseNonNegativeInt);
	        return [
	            major === undefined ? 0 : major,
	            minor === undefined ? 0 : minor,
	            patch === undefined ? 0 : patch,
	        ];
	    }
	}
	exports.Version = Version;

	});

	unwrapExports(version_provider);
	version_provider.Version;
	version_provider.resolveNgcc;
	version_provider.resolveNgLangSvc;
	version_provider.resolveTsServer;
	version_provider.resolve;
	version_provider.NGLANGSVC;

	var server_host = createCommonjsModule(function (module, exports) {
	/**
	 * @license
	 * Copyright Google Inc. All Rights Reserved.
	 *
	 * Use of this source code is governed by an MIT-style license that can be
	 * found in the LICENSE file at https://angular.io/license
	 */
	Object.defineProperty(exports, "__esModule", { value: true });
	exports.ServerHost = void 0;


	const NOOP_WATCHER = {
	    close() { },
	};
	/**
	 * `ServerHost` is a wrapper around `ts.sys` for the Node system. In Node, all
	 * optional methods of `ts.System` are implemented.
	 * See
	 * https://github.com/microsoft/TypeScript/blob/ec39d412876d0dcf704fc886d5036cb625220d2f/src/compiler/sys.ts#L716
	 */
	class ServerHost {
	    constructor(ivy, isG3) {
	        this.ivy = ivy;
	        this.isG3 = isG3;
	        this.args = tsserverlibrary__default['default'].sys.args;
	        this.newLine = tsserverlibrary__default['default'].sys.newLine;
	        this.useCaseSensitiveFileNames = tsserverlibrary__default['default'].sys.useCaseSensitiveFileNames;
	    }
	    write(s) {
	        tsserverlibrary__default['default'].sys.write(s);
	    }
	    writeOutputIsTTY() {
	        return tsserverlibrary__default['default'].sys.writeOutputIsTTY();
	    }
	    readFile(path, encoding) {
	        return tsserverlibrary__default['default'].sys.readFile(path, encoding);
	    }
	    getFileSize(path) {
	        return tsserverlibrary__default['default'].sys.getFileSize(path);
	    }
	    writeFile(path, data, writeByteOrderMark) {
	        return tsserverlibrary__default['default'].sys.writeFile(path, data, writeByteOrderMark);
	    }
	    /**
	     * @pollingInterval - this parameter is used in polling-based watchers and
	     * ignored in watchers that use native OS file watching
	     */
	    watchFile(path, callback, pollingInterval) {
	        return tsserverlibrary__default['default'].sys.watchFile(path, callback, pollingInterval);
	    }
	    watchDirectory(path, callback, recursive) {
	        if (this.isG3 && path.startsWith('/google/src')) {
	            return NOOP_WATCHER;
	        }
	        return tsserverlibrary__default['default'].sys.watchDirectory(path, callback, recursive);
	    }
	    resolvePath(path) {
	        return tsserverlibrary__default['default'].sys.resolvePath(path);
	    }
	    fileExists(path) {
	        // When a project is reloaded (due to changes in node_modules for example),
	        // the typecheck files ought to be retained. However, if they do not exist
	        // on disk, tsserver will remove them from project. See
	        // https://github.com/microsoft/TypeScript/blob/3c32f6e154ead6749b76ec9c19cbfdd2acad97d6/src/server/editorServices.ts#L2188-L2193
	        // To fix this, we fake the existence of the typecheck files.
	        if (path.endsWith('.ngtypecheck.ts')) {
	            return true;
	        }
	        return tsserverlibrary__default['default'].sys.fileExists(path);
	    }
	    directoryExists(path) {
	        return tsserverlibrary__default['default'].sys.directoryExists(path);
	    }
	    createDirectory(path) {
	        return tsserverlibrary__default['default'].sys.createDirectory(path);
	    }
	    getExecutingFilePath() {
	        return tsserverlibrary__default['default'].sys.getExecutingFilePath();
	    }
	    getCurrentDirectory() {
	        return tsserverlibrary__default['default'].sys.getCurrentDirectory();
	    }
	    getDirectories(path) {
	        return tsserverlibrary__default['default'].sys.getDirectories(path);
	    }
	    readDirectory(path, extensions, exclude, include, depth) {
	        return tsserverlibrary__default['default'].sys.readDirectory(path, extensions, exclude, include, depth);
	    }
	    getModifiedTime(path) {
	        return tsserverlibrary__default['default'].sys.getModifiedTime(path);
	    }
	    setModifiedTime(path, time) {
	        return tsserverlibrary__default['default'].sys.setModifiedTime(path, time);
	    }
	    deleteFile(path) {
	        return tsserverlibrary__default['default'].sys.deleteFile(path);
	    }
	    /**
	     * A good implementation is node.js' `crypto.createHash`.
	     * (https://nodejs.org/api/crypto.html#crypto_crypto_createhash_algorithm)
	     */
	    createHash(data) {
	        return tsserverlibrary__default['default'].sys.createHash(data);
	    }
	    /**
	     * This must be cryptographically secure. Only implement this method using
	     * `crypto.createHash("sha256")`.
	     */
	    createSHA256Hash(data) {
	        return tsserverlibrary__default['default'].sys.createSHA256Hash(data);
	    }
	    getMemoryUsage() {
	        return tsserverlibrary__default['default'].sys.getMemoryUsage();
	    }
	    exit(exitCode) {
	        return tsserverlibrary__default['default'].sys.exit(exitCode);
	    }
	    realpath(path) {
	        return tsserverlibrary__default['default'].sys.realpath(path);
	    }
	    setTimeout(callback, ms, ...args) {
	        return tsserverlibrary__default['default'].sys.setTimeout(callback, ms, ...args);
	    }
	    clearTimeout(timeoutId) {
	        return tsserverlibrary__default['default'].sys.clearTimeout(timeoutId);
	    }
	    clearScreen() {
	        return tsserverlibrary__default['default'].sys.clearScreen();
	    }
	    base64decode(input) {
	        return tsserverlibrary__default['default'].sys.base64decode(input);
	    }
	    base64encode(input) {
	        return tsserverlibrary__default['default'].sys.base64encode(input);
	    }
	    setImmediate(callback, ...args) {
	        return setImmediate(callback, ...args);
	    }
	    clearImmediate(timeoutId) {
	        return clearImmediate(timeoutId);
	    }
	    require(initialPath, moduleName) {
	        if (moduleName !== '@angular/language-service') {
	            return {
	                module: undefined,
	                error: new Error(`Angular server will not load plugin '${moduleName}'.`),
	            };
	        }
	        try {
	            let modulePath = require.resolve(moduleName, {
	                paths: [initialPath],
	            });
	            // TypeScript allows only package names as plugin names.
	            if (this.ivy && moduleName === version_provider.NGLANGSVC) {
	                modulePath = this.resolvePath(modulePath + '/../ivy.js');
	            }
	            return {
	                module: require(modulePath),
	                error: undefined,
	            };
	        }
	        catch (e) {
	            return {
	                module: undefined,
	                error: e,
	            };
	        }
	    }
	}
	exports.ServerHost = ServerHost;

	});

	unwrapExports(server_host);
	server_host.ServerHost;

	var notifications = createCommonjsModule(function (module, exports) {
	/**
	 * @license
	 * Copyright Google Inc. All Rights Reserved.
	 *
	 * Use of this source code is governed by an MIT-style license that can be
	 * found in the LICENSE file at https://angular.io/license
	 */
	Object.defineProperty(exports, "__esModule", { value: true });
	exports.SuggestIvyLanguageService = exports.SuggestStrictMode = exports.ProjectLanguageService = exports.ProjectLoadingFinish = exports.ProjectLoadingStart = void 0;

	exports.ProjectLoadingStart = new vscodeJsonrpc__default['default'].NotificationType0('angular/projectLoadingStart');
	exports.ProjectLoadingFinish = new vscodeJsonrpc__default['default'].NotificationType0('angular/projectLoadingFinish');
	exports.ProjectLanguageService = new vscodeJsonrpc__default['default'].NotificationType('angular/projectLanguageService');
	exports.SuggestStrictMode = new vscodeJsonrpc__default['default'].NotificationType('angular/suggestStrictMode');
	exports.SuggestIvyLanguageService = new vscodeJsonrpc__default['default'].NotificationType('angular/suggestIvyLanguageServiceMode');

	});

	unwrapExports(notifications);
	notifications.SuggestIvyLanguageService;
	notifications.SuggestStrictMode;
	notifications.ProjectLanguageService;
	notifications.ProjectLoadingFinish;
	notifications.ProjectLoadingStart;

	var progress = createCommonjsModule(function (module, exports) {
	/**
	 * @license
	 * Copyright Google Inc. All Rights Reserved.
	 *
	 * Use of this source code is governed by an MIT-style license that can be
	 * found in the LICENSE file at https://angular.io/license
	 */
	Object.defineProperty(exports, "__esModule", { value: true });
	exports.NgccProgressType = exports.NgccProgressToken = void 0;

	exports.NgccProgressToken = 'ngcc';
	exports.NgccProgressType = new vscodeJsonrpc__default['default'].ProgressType();

	});

	unwrapExports(progress);
	progress.NgccProgressType;
	progress.NgccProgressToken;

	var requests = createCommonjsModule(function (module, exports) {
	/**
	 * @license
	 * Copyright Google Inc. All Rights Reserved.
	 *
	 * Use of this source code is governed by an MIT-style license that can be
	 * found in the LICENSE file at https://angular.io/license
	 */
	Object.defineProperty(exports, "__esModule", { value: true });
	exports.GetTcbRequest = void 0;

	exports.GetTcbRequest = new vscodeLanguageserverProtocol__default['default'].RequestType('angular/getTcb');

	});

	unwrapExports(requests);
	requests.GetTcbRequest;

	var utils = createCommonjsModule(function (module, exports) {
	/**
	 * @license
	 * Copyright Google Inc. All Rights Reserved.
	 *
	 * Use of this source code is governed by an MIT-style license that can be
	 * found in the LICENSE file at https://angular.io/license
	 */
	Object.defineProperty(exports, "__esModule", { value: true });
	exports.MruTracker = exports.isConfiguredProject = exports.lspRangeToTsPositions = exports.lspPositionToTsPosition = exports.tsTextSpanToLspRange = exports.filePathToUri = exports.uriToFilePath = exports.isDebugMode = void 0;



	exports.isDebugMode = process.env['NG_DEBUG'] === 'true';
	var Scheme;
	(function (Scheme) {
	    Scheme["File"] = "file";
	})(Scheme || (Scheme = {}));
	/**
	 * Extract the file path from the specified `uri`.
	 * @param uri
	 */
	function uriToFilePath(uri) {
	    // Note: uri.path is different from uri.fsPath
	    // See
	    // https://github.com/microsoft/vscode-uri/blob/413805221cc6ed167186ab3103d3248d6f7161f2/src/index.ts#L622-L645
	    const { scheme, fsPath } = vscodeUri__default['default'].URI.parse(uri);
	    if (scheme !== Scheme.File) {
	        return '';
	    }
	    return fsPath;
	}
	exports.uriToFilePath = uriToFilePath;
	/**
	 * Converts the specified `filePath` to a proper URI.
	 * @param filePath
	 */
	function filePathToUri(filePath) {
	    return vscodeUri__default['default'].URI.file(filePath).toString();
	}
	exports.filePathToUri = filePathToUri;
	/**
	 * Convert ts.TextSpan to lsp.TextSpan. TypeScript keeps track of offset using
	 * 1-based index whereas LSP uses 0-based index.
	 * @param scriptInfo Used to determine the offsets.
	 * @param textSpan
	 */
	function tsTextSpanToLspRange(scriptInfo, textSpan) {
	    const start = scriptInfo.positionToLineOffset(textSpan.start);
	    const end = scriptInfo.positionToLineOffset(textSpan.start + textSpan.length);
	    // ScriptInfo (TS) is 1-based, LSP is 0-based.
	    return vscodeLanguageserver__default['default'].Range.create(start.line - 1, start.offset - 1, end.line - 1, end.offset - 1);
	}
	exports.tsTextSpanToLspRange = tsTextSpanToLspRange;
	/**
	 * Convert lsp.Position to the absolute offset in the file. LSP keeps track of
	 * offset using 0-based index whereas TypeScript uses 1-based index.
	 * @param scriptInfo Used to determine the offsets.
	 * @param position
	 */
	function lspPositionToTsPosition(scriptInfo, position) {
	    const { line, character } = position;
	    // ScriptInfo (TS) is 1-based, LSP is 0-based.
	    return scriptInfo.lineOffsetToPosition(line + 1, character + 1);
	}
	exports.lspPositionToTsPosition = lspPositionToTsPosition;
	/**
	 * Convert lsp.Range which is made up of `start` and `end` positions to
	 * TypeScript's absolute offsets.
	 * @param scriptInfo Used to determine the offsets.
	 * @param range
	 */
	function lspRangeToTsPositions(scriptInfo, range) {
	    const start = lspPositionToTsPosition(scriptInfo, range.start);
	    const end = lspPositionToTsPosition(scriptInfo, range.end);
	    return [start, end];
	}
	exports.lspRangeToTsPositions = lspRangeToTsPositions;
	function isConfiguredProject(project) {
	    return project.projectKind === tsserverlibrary__default['default'].server.ProjectKind.Configured;
	}
	exports.isConfiguredProject = isConfiguredProject;
	/**
	 * A class that tracks items in most recently used order.
	 */
	class MruTracker {
	    constructor() {
	        this.set = new Set();
	    }
	    update(item) {
	        if (this.set.has(item)) {
	            this.set.delete(item);
	        }
	        this.set.add(item);
	    }
	    delete(item) {
	        this.set.delete(item);
	    }
	    /**
	     * Returns all items sorted by most recently used.
	     */
	    getAll() {
	        // Javascript Set maintains insertion order, see
	        // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Set
	        // Since items are sorted from least recently used to most recently used,
	        // we reverse the result.
	        return [...this.set].reverse();
	    }
	}
	exports.MruTracker = MruTracker;

	});

	unwrapExports(utils);
	utils.MruTracker;
	utils.isConfiguredProject;
	utils.lspRangeToTsPositions;
	utils.lspPositionToTsPosition;
	utils.tsTextSpanToLspRange;
	utils.filePathToUri;
	utils.uriToFilePath;
	utils.isDebugMode;

	var completion = createCommonjsModule(function (module, exports) {
	/**
	 * @license
	 * Copyright Google Inc. All Rights Reserved.
	 *
	 * Use of this source code is governed by an MIT-style license that can be
	 * found in the LICENSE file at https://angular.io/license
	 */
	Object.defineProperty(exports, "__esModule", { value: true });
	exports.tsCompletionEntryToLspCompletionItem = exports.readNgCompletionData = void 0;


	// TODO: Move this to `@angular/language-service`.
	var CompletionKind;
	(function (CompletionKind) {
	    CompletionKind["attribute"] = "attribute";
	    CompletionKind["htmlAttribute"] = "html attribute";
	    CompletionKind["property"] = "property";
	    CompletionKind["component"] = "component";
	    CompletionKind["element"] = "element";
	    CompletionKind["key"] = "key";
	    CompletionKind["method"] = "method";
	    CompletionKind["pipe"] = "pipe";
	    CompletionKind["type"] = "type";
	    CompletionKind["reference"] = "reference";
	    CompletionKind["variable"] = "variable";
	    CompletionKind["entity"] = "entity";
	})(CompletionKind || (CompletionKind = {}));
	/**
	 * Extract `NgCompletionOriginData` from an `lsp.CompletionItem` if present.
	 */
	function readNgCompletionData(item) {
	    if (item.data === undefined) {
	        return null;
	    }
	    // Validate that `item.data.kind` is actually the right tag, and narrow its type in the process.
	    const data = item.data;
	    if (data.kind !== 'ngCompletionOriginData') {
	        return null;
	    }
	    return data;
	}
	exports.readNgCompletionData = readNgCompletionData;
	/**
	 * Convert Angular's CompletionKind to LSP CompletionItemKind.
	 * @param kind Angular's CompletionKind
	 */
	function ngCompletionKindToLspCompletionItemKind(kind) {
	    switch (kind) {
	        case CompletionKind.attribute:
	        case CompletionKind.htmlAttribute:
	        case CompletionKind.property:
	            return vscodeLanguageserver__default['default'].CompletionItemKind.Property;
	        case CompletionKind.component:
	        case CompletionKind.element:
	        case CompletionKind.key:
	            return vscodeLanguageserver__default['default'].CompletionItemKind.Class;
	        case CompletionKind.method:
	            return vscodeLanguageserver__default['default'].CompletionItemKind.Method;
	        case CompletionKind.pipe:
	            return vscodeLanguageserver__default['default'].CompletionItemKind.Function;
	        case CompletionKind.type:
	            return vscodeLanguageserver__default['default'].CompletionItemKind.Interface;
	        case CompletionKind.reference:
	        case CompletionKind.variable:
	            return vscodeLanguageserver__default['default'].CompletionItemKind.Variable;
	        case CompletionKind.entity:
	        default:
	            return vscodeLanguageserver__default['default'].CompletionItemKind.Text;
	    }
	}
	/**
	 * Convert ts.CompletionEntry to LSP Completion Item.
	 * @param entry completion entry
	 * @param position position where completion is requested.
	 * @param scriptInfo
	 */
	function tsCompletionEntryToLspCompletionItem(entry, position, scriptInfo) {
	    const item = vscodeLanguageserver__default['default'].CompletionItem.create(entry.name);
	    // Even though `entry.kind` is typed as ts.ScriptElementKind, it's
	    // really Angular's CompletionKind. This is because ts.ScriptElementKind does
	    // not sufficiently capture the HTML entities.
	    // This is a limitation of being a tsserver plugin.
	    const kind = entry.kind;
	    item.kind = ngCompletionKindToLspCompletionItemKind(kind);
	    item.detail = entry.kind;
	    item.sortText = entry.sortText;
	    // Text that actually gets inserted to the document. It could be different
	    // from 'entry.name'. For example, a method name could be 'greet', but the
	    // insertText is 'greet()'.
	    const insertText = entry.insertText || entry.name;
	    item.textEdit = entry.replacementSpan ?
	        vscodeLanguageserver__default['default'].TextEdit.replace(utils.tsTextSpanToLspRange(scriptInfo, entry.replacementSpan), insertText) :
	        vscodeLanguageserver__default['default'].TextEdit.insert(position, insertText);
	    item.data = {
	        kind: 'ngCompletionOriginData',
	        filePath: scriptInfo.fileName,
	        position,
	    };
	    return item;
	}
	exports.tsCompletionEntryToLspCompletionItem = tsCompletionEntryToLspCompletionItem;

	});

	unwrapExports(completion);
	completion.tsCompletionEntryToLspCompletionItem;
	completion.readNgCompletionData;

	var diagnostic = createCommonjsModule(function (module, exports) {
	/**
	 * @license
	 * Copyright Google Inc. All Rights Reserved.
	 *
	 * Use of this source code is governed by an MIT-style license that can be
	 * found in the LICENSE file at https://angular.io/license
	 */
	Object.defineProperty(exports, "__esModule", { value: true });
	exports.tsDiagnosticToLspDiagnostic = void 0;



	/**
	 * Convert ts.DiagnosticCategory to lsp.DiagnosticSeverity
	 * @param category diagnostic category
	 */
	function tsDiagnosticCategoryToLspDiagnosticSeverity(category) {
	    switch (category) {
	        case tsserverlibrary__default['default'].DiagnosticCategory.Warning:
	            return vscodeLanguageserver__default['default'].DiagnosticSeverity.Warning;
	        case tsserverlibrary__default['default'].DiagnosticCategory.Error:
	            return vscodeLanguageserver__default['default'].DiagnosticSeverity.Error;
	        case tsserverlibrary__default['default'].DiagnosticCategory.Suggestion:
	            return vscodeLanguageserver__default['default'].DiagnosticSeverity.Hint;
	        case tsserverlibrary__default['default'].DiagnosticCategory.Message:
	        default:
	            return vscodeLanguageserver__default['default'].DiagnosticSeverity.Information;
	    }
	}
	/**
	 * Convert ts.Diagnostic to lsp.Diagnostic
	 * @param tsDiag TS diagnostic
	 * @param scriptInfo Used to compute proper offset.
	 */
	function tsDiagnosticToLspDiagnostic(tsDiag, scriptInfo) {
	    const textSpan = {
	        start: tsDiag.start || 0,
	        length: tsDiag.length || 0,
	    };
	    return vscodeLanguageserver__default['default'].Diagnostic.create(utils.tsTextSpanToLspRange(scriptInfo, textSpan), tsserverlibrary__default['default'].flattenDiagnosticMessageText(tsDiag.messageText, '\n'), tsDiagnosticCategoryToLspDiagnosticSeverity(tsDiag.category), tsDiag.code, tsDiag.source);
	}
	exports.tsDiagnosticToLspDiagnostic = tsDiagnosticToLspDiagnostic;

	});

	unwrapExports(diagnostic);
	diagnostic.tsDiagnosticToLspDiagnostic;

	var ngcc = createCommonjsModule(function (module, exports) {
	/**
	 * @license
	 * Copyright Google Inc. All Rights Reserved.
	 *
	 * Use of this source code is governed by an MIT-style license that can be
	 * found in the LICENSE file at https://angular.io/license
	 */
	Object.defineProperty(exports, "__esModule", { value: true });
	exports.resolveAndRunNgcc = void 0;



	/**
	 * Resolve ngcc from the directory that contains the specified `tsconfig` and
	 * run ngcc.
	 */
	async function resolveAndRunNgcc(tsconfig, progress) {
	    var _a, _b;
	    const directory = path__default['default'].dirname(tsconfig);
	    const ngcc = version_provider.resolveNgcc(directory);
	    if (!ngcc) {
	        throw new Error(`Failed to resolve ngcc from ${directory}`);
	    }
	    const index = ngcc.resolvedPath.lastIndexOf('node_modules');
	    // By default, ngcc assumes the node_modules directory that it needs to process
	    // is in the cwd. In our case, we should set cwd to the directory where ngcc
	    // is resolved to, not the directory where tsconfig.json is located. See
	    // https://github.com/angular/angular/blob/e23fd1f38205410e0ecb601ec73847cea2dea2a8/packages/compiler-cli/ngcc/src/command_line_options.ts#L18-L24
	    const cwd = index > 0 ? ngcc.resolvedPath.slice(0, index) : process.cwd();
	    const args = [
	        '--tsconfig',
	        tsconfig,
	    ];
	    if (ngcc.version.greaterThanOrEqual(new version_provider.Version('11.2.4'))) {
	        // See https://github.com/angular/angular/commit/241784bde8582bcbc00b8a95acdeb3b0d38fbec6
	        args.push('--typings-only');
	    }
	    const childProcess = child_process__default['default'].fork(ngcc.resolvedPath, args, {
	        cwd: path__default['default'].resolve(cwd),
	        silent: true,
	        execArgv: [],
	    });
	    let stderr = '';
	    (_a = childProcess.stderr) === null || _a === void 0 ? void 0 : _a.on('data', (data) => {
	        stderr += data.toString();
	    });
	    (_b = childProcess.stdout) === null || _b === void 0 ? void 0 : _b.on('data', (data) => {
	        for (let entry of data.toString().split('\n')) {
	            entry = entry.trim();
	            if (entry) {
	                progress.report(entry);
	            }
	        }
	    });
	    return new Promise((resolve, reject) => {
	        childProcess.on('error', (error) => {
	            reject(error);
	        });
	        childProcess.on('close', (code) => {
	            if (code === 0) {
	                resolve();
	            }
	            else {
	                reject(new Error(`ngcc for ${tsconfig} returned exit code ${code}, stderr: ${stderr.trim()}`));
	            }
	        });
	    });
	}
	exports.resolveAndRunNgcc = resolveAndRunNgcc;

	});

	unwrapExports(ngcc);
	ngcc.resolveAndRunNgcc;

	var session = createCommonjsModule(function (module, exports) {
	/**
	 * @license
	 * Copyright Google Inc. All Rights Reserved.
	 *
	 * Use of this source code is governed by an MIT-style license that can be
	 * found in the LICENSE file at https://angular.io/license
	 */
	Object.defineProperty(exports, "__esModule", { value: true });
	exports.Session = void 0;













	var LanguageId;
	(function (LanguageId) {
	    LanguageId["TS"] = "typescript";
	    LanguageId["HTML"] = "html";
	})(LanguageId || (LanguageId = {}));
	// Empty definition range for files without `scriptInfo`
	const EMPTY_RANGE = node__default['default'].Range.create(0, 0, 0, 0);
	const setImmediateP = util__default['default'].promisify(setImmediate);
	/**
	 * Session is a wrapper around lsp.IConnection, with all the necessary protocol
	 * handlers installed for Angular language service.
	 */
	class Session {
	    constructor(options) {
	        this.angularCoreVersionMap = new WeakMap();
	        this.configuredProjToExternalProj = new Map();
	        this.openFiles = new utils.MruTracker();
	        this.diagnosticsTimeout = null;
	        this.isProjectLoading = false;
	        /**
	         * Tracks which `ts.server.Project`s have the renaming capability disabled.
	         *
	         * If we detect the compiler options diagnostic that suggests enabling strict mode, we want to
	         * disable renaming because we know that there are many cases where it will not work correctly.
	         */
	        this.renameDisabledProjects = new WeakSet();
	        this.logger = options.logger;
	        this.ivy = options.ivy;
	        this.logToConsole = options.logToConsole;
	        // Create a connection for the server. The connection uses Node's IPC as a transport.
	        this.connection = node__default['default'].createConnection({
	            // cancelUndispatched is a "middleware" to handle all cancellation requests.
	            // LSP spec requires every request to send a response back, even if it is
	            // cancelled. See
	            // https://microsoft.github.io/language-server-protocol/specifications/specification-current/#cancelRequest
	            cancelUndispatched(message) {
	                return {
	                    jsonrpc: message.jsonrpc,
	                    // This ID is just a placeholder to satisfy the ResponseMessage type.
	                    // `vscode-jsonrpc` will replace the ID with the ID of the message to
	                    // be cancelled. See
	                    // https://github.com/microsoft/vscode-languageserver-node/blob/193f06bf602ee1120afda8f0bac33c5161cab18e/jsonrpc/src/common/connection.ts#L619
	                    id: -1,
	                    error: new node__default['default'].ResponseError(node__default['default'].LSPErrorCodes.RequestCancelled, 'Request cancelled'),
	                };
	            }
	        });
	        this.addProtocolHandlers(this.connection);
	        this.projectService = this.createProjectService(options);
	    }
	    createProjectService(options) {
	        const projSvc = new tsserverlibrary__default['default'].server.ProjectService({
	            host: options.host,
	            logger: options.logger,
	            cancellationToken: tsserverlibrary__default['default'].server.nullCancellationToken,
	            useSingleInferredProject: true,
	            useInferredProjectPerProjectRoot: true,
	            typingsInstaller: tsserverlibrary__default['default'].server.nullTypingsInstaller,
	            // Not supressing diagnostic events can cause a type error to be thrown when the
	            // language server session gets an event for a file that is outside the project
	            // managed by the project service, and for which a program does not exist in the
	            // corresponding project's language service.
	            // See https://github.com/angular/vscode-ng-language-service/issues/693
	            suppressDiagnosticEvents: true,
	            eventHandler: (e) => this.handleProjectServiceEvent(e),
	            globalPlugins: [options.ngPlugin],
	            pluginProbeLocations: [options.resolvedNgLsPath],
	            // do not resolve plugins from the directory where tsconfig.json is located
	            allowLocalPluginLoads: false,
	        });
	        projSvc.setHostConfiguration({
	            formatOptions: projSvc.getHostFormatCodeOptions(),
	            extraFileExtensions: [
	                {
	                    // TODO: in View Engine getExternalFiles() returns a list of external
	                    // templates (HTML files). This configuration is no longer needed in
	                    // Ivy because Ivy returns the typecheck files.
	                    extension: '.html',
	                    isMixedContent: false,
	                    scriptKind: tsserverlibrary__default['default'].ScriptKind.Unknown,
	                },
	            ],
	            preferences: {
	                // We don't want the AutoImportProvider projects to be created. See
	                // https://devblogs.microsoft.com/typescript/announcing-typescript-4-0/#smarter-auto-imports
	                includePackageJsonAutoImports: 'off',
	            },
	        });
	        const pluginConfig = {
	            angularOnly: true,
	            ivy: options.ivy,
	        };
	        if (options.host.isG3) {
	            assert__default['default'](options.ivy === true, 'Ivy LS must be used in google3');
	            pluginConfig.forceStrictTemplates = true;
	        }
	        projSvc.configurePlugin({
	            pluginName: options.ngPlugin,
	            configuration: pluginConfig,
	        });
	        return projSvc;
	    }
	    addProtocolHandlers(conn) {
	        conn.onInitialize(p => this.onInitialize(p));
	        conn.onDidOpenTextDocument(p => this.onDidOpenTextDocument(p));
	        conn.onDidCloseTextDocument(p => this.onDidCloseTextDocument(p));
	        conn.onDidChangeTextDocument(p => this.onDidChangeTextDocument(p));
	        conn.onDidSaveTextDocument(p => this.onDidSaveTextDocument(p));
	        conn.onDefinition(p => this.onDefinition(p));
	        conn.onTypeDefinition(p => this.onTypeDefinition(p));
	        conn.onReferences(p => this.onReferences(p));
	        conn.onRenameRequest(p => this.onRenameRequest(p));
	        conn.onPrepareRename(p => this.onPrepareRename(p));
	        conn.onHover(p => this.onHover(p));
	        conn.onCompletion(p => this.onCompletion(p));
	        conn.onCompletionResolve(p => this.onCompletionResolve(p));
	        conn.onRequest(requests.GetTcbRequest, p => this.onGetTcb(p));
	    }
	    onGetTcb(params) {
	        const lsInfo = this.getLSAndScriptInfo(params.textDocument);
	        if (lsInfo === undefined) {
	            return undefined;
	        }
	        const { languageService, scriptInfo } = lsInfo;
	        const offset = utils.lspPositionToTsPosition(scriptInfo, params.position);
	        const response = languageService.getTcb(scriptInfo.fileName, offset);
	        if (response === undefined) {
	            return undefined;
	        }
	        const { fileName: tcfName } = response;
	        const tcfScriptInfo = this.projectService.getScriptInfo(tcfName);
	        if (!tcfScriptInfo) {
	            return undefined;
	        }
	        return {
	            uri: utils.filePathToUri(tcfName),
	            content: response.content,
	            selections: response.selections.map((span => utils.tsTextSpanToLspRange(tcfScriptInfo, span))),
	        };
	    }
	    enableLanguageServiceForProject(project, angularCore) {
	        const { projectName } = project;
	        if (!project.languageServiceEnabled) {
	            project.enableLanguageService();
	            // When the language service got disabled, the program was discarded via
	            // languageService.cleanupSemanticCache(). However, the program is not
	            // recreated when the language service is re-enabled. We manually mark the
	            // project as dirty to force update the graph.
	            project.markAsDirty();
	        }
	        if (!this.ivy) {
	            // Immediately enable Legacy / View Engine language service
	            this.info(`Enabling View Engine language service for ${projectName}.`);
	            this.promptToEnableIvyIfAvailable(project, angularCore);
	            return;
	        }
	        this.info(`Enabling Ivy language service for ${projectName}.`);
	        this.handleCompilerOptionsDiagnostics(project);
	        // Send diagnostics since we skipped this step when opening the file
	        // (because language service was disabled while waiting for ngcc).
	        // First, make sure the Angular project is complete.
	        this.runGlobalAnalysisForNewlyLoadedProject(project);
	    }
	    /**
	     * Invoke the compiler for the first time so that external templates get
	     * matched to the project they belong to.
	     */
	    runGlobalAnalysisForNewlyLoadedProject(project) {
	        if (!project.hasRoots()) {
	            return;
	        }
	        const fileName = project.getRootScriptInfos()[0].fileName;
	        const label = `Global analysis - getSemanticDiagnostics for ${fileName}`;
	        if (utils.isDebugMode) {
	            console.time(label);
	        }
	        // Getting semantic diagnostics will trigger a global analysis.
	        project.getLanguageService().getSemanticDiagnostics(fileName);
	        if (utils.isDebugMode) {
	            console.timeEnd(label);
	        }
	    }
	    handleCompilerOptionsDiagnostics(project) {
	        if (!utils.isConfiguredProject(project)) {
	            return;
	        }
	        const diags = project.getLanguageService().getCompilerOptionsDiagnostics();
	        const suggestStrictModeDiag = diags.find(d => d.code === -9910001);
	        if (suggestStrictModeDiag) {
	            const configFilePath = project.getConfigFilePath();
	            this.connection.sendNotification(notifications.SuggestStrictMode, {
	                configFilePath,
	                message: suggestStrictModeDiag.messageText,
	            });
	            this.renameDisabledProjects.add(project);
	        }
	        else {
	            this.renameDisabledProjects.delete(project);
	        }
	    }
	    /**
	     * An event handler that gets invoked whenever the program changes and
	     * TS ProjectService sends `ProjectUpdatedInBackgroundEvent`. This particular
	     * event is used to trigger diagnostic checks.
	     * @param event
	     */
	    handleProjectServiceEvent(event) {
	        switch (event.eventName) {
	            case tsserverlibrary__default['default'].server.ProjectLoadingStartEvent:
	                this.isProjectLoading = true;
	                this.connection.sendNotification(notifications.ProjectLoadingStart);
	                this.logger.info(`Loading new project: ${event.data.reason}`);
	                break;
	            case tsserverlibrary__default['default'].server.ProjectLoadingFinishEvent: {
	                if (this.isProjectLoading) {
	                    this.isProjectLoading = false;
	                    this.connection.sendNotification(notifications.ProjectLoadingFinish);
	                }
	                const { project } = event.data;
	                const angularCore = this.findAngularCoreOrDisableLanguageService(project);
	                if (angularCore) {
	                    if (this.ivy && isExternalAngularCore(angularCore)) {
	                        // Do not wait on this promise otherwise we'll be blocking other requests
	                        this.runNgcc(project, angularCore);
	                    }
	                    else {
	                        this.enableLanguageServiceForProject(project, angularCore);
	                    }
	                }
	                break;
	            }
	            case tsserverlibrary__default['default'].server.ProjectsUpdatedInBackgroundEvent:
	                // ProjectsUpdatedInBackgroundEvent is sent whenever diagnostics are
	                // requested via project.refreshDiagnostics()
	                this.triggerDiagnostics(event.data.openFiles, event.eventName);
	                break;
	            case tsserverlibrary__default['default'].server.ProjectLanguageServiceStateEvent:
	                this.connection.sendNotification(notifications.ProjectLanguageService, {
	                    projectName: event.data.project.getProjectName(),
	                    languageServiceEnabled: event.data.languageServiceEnabled,
	                });
	        }
	    }
	    /**
	     * Request diagnostics to be computed due to the specified `file` being opened
	     * or changed.
	     * @param file File opened / changed
	     * @param reason Trace to explain why diagnostics are requested
	     */
	    requestDiagnosticsOnOpenOrChangeFile(file, reason) {
	        const files = [];
	        if (isExternalTemplate(file)) {
	            // If only external template is opened / changed, we know for sure it will
	            // not affect other files because it is local to the Component.
	            files.push(file);
	        }
	        else {
	            // Get all open files, most recently used first.
	            for (const openFile of this.openFiles.getAll()) {
	                const scriptInfo = this.projectService.getScriptInfo(openFile);
	                if (scriptInfo) {
	                    files.push(scriptInfo.fileName);
	                }
	            }
	        }
	        this.triggerDiagnostics(files, reason);
	    }
	    /**
	     * Retrieve Angular diagnostics for the specified `files` after a specific
	     * `delay`, or renew the request if there's already a pending one.
	     * @param files files to be checked
	     * @param reason Trace to explain why diagnostics are triggered
	     * @param delay time to wait before sending request (milliseconds)
	     */
	    triggerDiagnostics(files, reason, delay = 300) {
	        // Do not immediately send a diagnostics request. Send only after user has
	        // stopped typing after the specified delay.
	        if (this.diagnosticsTimeout) {
	            // If there's an existing timeout, cancel it
	            clearTimeout(this.diagnosticsTimeout);
	        }
	        // Set a new timeout
	        this.diagnosticsTimeout = setTimeout(() => {
	            this.diagnosticsTimeout = null; // clear the timeout
	            this.sendPendingDiagnostics(files, reason);
	            // Default delay is 200ms, consistent with TypeScript. See
	            // https://github.com/microsoft/vscode/blob/7b944a16f52843b44cede123dd43ae36c0405dfd/extensions/typescript-language-features/src/features/bufferSyncSupport.ts#L493)
	        }, delay);
	    }
	    /**
	     * Execute diagnostics request for each of the specified `files`.
	     * @param files files to be checked
	     * @param reason Trace to explain why diagnostics is triggered
	     */
	    async sendPendingDiagnostics(files, reason) {
	        for (let i = 0; i < files.length; ++i) {
	            const fileName = files[i];
	            const result = this.getLSAndScriptInfo(fileName);
	            if (!result) {
	                continue;
	            }
	            const label = `${reason} - getSemanticDiagnostics for ${fileName}`;
	            if (utils.isDebugMode) {
	                console.time(label);
	            }
	            const diagnostics = result.languageService.getSemanticDiagnostics(fileName);
	            if (utils.isDebugMode) {
	                console.timeEnd(label);
	            }
	            // Need to send diagnostics even if it's empty otherwise editor state will
	            // not be updated.
	            this.connection.sendDiagnostics({
	                uri: utils.filePathToUri(fileName),
	                diagnostics: diagnostics.map(d => diagnostic.tsDiagnosticToLspDiagnostic(d, result.scriptInfo)),
	            });
	            if (this.diagnosticsTimeout) {
	                // There is a pending request to check diagnostics for all open files,
	                // so stop this one immediately.
	                return;
	            }
	            if (i < files.length - 1) {
	                // If this is not the last file, yield so that pending I/O events get a
	                // chance to run. This will open an opportunity for the server to process
	                // incoming requests. The next file will be checked in the next iteration
	                // of the event loop.
	                await setImmediateP();
	            }
	        }
	    }
	    /**
	     * Return the default project for the specified `scriptInfo` if it is already
	     * a configured project. If not, attempt to find a relevant config file and
	     * make that project its default. This method is to ensure HTML files always
	     * belong to a configured project instead of the default behavior of being in
	     * an inferred project.
	     * @param scriptInfo
	     */
	    getDefaultProjectForScriptInfo(scriptInfo) {
	        let project = this.projectService.getDefaultProjectForFile(scriptInfo.fileName, 
	        // ensureProject tries to find a default project for the scriptInfo if
	        // it does not already have one. It is not needed here because we are
	        // going to assign it a project below if it does not have one.
	        false // ensureProject
	        );
	        // TODO: verify that HTML files are attached to Inferred project by default.
	        // If they are already part of a ConfiguredProject then the following is
	        // not needed.
	        if (!project || project.projectKind !== tsserverlibrary__default['default'].server.ProjectKind.Configured) {
	            const { configFileName } = this.projectService.openClientFile(scriptInfo.fileName);
	            if (!configFileName) {
	                // Failed to find a config file. There is nothing we could do.
	                this.error(`No config file for ${scriptInfo.fileName}`);
	                return;
	            }
	            project = this.projectService.findProject(configFileName);
	            if (!project) {
	                return;
	            }
	            scriptInfo.detachAllProjects();
	            scriptInfo.attachToProject(project);
	        }
	        this.createExternalProject(project);
	        return project;
	    }
	    onInitialize(params) {
	        const serverOptions = {
	            logFile: this.logger.getLogFileName(),
	        };
	        return {
	            capabilities: {
	                textDocumentSync: node__default['default'].TextDocumentSyncKind.Incremental,
	                completionProvider: {
	                    // Only the Ivy LS provides support for additional completion resolution.
	                    resolveProvider: this.ivy,
	                    triggerCharacters: ['<', '.', '*', '[', '(', '$', '|']
	                },
	                definitionProvider: true,
	                typeDefinitionProvider: this.ivy,
	                referencesProvider: this.ivy,
	                renameProvider: this.ivy ? {
	                    // Renames should be checked and tested before being executed.
	                    prepareProvider: true,
	                } :
	                    false,
	                hoverProvider: true,
	                workspace: {
	                    workspaceFolders: { supported: true },
	                },
	            },
	            serverOptions,
	        };
	    }
	    onDidOpenTextDocument(params) {
	        var _a;
	        const { uri, languageId, text } = params.textDocument;
	        const filePath = utils.uriToFilePath(uri);
	        if (!filePath) {
	            return;
	        }
	        this.openFiles.update(filePath);
	        // External templates (HTML files) should be tagged as ScriptKind.Unknown
	        // so that they don't get parsed as TS files. See
	        // https://github.com/microsoft/TypeScript/blob/b217f22e798c781f55d17da72ed099a9dee5c650/src/compiler/program.ts#L1897-L1899
	        const scriptKind = languageId === LanguageId.TS ? tsserverlibrary__default['default'].ScriptKind.TS : tsserverlibrary__default['default'].ScriptKind.Unknown;
	        try {
	            // The content could be newer than that on disk. This could be due to
	            // buffer in the user's editor which has not been saved to disk.
	            // See https://github.com/angular/vscode-ng-language-service/issues/632
	            const result = this.projectService.openClientFile(filePath, text, scriptKind);
	            const { configFileName, configFileErrors } = result;
	            if (configFileErrors && configFileErrors.length) {
	                // configFileErrors is an empty array even if there's no error, so check length.
	                this.error(configFileErrors.map(e => e.messageText).join('\n'));
	            }
	            const project = configFileName ?
	                this.projectService.findProject(configFileName) : (_a = this.projectService.getScriptInfo(filePath)) === null || _a === void 0 ? void 0 : _a.containingProjects.find(utils.isConfiguredProject);
	            if (!project) {
	                return;
	            }
	            if (project.languageServiceEnabled) {
	                // Show initial diagnostics
	                this.requestDiagnosticsOnOpenOrChangeFile(filePath, `Opening ${filePath}`);
	            }
	        }
	        catch (error) {
	            if (this.isProjectLoading) {
	                this.isProjectLoading = false;
	                this.connection.sendNotification(notifications.ProjectLoadingFinish);
	            }
	            if (error.stack) {
	                this.error(error.stack);
	            }
	            throw error;
	        }
	        this.closeOrphanedExternalProjects();
	    }
	    /**
	     * Creates an external project with the same config path as `project` so that TypeScript keeps the
	     * project open when navigating away from `html` files.
	     */
	    createExternalProject(project) {
	        if (utils.isConfiguredProject(project) &&
	            !this.configuredProjToExternalProj.has(project.projectName)) {
	            const extProjectName = `${project.projectName}-external`;
	            project.projectService.openExternalProject({
	                projectFileName: extProjectName,
	                rootFiles: [{ fileName: project.getConfigFilePath() }],
	                options: {}
	            });
	            this.configuredProjToExternalProj.set(project.projectName, extProjectName);
	        }
	    }
	    onDidCloseTextDocument(params) {
	        const { textDocument } = params;
	        const filePath = utils.uriToFilePath(textDocument.uri);
	        if (!filePath) {
	            return;
	        }
	        this.openFiles.delete(filePath);
	        this.projectService.closeClientFile(filePath);
	    }
	    /**
	     * We open external projects for files so that we can prevent TypeScript from closing a project
	     * when there is open external HTML template that still references the project. This function
	     * checks if there are no longer any open files in any external project. If there
	     * aren't, we also close the external project that was created.
	     */
	    closeOrphanedExternalProjects() {
	        for (const [configuredProjName, externalProjName] of this.configuredProjToExternalProj) {
	            const configuredProj = this.projectService.findProject(configuredProjName);
	            if (!configuredProj || configuredProj.isClosed()) {
	                this.projectService.closeExternalProject(externalProjName);
	                this.configuredProjToExternalProj.delete(configuredProjName);
	                continue;
	            }
	            // See if any openFiles belong to the configured project.
	            // if not, close external project this.projectService.openFiles
	            const openFiles = toArray(this.projectService.openFiles.keys());
	            if (!openFiles.some(file => {
	                const scriptInfo = this.projectService.getScriptInfo(file);
	                return scriptInfo === null || scriptInfo === void 0 ? void 0 : scriptInfo.isAttached(configuredProj);
	            })) {
	                this.projectService.closeExternalProject(externalProjName);
	                this.configuredProjToExternalProj.delete(configuredProjName);
	            }
	        }
	    }
	    onDidChangeTextDocument(params) {
	        const { contentChanges, textDocument } = params;
	        const filePath = utils.uriToFilePath(textDocument.uri);
	        if (!filePath) {
	            return;
	        }
	        this.openFiles.update(filePath);
	        const scriptInfo = this.projectService.getScriptInfo(filePath);
	        if (!scriptInfo) {
	            this.error(`Failed to get script info for ${filePath}`);
	            return;
	        }
	        for (const change of contentChanges) {
	            if ('range' in change) {
	                const [start, end] = utils.lspRangeToTsPositions(scriptInfo, change.range);
	                scriptInfo.editContent(start, end, change.text);
	            }
	            else {
	                // New text is considered to be the full content of the document.
	                scriptInfo.editContent(0, scriptInfo.getSnapshot().getLength(), change.text);
	            }
	        }
	        const project = this.getDefaultProjectForScriptInfo(scriptInfo);
	        if (!project || !project.languageServiceEnabled) {
	            return;
	        }
	        this.requestDiagnosticsOnOpenOrChangeFile(scriptInfo.fileName, `Changing ${filePath}`);
	    }
	    onDidSaveTextDocument(params) {
	        const { text, textDocument } = params;
	        const filePath = utils.uriToFilePath(textDocument.uri);
	        if (!filePath) {
	            return;
	        }
	        this.openFiles.update(filePath);
	        const scriptInfo = this.projectService.getScriptInfo(filePath);
	        if (!scriptInfo) {
	            return;
	        }
	        if (text) {
	            scriptInfo.open(text);
	        }
	        else {
	            scriptInfo.reloadFromFile();
	        }
	    }
	    onDefinition(params) {
	        const lsInfo = this.getLSAndScriptInfo(params.textDocument);
	        if (lsInfo === undefined) {
	            return;
	        }
	        const { languageService, scriptInfo } = lsInfo;
	        const offset = utils.lspPositionToTsPosition(scriptInfo, params.position);
	        const definition = languageService.getDefinitionAndBoundSpan(scriptInfo.fileName, offset);
	        if (!definition || !definition.definitions) {
	            return;
	        }
	        const originSelectionRange = utils.tsTextSpanToLspRange(scriptInfo, definition.textSpan);
	        return this.tsDefinitionsToLspLocationLinks(definition.definitions, originSelectionRange);
	    }
	    onTypeDefinition(params) {
	        const lsInfo = this.getLSAndScriptInfo(params.textDocument);
	        if (lsInfo === undefined) {
	            return;
	        }
	        const { languageService, scriptInfo } = lsInfo;
	        const offset = utils.lspPositionToTsPosition(scriptInfo, params.position);
	        const definitions = languageService.getTypeDefinitionAtPosition(scriptInfo.fileName, offset);
	        if (!definitions) {
	            return;
	        }
	        return this.tsDefinitionsToLspLocationLinks(definitions);
	    }
	    onRenameRequest(params) {
	        const lsInfo = this.getLSAndScriptInfo(params.textDocument);
	        if (lsInfo === undefined) {
	            return;
	        }
	        const { languageService, scriptInfo } = lsInfo;
	        if (scriptInfo.scriptKind === tsserverlibrary__default['default'].ScriptKind.TS) {
	            // Because we cannot ensure our extension is prioritized for renames in TS files (see
	            // https://github.com/microsoft/vscode/issues/115354) we disable renaming completely so we can
	            // provide consistent expectations.
	            return;
	        }
	        const project = this.getDefaultProjectForScriptInfo(scriptInfo);
	        if (project === undefined || this.renameDisabledProjects.has(project)) {
	            return;
	        }
	        const offset = utils.lspPositionToTsPosition(scriptInfo, params.position);
	        const renameLocations = languageService.findRenameLocations(scriptInfo.fileName, offset, /*findInStrings*/ false, /*findInComments*/ false);
	        if (renameLocations === undefined) {
	            return;
	        }
	        const changes = renameLocations.reduce((changes, location) => {
	            if (changes[location.fileName] === undefined) {
	                changes[location.fileName] = [];
	            }
	            const fileEdits = changes[location.fileName];
	            const lsInfo = this.getLSAndScriptInfo(location.fileName);
	            if (lsInfo === undefined) {
	                return changes;
	            }
	            const range = utils.tsTextSpanToLspRange(lsInfo.scriptInfo, location.textSpan);
	            fileEdits.push({ range, newText: params.newName });
	            return changes;
	        }, {});
	        return { changes };
	    }
	    onPrepareRename(params) {
	        const lsInfo = this.getLSAndScriptInfo(params.textDocument);
	        if (lsInfo === undefined) {
	            return;
	        }
	        const { languageService, scriptInfo } = lsInfo;
	        if (scriptInfo.scriptKind === tsserverlibrary__default['default'].ScriptKind.TS) {
	            // Because we cannot ensure our extension is prioritized for renames in TS files (see
	            // https://github.com/microsoft/vscode/issues/115354) we disable renaming completely so we can
	            // provide consistent expectations.
	            return;
	        }
	        const project = this.getDefaultProjectForScriptInfo(scriptInfo);
	        if (project === undefined || this.renameDisabledProjects.has(project)) {
	            return;
	        }
	        const offset = utils.lspPositionToTsPosition(scriptInfo, params.position);
	        const renameInfo = languageService.getRenameInfo(scriptInfo.fileName, offset);
	        if (!renameInfo.canRename) {
	            return undefined;
	        }
	        const range = utils.tsTextSpanToLspRange(scriptInfo, renameInfo.triggerSpan);
	        return {
	            range,
	            placeholder: renameInfo.displayName,
	        };
	    }
	    onReferences(params) {
	        const lsInfo = this.getLSAndScriptInfo(params.textDocument);
	        if (lsInfo === undefined) {
	            return;
	        }
	        const { languageService, scriptInfo } = lsInfo;
	        const offset = utils.lspPositionToTsPosition(scriptInfo, params.position);
	        const references = languageService.getReferencesAtPosition(scriptInfo.fileName, offset);
	        if (references === undefined) {
	            return;
	        }
	        return references.map(ref => {
	            const scriptInfo = this.projectService.getScriptInfo(ref.fileName);
	            const range = scriptInfo ? utils.tsTextSpanToLspRange(scriptInfo, ref.textSpan) : EMPTY_RANGE;
	            const uri = utils.filePathToUri(ref.fileName);
	            return { uri, range };
	        });
	    }
	    tsDefinitionsToLspLocationLinks(definitions, originSelectionRange) {
	        const results = [];
	        for (const d of definitions) {
	            const scriptInfo = this.projectService.getScriptInfo(d.fileName);
	            // Some definitions, like definitions of CSS files, may not be recorded files with a
	            // `scriptInfo` but are still valid definitions because they are files that exist. In this
	            // case, check to make sure that the text span of the definition is zero so that the file
	            // doesn't have to be read; if the span is non-zero, we can't do anything with this
	            // definition.
	            if (!scriptInfo && d.textSpan.length > 0) {
	                continue;
	            }
	            const range = scriptInfo ? utils.tsTextSpanToLspRange(scriptInfo, d.textSpan) : EMPTY_RANGE;
	            const targetUri = utils.filePathToUri(d.fileName);
	            results.push({
	                originSelectionRange,
	                targetUri,
	                targetRange: range,
	                targetSelectionRange: range,
	            });
	        }
	        return results;
	    }
	    getLSAndScriptInfo(textDocumentOrFileName) {
	        const filePath = node__default['default'].TextDocumentIdentifier.is(textDocumentOrFileName) ?
	            utils.uriToFilePath(textDocumentOrFileName.uri) :
	            textDocumentOrFileName;
	        const scriptInfo = this.projectService.getScriptInfo(filePath);
	        if (!scriptInfo) {
	            this.error(`Script info not found for ${filePath}`);
	            return;
	        }
	        const project = this.getDefaultProjectForScriptInfo(scriptInfo);
	        if (!(project === null || project === void 0 ? void 0 : project.languageServiceEnabled)) {
	            return;
	        }
	        if (project.isClosed()) {
	            scriptInfo.detachFromProject(project);
	            this.logger.info(`Failed to get language service for closed project ${project.projectName}.`);
	            return undefined;
	        }
	        const languageService = project.getLanguageService();
	        if (!api__default['default'].isNgLanguageService(languageService)) {
	            return undefined;
	        }
	        return {
	            languageService,
	            scriptInfo,
	        };
	    }
	    onHover(params) {
	        const lsInfo = this.getLSAndScriptInfo(params.textDocument);
	        if (lsInfo === undefined) {
	            return;
	        }
	        const { languageService, scriptInfo } = lsInfo;
	        const offset = utils.lspPositionToTsPosition(scriptInfo, params.position);
	        const info = languageService.getQuickInfoAtPosition(scriptInfo.fileName, offset);
	        if (!info) {
	            return;
	        }
	        const { kind, kindModifiers, textSpan, displayParts, documentation } = info;
	        let desc = kindModifiers ? kindModifiers + ' ' : '';
	        if (displayParts) {
	            // displayParts does not contain info about kindModifiers
	            // but displayParts does contain info about kind
	            desc += displayParts.map(dp => dp.text).join('');
	        }
	        else {
	            desc += kind;
	        }
	        const contents = [{
	                language: 'typescript',
	                value: desc,
	            }];
	        if (documentation) {
	            for (const d of documentation) {
	                contents.push(d.text);
	            }
	        }
	        return {
	            contents,
	            range: utils.tsTextSpanToLspRange(scriptInfo, textSpan),
	        };
	    }
	    onCompletion(params) {
	        const lsInfo = this.getLSAndScriptInfo(params.textDocument);
	        if (lsInfo === undefined) {
	            return;
	        }
	        const { languageService, scriptInfo } = lsInfo;
	        const offset = utils.lspPositionToTsPosition(scriptInfo, params.position);
	        const completions = languageService.getCompletionsAtPosition(scriptInfo.fileName, offset, {
	        // options
	        });
	        if (!completions) {
	            return;
	        }
	        return completions.entries.map((e) => completion.tsCompletionEntryToLspCompletionItem(e, params.position, scriptInfo));
	    }
	    onCompletionResolve(item) {
	        var _a;
	        const data = completion.readNgCompletionData(item);
	        if (data === null) {
	            // This item wasn't tagged with Angular LS completion data - it probably didn't originate
	            // from this language service.
	            return item;
	        }
	        const { filePath, position } = data;
	        const lsInfo = this.getLSAndScriptInfo(filePath);
	        if (lsInfo === undefined) {
	            return item;
	        }
	        const { languageService, scriptInfo } = lsInfo;
	        const offset = utils.lspPositionToTsPosition(scriptInfo, position);
	        const details = languageService.getCompletionEntryDetails(filePath, offset, (_a = item.insertText) !== null && _a !== void 0 ? _a : item.label, undefined, undefined, undefined);
	        if (details === undefined) {
	            return item;
	        }
	        const { kind, kindModifiers, displayParts, documentation } = details;
	        let desc = kindModifiers ? kindModifiers + ' ' : '';
	        if (displayParts) {
	            // displayParts does not contain info about kindModifiers
	            // but displayParts does contain info about kind
	            desc += displayParts.map(dp => dp.text).join('');
	        }
	        else {
	            desc += kind;
	        }
	        item.detail = desc;
	        item.documentation = documentation === null || documentation === void 0 ? void 0 : documentation.map(d => d.text).join('');
	        return item;
	    }
	    /**
	     * Show an error message in the remote console and log to file.
	     *
	     * @param message The message to show.
	     */
	    error(message) {
	        if (this.logToConsole) {
	            this.connection.console.error(message);
	        }
	        this.logger.msg(message, tsserverlibrary__default['default'].server.Msg.Err);
	    }
	    /**
	     * Show a warning message in the remote console and log to file.
	     *
	     * @param message The message to show.
	     */
	    warn(message) {
	        if (this.logToConsole) {
	            this.connection.console.warn(message);
	        }
	        // ts.server.Msg does not have warning level, so log as info.
	        this.logger.msg(`[WARN] ${message}`, tsserverlibrary__default['default'].server.Msg.Info);
	    }
	    /**
	     * Show an information message in the remote console and log to file.
	     *
	     * @param message The message to show.
	     */
	    info(message) {
	        if (this.logToConsole) {
	            this.connection.console.info(message);
	        }
	        this.logger.msg(message, tsserverlibrary__default['default'].server.Msg.Info);
	    }
	    /**
	     * Start listening on the input stream for messages to process.
	     */
	    listen() {
	        this.connection.listen();
	    }
	    /**
	     * Find the main declaration file for `@angular/core` in the specified
	     * `project`. If found, return the declaration file. Otherwise, disable the
	     * language service and return undefined.
	     *
	     * @returns main declaration file in `@angular/core`.
	     */
	    findAngularCoreOrDisableLanguageService(project) {
	        const { projectName } = project;
	        if (!project.languageServiceEnabled) {
	            this.info(`Language service is already disabled for ${projectName}. ` +
	                `This could be due to non-TS files that exceeded the size limit (${tsserverlibrary__default['default'].server.maxProgramSizeForNonTsFiles} bytes).` +
	                `Please check log file for details.`);
	            return;
	        }
	        if (!project.hasRoots() || project.isNonTsProject()) {
	            return undefined;
	        }
	        const angularCore = project.getFileNames().find(isAngularCore);
	        if (angularCore === undefined) {
	            project.disableLanguageService();
	            this.info(`Disabling language service for ${projectName} because it is not an Angular project ` +
	                `('@angular/core' could not be found).`);
	            if (project.getExcludedFiles().some(isAngularCore)) {
	                this.info(`Please check your tsconfig.json to make sure 'node_modules' directory is not excluded.`);
	            }
	        }
	        return angularCore;
	    }
	    /**
	     * Disable the language service, run ngcc, then re-enable language service.
	     */
	    async runNgcc(project, angularCore) {
	        if (!utils.isConfiguredProject(project)) {
	            return;
	        }
	        // Disable language service until ngcc is completed.
	        project.disableLanguageService();
	        const configFilePath = project.getConfigFilePath();
	        this.connection.sendProgress(progress.NgccProgressType, progress.NgccProgressToken, {
	            done: false,
	            configFilePath,
	            message: `Running ngcc for ${configFilePath}`,
	        });
	        let success = false;
	        try {
	            await ngcc.resolveAndRunNgcc(configFilePath, {
	                report: (msg) => {
	                    this.connection.sendProgress(progress.NgccProgressType, progress.NgccProgressToken, {
	                        done: false,
	                        configFilePath,
	                        message: msg,
	                    });
	                },
	            });
	            success = true;
	        }
	        catch (e) {
	            this.error(`Failed to run ngcc for ${configFilePath}:\n` +
	                `    ${e.message}\n` +
	                `    Language service will remain disabled.`);
	        }
	        finally {
	            this.connection.sendProgress(progress.NgccProgressType, progress.NgccProgressToken, {
	                done: true,
	                configFilePath,
	                success,
	            });
	        }
	        // Re-enable language service even if ngcc fails, because users could fix
	        // the problem by running ngcc themselves. If we keep language service
	        // disabled, there's no way users could use the extension even after
	        // resolving ngcc issues. On the client side, we will warn users about
	        // potentially degraded experience.
	        this.enableLanguageServiceForProject(project, angularCore);
	    }
	    promptToEnableIvyIfAvailable(project, coreDts) {
	        var _a;
	        let angularCoreVersion = this.angularCoreVersionMap.get(project);
	        if (angularCoreVersion === undefined) {
	            angularCoreVersion = (_a = version_provider.resolve('@angular/core', coreDts)) === null || _a === void 0 ? void 0 : _a.version;
	        }
	        if (angularCoreVersion !== undefined && !this.ivy && angularCoreVersion.major >= 9) {
	            this.connection.sendNotification(notifications.SuggestIvyLanguageService, {
	                message: 'Would you like to enable the new Ivy-native language service to get the latest features and bug fixes?',
	            });
	        }
	    }
	}
	exports.Session = Session;
	function toArray(it) {
	    const results = [];
	    for (let itResult = it.next(); !itResult.done; itResult = it.next()) {
	        results.push(itResult.value);
	    }
	    return results;
	}
	function isAngularCore(path) {
	    return isExternalAngularCore(path) || isInternalAngularCore(path);
	}
	function isExternalAngularCore(path) {
	    return path.endsWith('@angular/core/core.d.ts');
	}
	function isInternalAngularCore(path) {
	    return path.endsWith('angular2/rc/packages/core/index.d.ts');
	}
	function isTypeScriptFile(path) {
	    return path.endsWith('.ts');
	}
	function isExternalTemplate(path) {
	    return !isTypeScriptFile(path);
	}

	});

	unwrapExports(session);
	session.Session;

	var server = createCommonjsModule(function (module, exports) {
	/**
	 * @license
	 * Copyright Google Inc. All Rights Reserved.
	 *
	 * Use of this source code is governed by an MIT-style license that can be
	 * found in the LICENSE file at https://angular.io/license
	 */
	Object.defineProperty(exports, "__esModule", { value: true });





	// Parse command line arguments
	const options = cmdline_utils.parseCommandLine(process.argv);
	if (options.help) {
	    console.error(cmdline_utils.generateHelpMessage(process.argv));
	    process.exit(0);
	}
	// Create a logger that logs to file. OK to emit verbose entries.
	const logger$1 = logger.createLogger({
	    logFile: options.logFile,
	    logVerbosity: options.logVerbosity,
	});
	const ts = version_provider.resolveTsServer(options.tsProbeLocations);
	const isG3 = ts.resolvedPath.includes('/google3/');
	const ivy = isG3 ? true : options.ivy;
	const ng = version_provider.resolveNgLangSvc(options.ngProbeLocations, ivy);
	// ServerHost provides native OS functionality
	const host = new server_host.ServerHost(ivy, isG3);
	// Establish a new server session that encapsulates lsp connection.
	const session$1 = new session.Session({
	    host,
	    logger: logger$1,
	    ngPlugin: version_provider.NGLANGSVC,
	    resolvedNgLsPath: ng.resolvedPath,
	    ivy,
	    logToConsole: options.logToConsole,
	});
	// Log initialization info
	session$1.info(`Angular language server process ID: ${process.pid}`);
	session$1.info(`Using ${ts.name} v${ts.version} from ${ts.resolvedPath}`);
	session$1.info(`Using ${ng.name} v${ng.version} from ${ng.resolvedPath}`);
	if (logger$1.loggingEnabled()) {
	    session$1.info(`Log file: ${logger$1.getLogFileName()}`);
	}
	else {
	    session$1.info(`Logging is turned off. To enable, run command 'Open Angular server log'.`);
	}
	if (process.env.NG_DEBUG === 'true') {
	    session$1.info('Angular Language Service is running under DEBUG mode');
	}
	session$1.listen();

	});

	var server$1 = unwrapExports(server);

	return server$1;

});
