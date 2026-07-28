#!/usr/bin/env python3
"""Inpainting con Replicate (flux-fill): borra/rellena SOLO la zona de la mascara,
dejando el resto de la imagen intacto. Ideal para quitar un objeto/personaje de una
imagen existente SIN regenerar toda la escena.

Uso:
  python3 tools/inpaint.py imagen.png mascara.png salida.png "prompt del relleno"
La mascara: BLANCO = zona a rellenar, NEGRO = se conserva tal cual.
Requiere REPLICATE_API_TOKEN y red hacia api.replicate.com / replicate.delivery.
"""
import base64
import json
import mimetypes
import os
import sys
import time
import urllib.request
import urllib.error

MODEL = "black-forest-labs/flux-fill-dev"
API = "https://api.replicate.com/v1/models/%s/predictions"


def _data_uri(path: str) -> str:
    mime = mimetypes.guess_type(path)[0] or "image/png"
    with open(path, "rb") as f:
        return "data:%s;base64,%s" % (mime, base64.b64encode(f.read()).decode("ascii"))


def _get(url: str, token: str) -> dict:
    req = urllib.request.Request(url, headers={"Authorization": "Bearer " + token})
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.loads(resp.read().decode("utf-8"))


def main() -> None:
    if len(sys.argv) < 5:
        sys.exit("uso: inpaint.py imagen mascara salida 'prompt'")
    image, mask, out_path, prompt = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
    token = os.environ.get("REPLICATE_API_TOKEN")
    if not token:
        sys.exit("ERROR: falta REPLICATE_API_TOKEN")

    body = json.dumps({"input": {
        "image": _data_uri(image),
        "mask": _data_uri(mask),
        "prompt": prompt,
        "output_format": "png",
        "num_inference_steps": 30,
        "guidance": 30,
    }}).encode("utf-8")
    req = urllib.request.Request(API % MODEL, data=body, method="POST", headers={
        "Authorization": "Bearer " + token,
        "Content-Type": "application/json",
        "Prefer": "wait",
    })
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        sys.exit("ERROR HTTP %s: %s" % (e.code, e.read().decode("utf-8", "ignore")[:400]))

    poll = data.get("urls", {}).get("get")
    deadline = time.time() + 240
    while data.get("status") in ("starting", "processing") and poll:
        if time.time() > deadline:
            sys.exit("TIMEOUT status=%s" % data.get("status"))
        time.sleep(2.0)
        data = _get(poll, token)

    output = data.get("output")
    if data.get("status") != "succeeded" or not output:
        sys.exit("Fallo: status=%s error=%s" % (data.get("status"), data.get("error")))
    url = output[0] if isinstance(output, list) else output
    urllib.request.urlretrieve(url, out_path)
    print("OK ->", out_path)


if __name__ == "__main__":
    main()
