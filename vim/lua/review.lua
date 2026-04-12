-- Code review: one tab per changed file, file on top, delta diff below.
-- Re-running refreshes existing review tabs in place, closes tabs for files no
-- longer changed, and opens new tabs for newly-changed files. Terminal-width
-- aware: side-by-side when there's room, unified when narrow.

local M = {}

local WIDE_THRESHOLD = 180

local function is_wide()
  return vim.o.columns >= WIDE_THRESHOLD
end

-- Mode (wide vs narrow) at which review tabs were last rendered, so VimResized
-- knows whether a refresh is needed.
local last_wide = nil

local function delta_cmd()
  if is_wide() then
    return 'delta --side-by-side --paging=never'
  end
  return 'delta --paging=never'
end

local function build_diff_cmd(root, base_ref, rel, is_untracked)
  if is_untracked then
    return string.format(
      'git -C %s diff --no-index -- /dev/null %s | %s',
      vim.fn.shellescape(root),
      vim.fn.shellescape(rel),
      delta_cmd()
    )
  end
  return string.format(
    'git -C %s diff %s -- %s | %s',
    vim.fn.shellescape(root),
    vim.fn.shellescape(base_ref),
    vim.fn.shellescape(rel),
    delta_cmd()
  )
end

local function build_stats_cmd(root, base_ref)
  return string.format(
    'git -C %s --no-pager diff --stat --color=always %s',
    vim.fn.shellescape(root),
    vim.fn.shellescape(base_ref)
  )
end

local function git_root()
  local root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 or not root or root == '' then
    return nil
  end
  return root
end

local function fetch_untracked(root)
  local set = {}
  local list = vim.fn.systemlist({'git', '-C', root, 'ls-files', '--others', '--exclude-standard'})
  for _, f in ipairs(list) do set[f] = true end
  return set
end

-- Find a window in a tab by whether its buffer is a terminal.
local function find_win_by_term(tab, want_terminal)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    local is_term = vim.bo[vim.api.nvim_win_get_buf(win)].buftype == 'terminal'
    if is_term == want_terminal then
      return win
    end
  end
  return nil
end

-- Read a tabpage variable, returning nil if unset (instead of raising).
local function tab_var(tab, name)
  local ok, val = pcall(vim.api.nvim_tabpage_get_var, tab, name)
  if ok then return val end
  return nil
end

-- Review tab metadata: stats flag or file path, plus stored base ref (if any).
-- Returns nil if this isn't a review tab.
local function review_info(tab)
  if tab_var(tab, 'review_stats') then
    return {base_ref = tab_var(tab, 'review_base'), stats = true}
  end
  local rel = tab_var(tab, 'review_file')
  if rel then
    return {base_ref = tab_var(tab, 'review_base'), rel = rel}
  end
  return nil
end

local function is_review_tab(tab)
  return review_info(tab) ~= nil
end

-- Pick the right command (stats or file diff) for an existing review tab.
local function cmd_for_review_tab(info, root, base_ref, untracked_set)
  if info.stats then
    return build_stats_cmd(root, base_ref)
  end
  return build_diff_cmd(root, base_ref, info.rel, untracked_set[info.rel] or false)
end

-- Parse the "new file" line number from a delta side-by-side output line.
-- Delta's ANSI-stripped format is: │ old_num │ old_content │ new_num │ new_content
-- The new line number lives in field 4 (after splitting on │).
local function parse_new_line_num(line)
  if not line or line == '' then return nil end
  local parts = vim.split(line, '│', {plain = true})
  if #parts < 4 then return nil end
  local num = parts[4]:match('%d+')
  return num and tonumber(num) or nil
end

-- Called from <CR> in a review terminal buffer. Walks up from the cursor line
-- looking for a parseable new-file line number, then jumps the file pane in
-- the same tab to that line.
local function jump_to_file_line()
  local term_buf = vim.api.nvim_get_current_buf()
  if vim.bo[term_buf].buftype ~= 'terminal' then return end
  local row = vim.api.nvim_win_get_cursor(0)[1]

  local line_num
  for r = row, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(term_buf, r - 1, r, false)[1]
    local n = parse_new_line_num(line)
    if n then line_num = n; break end
  end
  if not line_num then
    vim.notify('No diff line number at cursor', vim.log.levels.INFO)
    return
  end

  local tab = vim.api.nvim_get_current_tabpage()
  local file_win = find_win_by_term(tab, false)
  if not file_win then
    vim.notify('No file pane in this tab', vim.log.levels.INFO)
    return
  end
  vim.api.nvim_set_current_win(file_win)
  local file_buf = vim.api.nvim_win_get_buf(file_win)
  local max_line = vim.api.nvim_buf_line_count(file_buf)
  vim.api.nvim_win_set_cursor(file_win, {math.min(line_num, max_line), 0})
  vim.cmd('normal! zz')
