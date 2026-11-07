import subprocess
import tempfile
from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.responses import Response
from pydantic import BaseModel

app = FastAPI(title="LaTeX compiler")


class CompileRequest(BaseModel):
    tex: str


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/compile")
def compile_tex(req: CompileRequest):
    with tempfile.TemporaryDirectory() as tmp:
        tex_file = Path(tmp) / "doc.tex"
        tex_file.write_text(req.tex, encoding="utf-8")

        result = subprocess.run(
            ["pdflatex", "-interaction=nonstopmode", "-halt-on-error",
             "-no-shell-escape", "doc.tex"],
            cwd=tmp, capture_output=True, text=True, timeout=60,
        )

        pdf_file = Path(tmp) / "doc.pdf"
        if result.returncode != 0 or not pdf_file.exists():
            raise HTTPException(status_code=422, detail=result.stdout[-1500:])

        return Response(content=pdf_file.read_bytes(), media_type="application/pdf")