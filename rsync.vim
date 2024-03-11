

function! rsync#get_json(...)
	let local_path = get(a:, 1, '/')
	let cnf_name = '.rsync.cnf'
	let cnf_path = local_path.cnf_name 

	if filereadable(cnf_path)
		let cnf_json = system('cat '.cnf_path)
		let cnf = json_decode(cnf_json)
		let cnf['local_path'] = local_path
		call add(cnf['exclude_local_paths'], cnf_name)
		return cnf
	endif

	return v:false
endfunction


function! rsync#get_cnf()
	let arr_paths = split(expand('%:p:h'), '/')
	while len(arr_paths)
		let path = '/'.join(arr_paths, '/').'/'
		let cnf = rsync#get_json(path)
		if cnf isnot v:false | return cnf | endif
		unlet arr_paths[-1]
	endwhile
	return rsync#get_json()
endfunction


function! rsync#download()
	let cnf = rsync#get_cnf()
	if cnf is v:false | echom 'Error not found .rsync.cnf file' | return | endif
	
	let excludes = '' 
	for exclude in cnf.exclude_remote_paths
		let excludes .= '--exclude \"'.exclude.'\" ' 	
	endfor

	let cmd = printf('expect -c "set timeout -1; spawn rsync -a %s %s@%s:%s %s;'.
		\ 'expect \"password:\"; send %s\r; expect \"total size\""',
		\ excludes, cnf.user, cnf.host, cnf.remote_path,  cnf.local_path, cnf.password)
	execute '!'.cmd
endfunction


function! rsync#upload()
	let cnf = rsync#get_cnf()
	if cnf is v:false | echom 'Error not found .rsync.cnf file' | return | endif
	
	let filename = expand('%:p')
	let filename = substitute(filename, cnf.local_path, '', '')
	echo filename
endfunction


