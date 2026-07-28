#!/usr/bin/env python3
"""Genera una imagen con Replicate y la guarda en el repo.

Requisitos (config del ENTORNO de Claude Code, no del codigo):
  1) Politica de red que permita:  api.replicate.com, replicate.delivery,
     pbxt.replicate.delivery
  2) Variable de entorno:  REPLICATE_API_TOKEN=r8_xxx  (secreto del entorno)

Uso:
  python3 tools/gen_image.py "prompt..." assets/ui/tienda_vacia.png --aspect 16:9
  opciones:
    --aspect  1:1 | 16:9 | 3:2 | 9:16 ...   (por defecto 16:9)
    --model   owner/model  (por defecto black-forest-labs/flux-schnell)
    --format  png | jpg | webp              (por defecto png)

Nota: usa el endpoint sincrono de Replicate (Prefer: wait); no hace falta pollear.
Solo depende de la libreria estandar (urllib), asi no requiere pip.
"""
import argparse
import json
import os
import sys
import urllib.request
import urllib.error


API = "https://api.replicate.com/v1/models/%s/predictions"


def generate(prompt: str, out_path: str, model: str, aspect: str, fmt: str) -> None:
    token = os.environ.get("REPLICATE_API_TOKEN")
    if not token:
        sys.exit("ERROR: falta REPLICATE_API_TOKEN (cargalo como secreto del entorno).")

    body = json.dumps({
        "input": {
            "prompt": prompt,
            "aspect_ratio": aspect,
            "output_format": fmt,
        }
    }).encode("utf-8")

    req = urllib.request.Request(
        API % model,
        data=body,
        method="POST",
        headers={
            "Authorization": "Bearer " + token,
            "Content-Type": "application/json",
            "Prefer": "wait",  # espera a que termine y devuelve el resultado
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=180) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        sys.exit("ERROR HTTP %s: %s" % (e.code, e.read().decode("utf-8", "ignore")[:400]))
    except urllib.error.URLError as e:
        sys.exit("ERROR de red (¿host bloqueado por la politica del entorno?): %s" % e.reason)

    status = data.get("status")
    output = data.get("output")
    if status != "succeeded" or not output:
        sys.exit("La generacion no termino OK: status=%s error=%s" % (status, data.get("error")))

    url = output[0] if isinstance(output, list) else output
    os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)
    urllib.request.urlretrieve(url, out_path)
    print("OK -> %s  (modelo %s, %s)" % (out_path, model, aspect))


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("prompt")
    ap.add_argument("output")
    ap.add_argument("--aspect", default="16:9")
    ap.add_argument("--model", default="black-forest-labs/flux-schnell")
    ap.add_argument("--format", default="png")
    a = ap.parse_args()
    generate(a.prompt, a.output, a.model, a.aspect, a.format)


if __name__ == "__main__":
    main()