end

-- Run a diff command in a new terminal buffer and wire up review keymaps.
-- Must be called in the window that should host the terminal.
local function open_diff_terminal(cmd)
  vim.cmd('terminal ' .. cmd)
  vim.bo.buflisted = false
  vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], {buffer = true, desc = 'Exit terminal mode'})
  vim.keymap.set('n', '<CR>', jump_to_file_line, {buffer = true, desc = 'Jump to diff line in file'})
end

-- Replace (or create) a tab's terminal pane with a fresh run of `cmd`.
-- Used by both file-review refresh (diff cmd) and stats-tab refresh (stat cmd).
local function render_cmd_into_tab(tab, cmd)
  vim.api.nvim_set_current_tabpage(tab)
  local term_win = find_win_by_term(tab, true)
  if term_win then
    vim.api.nvim_set_current_win(term_win)
    local old_buf = vim.api.nvim_win_get_buf(term_win)
    open_diff_terminal(cmd)
    pcall(vim.api.nvim_buf_delete, old_buf, {force = true})
  else
    vim.cmd('topleft split')
    open_diff_terminal(cmd)
  end
  -- Leave focus on the diff (terminal) pane.
  local focus_term = find_win_by_term(tab, true)
  if focus_term then
    vim.api.nvim_set_current_win(focus_term)
  end
end

-- Re-render every existing review tab at the current terminal width.
-- Doesn't add or remove tabs. Returns true if any tab was touched.
local function refresh_all_review_tabs()
  local root = git_root()
  if not root then return false end
  local untracked_set = fetch_untracked(root)
  local prev_tab = vim.api.nvim_get_current_tabpage()
  local touched = false
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local info = review_info(tab)
    if info and info.base_ref then
      render_cmd_into_tab(tab, cmd_for_review_tab(info, root, info.base_ref, untracked_set))
      touched = true
    end
  end
  pcall(vim.api.nvim_set_current_tabpage, prev_tab)
  if touched then
    last_wide = is_wide()
  end
  return touched
end

local function review_against(base_ref)
  local root = git_root()
  if not root then
    vim.notify('Not in a git repo', vim.log.levels.ERROR)
    return
  end
  local files = vim.fn.systemlist({'git', '-C', root, 'diff', '--name-only', base_ref})
  if vim.v.shell_error ~= 0 then
    vim.notify('git diff failed for base ' .. base_ref, vim.log.levels.ERROR)
    return
  end
  local untracked_set = fetch_untracked(root)
  for f in pairs(untracked_set) do table.insert(files, f) end

  -- Remember where the user invoked rr from so new tabs land to its right.
  local start_tab = vim.api.nvim_get_current_tabpage()

  local new_set = {}
  for _, rel in ipairs(files) do new_set[rel] = true end

  -- Walk existing review tabs: refresh stats/file tabs still relevant, close
  -- file tabs whose files no longer appear in the diff.
  local existing = {}
  local existing_stats = false
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local info = review_info(tab)
    if info then
      local keep
      if info.stats then
        existing_stats = true
        keep = #files > 0
      else
        keep = new_set[info.rel] or false
        if keep then existing[info.rel] = true end
      end
      if keep then
        render_cmd_into_tab(tab, cmd_for_review_tab(info, root, base_ref, untracked_set))
        vim.t.review_base = base_ref
      else
        vim.api.nvim_set_current_tabpage(tab)
        vim.cmd('tabclose')
      end
    end
  end

  if #files == 0 then
    vim.notify('No changed files vs ' .. base_ref)
    return
  end

  -- New tabs are created "after current" by :tabnew, so navigate to the
  -- starting tab first. That anchors the stats tab immediately to its right.
  if vim.api.nvim_tabpage_is_valid(start_tab) then
    vim.api.nvim_set_current_tabpage(start_tab)
  end

  -- Create the stats tab first so it ends up as the leftmost review tab.
  if not existing_stats then
    vim.cmd('tabnew')
    vim.t.review_stats = true
    vim.t.review_base = base_ref
    open_diff_terminal(build_stats_cmd(root, base_ref))
  end

  -- Move to the rightmost existing review tab so new file tabs chain after it
  -- (keeping the review cluster contiguous and in order).
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if is_review_tab(tab) then
      vim.api.nvim_set_current_tabpage(tab)
    end
  end

  for _, rel in ipairs(files) do
    if not existing[rel] then
      local abs = root .. '/' .. rel
      vim.cmd('tabnew')
      vim.t.review_file = rel
      vim.t.review_base = base_ref
      local has_file = vim.fn.filereadable(abs) == 1
      if has_file then
        vim.cmd('edit ' .. vim.fn.fnameescape(abs))
        vim.cmd('topleft split')
      end
      open_diff_terminal(build_diff_cmd(root, base_ref, rel, untracked_set[rel] or false))
    end
  end

  last_wide = is_wide()

  -- Jump to the first review tab (stats if present, otherwise first file).
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if is_review_tab(tab) then
      vim.api.nvim_set_current_tabpage(tab)
      break
    end
  end
