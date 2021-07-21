// "Here's an updated snippet which will return URIs of workspace files except
// for those ignored either by search.exclude or files.exclude or .gitignore."
// via:
// https://github.com/microsoft/vscode/issues/48674
import { workspace, Uri } from 'vscode';
import { exec, ExecException } from 'child_process';
// import applicationInsights from './telemetry';
import { join } from 'path';

export default async function findNonIgnoredFiles(
  pattern: string,
  checkGitIgnore = true
): Promise<Uri[]> {
  const exclude = [
    ...Object.keys((await workspace.getConfiguration('search', null).get('exclude')) || {}),
    ...Object.keys((await workspace.getConfiguration('files', null).get('exclude')) || {}),
  ].join(',');

  const uris = await workspace.findFiles(pattern, `{${exclude}}`);
  if (!checkGitIgnore) {
    return uris;
  }
  return filterGitIgnored(uris);
}

// TODO: https://github.com/Microsoft/vscode/blob/release/1.27/extensions/git/src/api/git.d.ts instead of git shell if possible
async function filterGitIgnored(uris: Uri[]): Promise<Uri[]> {
  const workspaceRelativePaths = uris.map((uri) => workspace.asRelativePath(uri, false));
  for (const workspaceDirectory of workspace.workspaceFolders!) {
    const workspaceDirectoryPath = workspaceDirectory.uri.fsPath;
    try {
      const { stdout, stderr } = await new Promise<{ stdout: string; stderr: string }>(
        (resolve, reject) => {
          exec(
            `git check-ignore ${workspaceRelativePaths.join(' ')}`,
            { cwd: workspaceDirectoryPath },
            // https://git-scm.com/docs/git-check-ignore#_exit_status
            (error: ExecException | null, stdout, stderr) => {
              if (error && error.code !== 0 && error.code !== 1) {
                reject(error);
                return;
              }

              resolve({ stdout, stderr });
            }
          );
        }
      );

      if (stderr) {
        throw new Error(stderr);
      }

      for (const relativePath of stdout.split('\n')) {
        const uri = Uri.file(
          join(workspaceDirectoryPath, relativePath.slice(1, -1) /* Remove quotes */)
        );
        const index = uris.findIndex((u) => u.fsPath === uri.fsPath);
        if (index > -1) {
          uris.splice(index, 1);
        }
      }
    } catch (error) {
      console.error('findNonIgnoredFiles-git-exec-error', error);
      //   applicationInsights.sendTelemetryEvent('findNonIgnoredFiles-git-exec-error');
    }
  }
  return uris;
}
