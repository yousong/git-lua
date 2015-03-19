import sys
import re
import json

# usage.
if len(sys.argv) < 3:
    sys.stderr.write("Usage: %s <base_url> <release_page.html>\n" % sys.argv[0]);
    sys.exit(1)

# base_url for download
base_url = sys.argv[1]
release_page = sys.argv[2]
if not base_url.endswith("/"):
    base_url += "/"
with open(release_page, "rb") as fin:
    release_page_data = fin.read()

# order of fields in .lst
Keys = ("ver", "date", "md5", "sha1", "url")
RE_release = re.compile(
           r"(?P<ver>lua-[0-9.]+)\.tar\.gz"
    r".*?" r"(?P<date>\d\d\d\d-\d\d-\d\d)"
    r".*?" r"md5: (?P<md5>[a-f0-9]{32})"
    r".*?" r"sha1: (?P<sha1>[a-f0-9]{40})"
    , re.DOTALL)

release_info = []
for m in RE_release.finditer(release_page_data):
    info = m.groupdict()
    url = base_url + m.group("ver") + ".tar.gz"
    info["url"] = url
    release_info.append(info)
    #print g(m, "ver")

with open("release-info.json", "wb") as fout:
    json.dump(release_info, fout)

with open("release-info.lst", "wb") as fout:
    l = lambda r: (r[k] for k in Keys)
    rows = (" ".join(l(r)) for r in release_info)
    data = "\n".join(rows)
    fout.write(data);

if __name__ == "__main__":
    pass