end

local function merge_base()
  for _, b in ipairs({'main', 'master'}) do
    local mb = vim.fn.systemlist({'git', 'merge-base', 'HEAD', b})[1]
    if vim.v.shell_error == 0 and mb and mb ~= '' then
      return mb
    end
  end
  return nil
end

-- Tabline: label review tabs with the shortest trailing path suffix that
-- uniquely identifies the file among all currently-open tabs. Non-review tabs
-- use the same logic based on their buffer name.
local function split_path(path)
  local parts = {}
  for p in path:gmatch('[^/]+') do table.insert(parts, p) end
  if #parts == 0 then parts = {path} end
  return parts
end

local function suffix_of(parts, n)
  local take = math.min(n, #parts)
  return table.concat(parts, '/', #parts - take + 1, #parts)
end

-- For each path, pick the shortest n such that suffix_of(parts[i], n) doesn't
-- collide with any other tab's suffix at that same level.
local function unique_suffixes(paths)
  local parts, depths = {}, {}
  for i, p in ipairs(paths) do
    parts[i] = split_path(p)
    depths[i] = 1
  end
  while true do
    local groups = {}
    for i = 1, #paths do
      local lbl = suffix_of(parts[i], depths[i])
      groups[lbl] = groups[lbl] or {}
      table.insert(groups[lbl], i)
    end
    local extended = false
    for _, members in pairs(groups) do
      if #members > 1 then
        for _, idx in ipairs(members) do
          if depths[idx] < #parts[idx] then
            depths[idx] = depths[idx] + 1
            extended = true
          end
        end
      end
    end
    if not extended then break end
  end
  local labels = {}
  for i = 1, #paths do
    labels[i] = suffix_of(parts[i], depths[i])
  end
  return labels
end

function M.tabline()
  local tabs = vim.api.nvim_list_tabpages()

  local paths = {}
  for i, tab in ipairs(tabs) do
    local rel = tab_var(tab, 'review_file')
    if tab_var(tab, 'review_stats') then
      paths[i] = '[stats]'
    elseif rel and rel ~= '' then
      paths[i] = rel
    else
      local win = vim.api.nvim_tabpage_get_win(tab)
      local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
      paths[i] = name == '' and '[No Name]' or name
    end
  end

  local labels = unique_suffixes(paths)

  local out = {}
  local cur = vim.api.nvim_get_current_tabpage()
  for i, tab in ipairs(tabs) do
    local hl = (tab == cur) and '%#TabLineSel#' or '%#TabLine#'
    table.insert(out, hl)
    table.insert(out, '%' .. i .. 'T')
    table.insert(out, ' ' .. labels[i] .. ' ')
  end
  table.insert(out, '%#TabLineFill#%T')
  return table.concat(out)
end

_G.__review_tabline = M.tabline
vim.o.tabline = '%!v:lua.__review_tabline()'

function M.vs_head()
  review_against('HEAD')
end

function M.vs_merge_base()
  local mb = merge_base()
  if not mb then
    vim.notify('No main/master branch found', vim.log.levels.ERROR)
    return
  end
  review_against(mb)
end

-- On terminal resize, re-render review tabs if we've crossed the wide/narrow
-- threshold. Uses an augroup so re-loading the module doesn't stack autocmds.
vim.api.nvim_create_augroup('ReviewResize', {clear = true})
vim.api.nvim_create_autocmd('VimResized', {
  group = 'ReviewResize',
  callback = function()
    if last_wide == nil then return end
    if is_wide() ~= last_wide then
      refresh_all_review_tabs()
    end
  end,
})

return M
