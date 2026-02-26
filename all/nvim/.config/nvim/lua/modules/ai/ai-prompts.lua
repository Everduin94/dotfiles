--[[

{buffers}: A list of all open buffers.
{file}: The current file path.
{position}: The cursor position in the current file.
{line}: The current line.
{selection}: The visual selection.
{diagnostics}: The diagnostics for the current buffer.
{diagnostics_all}: All diagnostics in the workspace.
{quickfix}: The current quickfix list, including title and formatted items.
{function}: The function at cursor (Tree-sitter) - returns location like function foo @file:10:5.
{class}: The class/struct at cursor (Tree-sitter) - returns location.
{this}: A special context variable. If the current buffer is a file, it resolves to {position}. Otherwise, it resolves to the literal string "this" and appends the current {selection} to the prompt.

--]]
local M = {
  refactor = "Refactor {this} to be maintainable",
}

return M
