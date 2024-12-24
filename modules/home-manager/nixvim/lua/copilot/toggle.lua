(function(vim)
  return function()
    local isEnabled =
      vim.api.nvim_exec(":Copilot status", true) == 'Copilot: Ready'
    if isEnabled then
      vim.cmd('Copilot disable')
      print('Copilot disabled')
    else
      vim.cmd('Copilot enable')
      print('Copilot enabled')
    end
  end
  ---@diagnostic disable-next-line: undefined-global
end)(vim)
