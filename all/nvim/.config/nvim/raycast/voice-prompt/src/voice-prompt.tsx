import { Action, ActionPanel, Clipboard, Detail, Icon, getPreferenceValues, showToast, Toast } from "@raycast/api";
import { ChildProcessWithoutNullStreams, spawn } from "node:child_process";
import { dirname } from "node:path";
import { useEffect, useRef, useState } from "react";

type Status = "starting" | "recording" | "processing" | "done" | "error";

type Preferences = {
  pythonBin: string;
  scriptPath: string;
};

export default function Command() {
  const { pythonBin, scriptPath } = getPreferenceValues<Preferences>();

  const processRef = useRef<ChildProcessWithoutNullStreams | null>(null);
  const outputRef = useRef("");
  const [status, setStatus] = useState<Status>("starting");
  const [transcript, setTranscript] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    let mounted = true;

    async function run() {
      const toast = await showToast({
        style: Toast.Style.Animated,
        title: "Starting recording",
        message: "Launching Python whisper script",
      });

      const child = spawn(pythonBin, [scriptPath], {
        cwd: dirname(scriptPath),
        env: process.env,
      });

      processRef.current = child;
      setStatus("recording");

      child.stdout.on("data", (chunk) => {
        outputRef.current += chunk.toString();
      });

      child.stderr.on("data", (chunk) => {
        outputRef.current += chunk.toString();
      });

      child.on("error", (spawnError) => {
        if (!mounted) {
          return;
        }

        const message = String(spawnError);
        setError(message);
        setStatus("error");
        toast.style = Toast.Style.Failure;
        toast.title = "Failed to start";
        toast.message = message;
      });

      child.on("exit", async (code) => {
        if (!mounted) {
          return;
        }

        processRef.current = null;

        if (code === 0) {
          const clipboardText = (await Clipboard.readText()) ?? "";
          setTranscript(clipboardText);
          setStatus("done");
          toast.style = Toast.Style.Success;
          toast.title = "Transcript copied";
          toast.message = clipboardText ? "Ready to paste" : "No clipboard text found";
          return;
        }

        const details = outputRef.current.trim() || `Process exited with code ${code}`;
        setError(details);
        setStatus("error");
        toast.style = Toast.Style.Failure;
        toast.title = "Voice prompt failed";
        toast.message = `Exit code ${code}`;
      });
    }

    run();

    return () => {
      mounted = false;
      if (processRef.current) {
        processRef.current.kill("SIGINT");
      }
    };
  }, [pythonBin, scriptPath]);

  function stopRecording() {
    if (!processRef.current) {
      return;
    }

    setStatus("processing");
    processRef.current.kill("SIGINT");
  }

  return (
    <Detail
      markdown={renderMarkdown(status, transcript, error)}
      actions={
        <ActionPanel>
          {status === "recording" ? (
            <Action
              title="Stop Recording"
              icon={Icon.Stop}
              shortcut={{ modifiers: ["ctrl"], key: "x" }}
              onAction={stopRecording}
            />
          ) : null}
          {transcript ? <Action.CopyToClipboard title="Copy Transcript Again" content={transcript} /> : null}
        </ActionPanel>
      }
    />
  );
}

function renderMarkdown(status: Status, transcript: string, error: string) {
  if (status === "recording") {
    return [
      "# Recording",
      "",
      "Speak now.",
      "",
      "Press `ctrl + x` to stop recording.",
    ].join("\n");
  }

  if (status === "processing") {
    return [
      "# Processing",
      "",
      "Finalizing audio and running Faster Whisper.",
    ].join("\n");
  }

  if (status === "done") {
    return [
      "# Done",
      "",
      "Transcript copied to clipboard.",
      "",
      transcript ? "## Preview\n\n```text\n" + transcript.trim() + "\n```" : "No transcript preview available.",
    ].join("\n");
  }

  if (status === "error") {
    return [
      "# Error",
      "",
      "```text",
      error || "Unknown error",
      "```",
    ].join("\n");
  }

  return [
    "# Starting",
    "",
    "Launching the recorder.",
  ].join("\n");
}
