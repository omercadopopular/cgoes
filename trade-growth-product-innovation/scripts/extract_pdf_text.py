from pathlib import Path
from pypdf import PdfReader

pdf_path = Path(__file__).resolve().parent.parent / 'Trade__Growth_and_Product_Innovation.pdf'
out_path = Path(__file__).resolve().parent / 'Trade__Growth_and_Product_Innovation.txt'

text_chunks = []
reader = PdfReader(str(pdf_path))
for i, page in enumerate(reader.pages):
    try:
        text_chunks.append(page.extract_text() or '')
    except Exception as e:
        text_chunks.append(f"\n[[PAGE {i} extraction error: {e}]]\n")

text = '\n\n'.join(text_chunks)
out_path.write_text(text, encoding='utf-8')
print(f'Wrote {len(text)} chars to {out_path}')
