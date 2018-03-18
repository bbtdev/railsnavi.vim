function! SwitchToRailsSpecAlternate()
  let current_file = GetCurrentFile()
  let alternate_file = RailsSpecGetAlternate(current_file)

  if alternate_file != 'error'
    exec ':e ' . alternate_file
  else
    exec ':echo "This file is not compatible"'
  endif
endfunction

function! RailsSpecGetAlternate(file)
  let current_file = a:file
  let in_spec = IsInSpec(current_file)
  let in_app = IsCompatibleForSpec(current_file)
  if in_spec
    let new_file = GetFileForSpec(current_file)
  elseif in_app
    let new_file = GetSpecForFile(current_file)
  else
    return "error"
  endif

  return new_file
endfunction

function! GetCurrentFile()
  let current_file = expand("%")
  return current_file
endfunction

function! GetSpecForFile(file)
  let new_file = substitute(a:file, '^app/', '', '')
  if match(new_file, "rabl") != -1
    let new_file = substitute(new_file, '\.e\?rabl$', '\.rabl_spec\.rb', '')
  else
    let new_file = substitute(new_file, '\.e\?rb$', '_spec.rb', '')
  endif
  let new_file = 'spec/' . new_file

  return new_file
endfunction

function! GetFileForSpec(spec_file)
  let new_file = substitute(a:spec_file, '^spec/', '', '')
  if match(new_file, "rabl") != -1
    let new_file = substitute(new_file, '_spec\.rb$', '', '')
  else
    let new_file = substitute(new_file, '_spec\.rb$', '.rb', '')
  endif
  let new_file = 'app/' . new_file

  return new_file
endfunction

function! IsCompatibleForSpec(file)
  let current_file = a:file
  let in_app = match(current_file, '^app/') != -1
  let compatible_app_file = match(current_file, '\<services\>') != -1 || match(current_file, '\<jobs\>') != -1 || match(current_file, '\<controllers\>') != -1 || match(current_file, '\<models\>') != -1 || match(current_file, '\<workers\>') != -1 || match(current_file, '\<views\>') != -1 || match(current_file, '\<helpers\>') != -1

  if in_app && compatible_app_file
    return 1
  else
    return 0
  endif
endfunction

function! IsInSpec(file)
  let is_in_spec = match(a:file, '^spec/') != -1

  return is_in_spec
endfunction

function! RunSpecForFile()
  let file = GetCurrentFile()
  if IsCompatibleForSpec(file)
    let file = GetSpecForFile(file)
  endif
  
  exec '!rspec ' . file
endfunction

function! RunSpecDispatchForFile()
  let file = GetCurrentFile()
  if IsCompatibleForSpec(file)
    let file = GetSpecForFile(file)
  endif
  
  exec ':Dispatch rspec '. file
endfunction

fun! OpenFolderWithDirvish(folder)
  exec ':Dirvish ' . a:folder
endfun

fun! AlternateViewsFolderController()
  let file = expand("%:p")

  if match(file, "views") == -1
    let file = substitute(file, 'controllers', 'views', '')
    let file = substitute(file, '_controller.rb', '/', '')

    let something =  OpenFolderWithDirvish(file)
  else
    let file = substitute(file, 'views', 'controllers', '')
    let file = substitute(file, '/$', '_controller.rb', '')

    exec ':e ' . file
  endif
endfun

