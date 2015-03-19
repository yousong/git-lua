TOPDIR="$(pwd)"
TARBALLS_DIR="$TOPDIR/tarballs"
SOURCE_DIR="$TOPDIR/lua-source"
SCRIPTS_DIR="$TOPDIR/scripts"

_tmp_dir="$TOPDIR/tmp"

RELEASE_URL="http://www.lua.org/ftp/"
RELEASE_PAGE="$TOPDIR/release-page.html"
RELEASE_INFO_LST="$TOPDIR/release-info.lst"

__info() {
	echo -e '\e[34;42m'"info: $1"'\e[0m' >&2
}

__error() {
	echo -e '\e[37;41m'"error: $1"'\e[0m' >&2
}

update_release_info() {
	wget -O "$RELEASE_PAGE" "$RELEASE_URL"
	python "$SCRIPTS_DIR/extract-release-info.py" "$RELEASE_URL" "$RELEASE_PAGE"
}

fetch_version() {
	local ver="$1"
	local lst_line="$(cat "$RELEASE_INFO_LST" | grep "^$ver ")"

	[ -z "$lst_line" ] && {
		__error "cannot find $ver in $RELEASE_INFO_LST."
		return 1
	}

	local url="$(echo "$lst_line" | cut -d ' ' -f 5)"
	local csum="$(echo "$lst_line" | cut -d ' ' -f 3)"
	local fname="$(basename "$url")"

	(
		cd "$TARBALLS_DIR";
		wget -c "$url" || {
			__error "download $url failed."
			exit 1
		};
		echo "$csum $fname" | md5sum --check || {
			__error "md5sum $fname failed."
			exit 1
		};
	)
}

import_version() {
    local ver="$1"
    local fname="$1.tar.gz"
    local fpath="$TARBALLS_DIR/$fname"

    rm -rf "$_tmp_dir" && \
        mkdir -p "$_tmp_dir"

    # balls are complete?
    [ -s "$fpath" ] || {
        __error "cannot find non-empty file $fpath."
        return 1
    }

    # already imported?
    git tag | grep --quiet --fixed-strings "$ver" && {
        __error "$ver already imported"
        return 0
    }

    # inflation okay?
    tar xzf "$fpath" -C "$_tmp_dir" || {
        __error "tar xzf $fpath failed."
        return 1
    }

    # reset source directory okay?
    #  1. Check if $SOURCE_DIR was tracked
    #  2. git-rm it.
    #  3. rm -rf it for empty directoires there.
    #  4. mkdir -p the directory
    git ls-files "$SOURCE_DIR" --error-unmatch 2>/dev/null && {
        git rm -r "$SOURCE_DIR" && \
        rm -rf "$SOURCE_DIR" && \
        mkdir -p "$SOURCE_DIR" || {
            __error "reset $SOURCE_DIR failed."
            return 1
        }
    }

    # move okay?
    # -T is for treating DEST as a normal file.
    mv -T "$(find $_tmp_dir/ -type d -maxdepth 1 -mindepth 1)" "$SOURCE_DIR" || {
        __error "move from $_tmp_dir/ to $SOURCE_DIR failed."
        return 1
    }

    # git add, commit, tag okay?
    git add "$SOURCE_DIR" && \
        git commit -m "lua-source: import $ver." && \
        git tag "$ver" HEAD || {
        __error "git {add,commit,tag} failed."
        return 1
    }
}

_import_all_versions() {
    local lst="$TOPDIR/release-info.lst"
    local ver

    cat "$lst" | cut -f 1 -d ' ' | sort --numeric-sort | while read ver; do
        import_version "$ver" && {
            __info "succeed importing $ver."
        } || {
            __error "failed importing $ver."
        }
    done
}

_fetch_all_versions() {
    local lst="$TOPDIR/release-info.lst"
    local ver

    cat "$lst" | cut -f 1 -d ' ' | sort --numeric-sort | while read ver; do
        fetch_version "$ver" && {
            __info "succeed fetching $ver."
        } || {
            __error "failed fetching $ver."
        }
    done
}
