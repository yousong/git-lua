A repository trying to record every available official version of Lua.

All versions are tagged.

	git log --stat --summary --find-renames
	git diff -p --stat --summary --find-renames lua-5.1.4 lua-5.1.5

[Empty directories in source tarballs are not tracked in `lua-source/` directory.](https://git.wiki.kernel.org/index.php/GitFaq#Can_I_add_empty_directories.3F)

## Maintenance

	. ./scripts/environ-setup.sh

	# fetch release info to local.
	update_release_info
	# check if anything interesting changed.
	git diff

	# do the update.
	fetch_version lua-5.2.0
	import_version lua-5.2.0

	# check logs and tags
	# push
	git push --tags origin master

## TODO

- Add infrastructure for building and testing.

## Useful links.

### Official ones

- Lua Version History (with timeline and summary text on each major version), http://www.lua.org/versions.html
- Lua manuals (available in HTML, PostScript, PDF formats), http://www.lua.org/manual/

### Other efforts

[LuaDist](http://luadist.org/)

> LuaDist is a true multi-platform package management system that aims to provide both source and binary repository of modules for the Lua programming language.  

[http://repo.or.cz/w/lua.git](http://repo.or.cz/w/lua.git)

> Mirror of the Lua history from 1.0 - 5.1.2 + latest bugfixes

[Tar archive frontend for git-fast-import](https://github.com/git/git/blob/master/contrib/fast-import/import-tars.perl)

Just write another one for the current specific situation is faster than reading the code.

[Lua 5.3 中文文档](http://cloudwu.github.io/lua53doc/), by [cloudwu](https://github.com/cloudwu/lua53doc)
