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
import time
import urllib.request
import urllib.error


API = "https://api.replicate.com/v1/models/%s/predictions"

# Estilo artistico COMUN a todo el juego (concept art pintado, NO fotorrealista),
# para mantener coherencia con el arte que subio el diseñador (menu, storyboard,
# IMG_1501). Se agrega a cada prompt salvo que se pase --no-style.
STYLE = (" . Hand-painted 2D digital illustration, storybook fantasy concept art, "
         "painterly visible brush strokes, warm cozy indie game key art, stylized and "
         "charming, soft shading, rich warm colors. NOT photorealistic, NOT 3d render, "
         "NOT a photograph, no realism, no hyperrealism.")


def _get(url: str, token: str) -> dict:
    req = urllib.request.Request(url, headers={"Authorization": "Bearer " + token})
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.loads(resp.read().decode("utf-8"))


def _poll(data: dict, token: str, timeout_s: int = 180) -> dict:
    """Espera a que la prediccion llegue a un estado terminal."""
    poll_url = data.get("urls", {}).get("get")
    deadline = time.time() + timeout_s
    while data.get("status") in ("starting", "processing") and poll_url:
        if time.time() > deadline:
            sys.exit("TIMEOUT: la prediccion no termino en %ss (status=%s)" % (timeout_s, data.get("status")))
        time.sleep(2.0)
        data = _get(poll_url, token)
    return data


def generate(prompt: str, out_path: str, model: str, aspect: str, fmt: str, use_style: bool) -> None:
    token = os.environ.get("REPLICATE_API_TOKEN")
    if not token:
        sys.exit("ERROR: falta REPLICATE_API_TOKEN (cargalo como secreto del entorno).")

    full_prompt = prompt + (STYLE if use_style else "")
    body = json.dumps({
        "input": {
            "prompt": full_prompt,
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
        with urllib.request.urlopen(req, timeout=120) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        sys.exit("ERROR HTTP %s: %s" % (e.code, e.read().decode("utf-8", "ignore")[:400]))
    except urllib.error.URLError as e:
        sys.exit("ERROR de red (¿host bloqueado por la politica del entorno?): %s" % e.reason)

    # Prefer: wait puede devolver antes de terminar; esperamos por polling.
    data = _poll(data, token)
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
    ap.add_argument("--no-style", action="store_true", help="no agregar el sufijo de estilo comun")
    a = ap.parse_args()
    generate(a.prompt, a.output, a.model, a.aspect, a.format, not a.no_style)


if __name__ == "__main__":
    main()
