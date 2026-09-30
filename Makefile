PYTHON ?= python3
PORT ?= 8000

CATALOG := models/catalog.json
SCAD := $(wildcard models/*.scad)
VENDOR_STAMP := vendor/.stamp
REQUIRED := index.html js/app.js js/render-worker.js css/style.css LICENSE \
	fonts/LiberationSans-Regular.ttf vendor/openscad-wasm/openscad.wasm \
	vendor/three/three.module.js

.PHONY: all catalog vendor serve check clean help

all: vendor catalog

catalog: $(CATALOG)

$(CATALOG): $(SCAD) scripts/catalog.py
	$(PYTHON) scripts/catalog.py

vendor: $(VENDOR_STAMP)

$(VENDOR_STAMP): scripts/fetch-vendor.py
	$(PYTHON) scripts/fetch-vendor.py

serve: vendor catalog
	@echo "Serving on http://127.0.0.1:$(PORT)/"
	$(PYTHON) -m http.server $(PORT)

check: vendor catalog
	@test -s $(CATALOG)
	@$(PYTHON) -c "import json, pathlib, sys; \
p = pathlib.Path('$(CATALOG)'); \
models = json.loads(p.read_text()); \
missing = [m.get('path','') for m in models if not pathlib.Path(str(m.get('path','')).lstrip('./')).exists()]; \
sys.exit('missing model files: ' + ', '.join(missing) if missing else 0)"
	@for f in $(REQUIRED); do test -e $$f || { echo "missing $$f"; exit 1; }; done
	@echo "ok: catalog, models, and required assets are present"

clean:
	rm -f $(CATALOG)

help:
	@echo "SCAD Workbench"
	@echo
	@echo "  make          fetch vendor assets and rebuild models/catalog.json"
	@echo "  make vendor   download OpenSCAD WASM and Three.js into vendor/"
	@echo "  make catalog  rebuild models/catalog.json from models/*.scad"
	@echo "  make serve    fetch vendors, rebuild the catalog, then serve on PORT ($(PORT))"
	@echo "  make check    verify catalog paths and required static files"
	@echo "  make clean    remove the generated catalog"
	@echo "  make help     show this text"
	@echo
	@echo "Add a library model by dropping a .scad file in models/ and running make."
	@echo "Optional header comments:  // name: …   // description: …"
	@echo "Override the port with  make serve PORT=8080"
