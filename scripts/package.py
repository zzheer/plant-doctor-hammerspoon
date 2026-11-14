from pathlib import Path
import hashlib, sys, zipfile
root = Path(__file__).resolve().parents[1]
source = root / "Source/PlantDoctorPhotoPrep.spoon"
output = Path(sys.argv[1]).resolve()
if output.is_relative_to(root):
    raise SystemExit("Output must be outside source repository")
output.parent.mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(output, "w", zipfile.ZIP_DEFLATED) as z:
    for name in ("init.lua", "docs.json", "README.md", "LICENSE"):
        data = (source/name).read_bytes()
        info = zipfile.ZipInfo("PlantDoctorPhotoPrep.spoon/" + name, (2026,1,1,0,0,0))
        info.external_attr = 0o100644 << 16
        info.compress_type = zipfile.ZIP_DEFLATED
        z.writestr(info, data)
print(output)
print(hashlib.sha256(output.read_bytes()).hexdigest())
