from zipfile import ZipFile, ZIP_DEFLATED
from os import listdir, path, mkdir, walk

def create_bundle(name):
	if not path.exists("dist"):
		mkdir("dist")

	bundle_name = f"{name}.zip"
	bundle_path = path.join("dist", bundle_name)
	with ZipFile(bundle_path, "w", ZIP_DEFLATED) as new_zip:
		new_zip.writestr(path.join("src", "__init__.py"), "")
		for script_file in listdir("src"):
			new_zip.write(path.join("src", script_file))
		zip_all_files('build_dep', new_zip)
	return bundle_path, bundle_name

def zip_all_files(path1, zipf):
	if not path.exists(path1):
		return

	for root, dirs, files in walk(path.join(path1)):
		for filename in files:
			arcroot = root.replace(path1, '')
			zipf.write(path.join(root, filename), arcname=path.join(arcroot.filename))

create_bundle("da-lambda")
